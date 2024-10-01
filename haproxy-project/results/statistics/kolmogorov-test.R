# Load necessary libraries
library(dplyr)

# Step 1: Read the log file
logs <- readLines("./results/90-percent/logs.txt")

# Step 2: Extract data from logs using regex
extract_data <- function(log_line) {
  parts <- strsplit(log_line, ",")[[1]]
  id <- as.numeric(gsub("Id=", "", parts[1]))
  start_date <- as.POSIXct(gsub("start_date=", "", parts[2]), format="%Y-%m-%d %H:%M:%OS")
  total_time <- as.numeric(gsub("totalTime=", "", parts[3]))

  data.frame(Id = id, StartDate = start_date, TotalTime = total_time)
}

# Step 3: Convert all logs to a data frame
log_data <- do.call(rbind, lapply(logs, extract_data))

# Step 4: Identify the start of new intervals (when Id=2)
log_data <- log_data %>%
  mutate(IsNewInterval = ifelse(Id == 2, TRUE, FALSE))  # Mark intervals where Id=2

# Step 5: Create an interval ID to group data by each new interval
log_data <- log_data %>%
  mutate(IntervalID = cumsum(IsNewInterval))

# Step 6: Function to perform Kolmogorov-Smirnov test for each interval
run_ks_test <- function(interval_data) {
  # Extract latency data (TotalTime)
  latency_data <- interval_data$TotalTime

  # Run the K-S test
  ks_test_result <- ks.test(latency_data, "pnorm", mean = mean(latency_data), sd = sd(latency_data))

  return(ks_test_result)
}

# Step 7: Apply the K-S test to each interval and store the results
ks_results <- log_data %>%
  group_by(IntervalID) %>%
  do(ks_test = run_ks_test(.)) %>%
  summarise(
    IntervalID = IntervalID,
    p_value = ks_test$p.value,
    statistic = ks_test$statistic
  )

# Step 8: Print the results of the K-S test for each interval
print(ks_results)

# Optionally save the results to a CSV file
write.csv(ks_results, "ks_test_results.csv", row.names = FALSE)
