# Load necessary libraries
library(ggplot2)
library(dplyr)

# Step 1: Read the log file
logs <- readLines("logs.txt")

# Step 2: Extract data from logs using regex
extract_data <- function(log_line) {
  parts <- strsplit(log_line, ",")[[1]]
  id <- as.numeric(gsub("Id=", "", parts[1]))
  start <- as.numeric(gsub("start=", "", parts[2]))
  end <- as.numeric(gsub("end=", "", parts[3]))
  total_time <- as.numeric(gsub("totalTime=", "", parts[4]))

  data.frame(Id = id, Start = start, End = end, TotalTime = total_time)
}

# Step 3: Convert all logs to a data frame
log_data <- do.call(rbind, lapply(logs, extract_data))

# Step 4: Calculate throughput (requests per second)
log_data <- log_data %>%
  mutate(Throughput = 1 / (TotalTime / 1e6)) # Throughput in requests per second

# Step 5: Plot Latency
ggplot(log_data, aes(x = Id, y = TotalTime)) +
  geom_line(color = "red") +
  labs(title = "Request Latency Over Time", x = "Request ID", y = "Total Time (microseconds)") +
  theme_minimal()

# Save the Latency plot
ggsave("latency_plot.png")

# Step 6: Plot Throughput
ggplot(log_data, aes(x = Id, y = Throughput)) +
  geom_line(color = "blue") +
  labs(title = "Request Throughput Over Time", x = "Request ID", y = "Throughput (requests/second)") +
  theme_minimal()

# Save the Throughput plot
ggsave("throughput_plot.png")
