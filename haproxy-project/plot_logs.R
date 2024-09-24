# Load necessary libraries
library(ggplot2)
library(dplyr)

# Step 1: Read the log file
logs <- readLines("logs.txt")

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

# Step 4: Calculate throughput (requests per second)
log_data <- log_data %>%
  mutate(Throughput = 1 / (TotalTime / 1e6))  # Convert total time from microseconds to seconds

# Step 5: Group data into 10-second intervals and calculate the mean values
log_data_summary <- log_data %>%
  mutate(TimeGroup = cut(StartDate, breaks = "5 sec")) %>% # Group data into 10-second intervals
  group_by(TimeGroup) %>%
  summarise(MeanLatency = mean(TotalTime), MeanThroughput = mean(Throughput))

# Step 6: Convert TimeGroup back to POSIXct for plotting
log_data_summary <- log_data_summary %>%
  mutate(TimeGroup = as.POSIXct(TimeGroup))

# Step 7: Plot Mean Latency over time
ggplot(log_data_summary, aes(x = TimeGroup, y = MeanLatency)) +
  geom_line(color = "red") +
  labs(title = "Mean Request Latency Over Time (5-second intervals)",
       x = "Timestamp",
       y = "Mean Latency (microseconds)") +
  theme_minimal()

# Save the Mean Latency plot
ggsave("mean_latency_plot.png")

# Step 8: Plot Mean Throughput over time
ggplot(log_data_summary, aes(x = TimeGroup, y = MeanThroughput)) +
  geom_line(color = "blue") +
  labs(title = "Mean Request Throughput Over Time (5-second intervals)",
       x = "Timestamp",
       y = "Mean Throughput (requests/second)") +
  theme_minimal()

# Save the Mean Throughput plot
ggsave("mean_throughput_plot.png")
