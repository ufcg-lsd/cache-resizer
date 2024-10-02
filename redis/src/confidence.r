library(dplyr)
library(lubridate)

setwd("/home/augusto/workspace/cache-resizer/redis/src")

logs <- read.table("resources/r10/logs.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(logs) <- c("date", "time", "client", "key", "latency", "status")

resize_start <- as.POSIXct("11:19:49", format="%H:%M:%S", tz="UTC")
resize_end <- as.POSIXct("11:19:50", format="%H:%M:%S", tz="UTC")

# 1 min after real start (without warmup)
start_time <- as.POSIXct("11:18:49", format="%H:%M:%S", tz="UTC")
logs$timest <- as.POSIXct(logs$time, format="%H:%M:%S", tz="UTC")
logs$latency <- as.numeric(sub("µs", "", logs$latency))

# Only hits
logs_hits <- filter(logs, timest >= start_time, status == "hit") # Review latency < 1000
logs <- filter(logs, timest >= start_time)

# Split data by periods: before, during and after resizing
before_resize <- filter(logs_hits, timest < resize_start)
during_resize <- filter(logs_hits, timest >= resize_start & timest <= resize_end)
after_resize <- filter(logs_hits, timest > resize_end)

before_resize_t <- filter(logs, timest < resize_start)
after_resize_t <- filter(logs, timest > resize_end)

# Mean Latency and Throughput before and after resize
print(mean(before_resize$latency))
print(mean(after_resize$latency))

logs_before <- before_resize_t %>%
  group_by(timest) %>%
  summarise(
    throughput = n()
  )

logs_after <- after_resize_t %>%
  group_by(timest) %>%
  summarise(
    throughput = n()
  )

print(mean(logs_before$throughput))
print(mean(logs_after$throughput))

# Function to calculate the confidence interval with bootstrap
calc_confidence_interval_bootstrap <- function(data, confidence = 0.95, n_boot = 200) {
  # Define a matrix to store the bootstrap samples
  boot_samples <- replicate(n_boot, sample(data, replace = TRUE))

  # Calculate the mean of each bootstrap sample
  boot_means <- apply(boot_samples, 2, mean)

  # Set the lower and upper bounds of the confidence interval
  ci_lower <- quantile(boot_means, (1 - confidence) / 2)
  ci_upper <- quantile(boot_means, 1 - (1 - confidence) / 2)

  return(c(ci_lower, ci_upper))
}

ci_bootstrap_before_hit <- calc_confidence_interval_bootstrap(before_resize$latency)
ci_bootstrap_during_hit <- calc_confidence_interval_bootstrap(during_resize$latency)
ci_bootstrap_after_hit <- calc_confidence_interval_bootstrap(after_resize$latency)

file_conn <- file("resources/r75/confidence.txt")
cat("IC bootstrap Antes do redimensionamento: [", ci_bootstrap_before_hit[1], ", ", ci_bootstrap_before_hit[2], "]\n",
    "IC bootstrap Durante o redimensionamento: [", ci_bootstrap_during_hit[1], ", ", ci_bootstrap_during_hit[2], "]\n",
    "IC bootstrap Após o redimensionamento: [", ci_bootstrap_after_hit[1], ", ", ci_bootstrap_after_hit[2], "]\n",
    file = file_conn)

close(file_conn)

