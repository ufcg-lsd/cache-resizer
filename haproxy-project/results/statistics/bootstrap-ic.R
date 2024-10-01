# Load necessary libraries
library(dplyr)

# Step 1: Read the log file
logs <- readLines("../10-percent/logs.txt")

# Step 2: Extract data from logs using regex
extract_data <- function(log_line) {
  parts <- strsplit(log_line, ",")[[1]]
  id <- as.numeric(gsub("Id=", "", parts[1]))
  start_date <- as.POSIXct(gsub("start_date=", "", parts[2]), format="%Y-%m-%d %H:%M:%OS")
  total_time <- as.numeric(gsub("totalTime=", "", parts[3]))

  # Throughput is the inverse of latency (requests per second)
  throughput <- 1 / (total_time / 1e6)  # Convert microseconds to seconds

  data.frame(Id = id, StartDate = start_date, TotalTime = total_time, Throughput = throughput)
}

# Step 3: Convert all logs to a data frame
log_data <- do.call(rbind, lapply(logs, extract_data))

# Step 4: Identify the start of new intervals (when Id=2)
log_data <- log_data %>%
  mutate(IsNewInterval = ifelse(Id == 2, TRUE, FALSE))  # Mark intervals where Id=2

# Step 5: Create an interval ID to group data by each new interval
log_data <- log_data %>%
  mutate(IntervalID = cumsum(IsNewInterval))

# Function to calculate bootstrap confidence intervals
bootstrap_ci <- function(data, n_bootstrap = 1000, conf_level = 0.95) {
  # Replicate the bootstrap process
  bootstrap_means <- replicate(n_bootstrap, {
    sample_data <- sample(data, replace = TRUE)
    mean(sample_data)
  })

  # Calculate percentiles for the confidence interval
  alpha <- (1 - conf_level) / 2
  lower_bound <- quantile(bootstrap_means, probs = alpha)
  upper_bound <- quantile(bootstrap_means, probs = 1 - alpha)

  return(c(lower_bound, upper_bound))
}

# Step 6: Apply manual bootstrap CI calculation for both latency and throughput for each interval
results <- log_data %>%
  group_by(IntervalID) %>%
  summarise(
    IntervalStart = min(StartDate),
    IntervalEnd = max(StartDate),
    AvgLatency = mean(TotalTime),
    Latency_CI_Lower = bootstrap_ci(TotalTime)[1],
    Latency_CI_Upper = bootstrap_ci(TotalTime)[2],
    AvgThroughput = mean(Throughput),
    Throughput_CI_Lower = bootstrap_ci(Throughput)[1],
    Throughput_CI_Upper = bootstrap_ci(Throughput)[2]
  )

# Optional: Add visualization of the confidence intervals for inspection
print(results)

# Step 7: Save the results to a CSV file
write.csv(results, "bootstrap_confidence_intervals_latency_throughput-10.csv", row.names = FALSE)
