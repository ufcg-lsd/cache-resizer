# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)

# Read the logs file
logs <- read.table("logs.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(logs) <- c("date", "time", "client", "key", "latency", "status")

# Combine date and time into a single datetime column
logs$timestamp <- as.POSIXct(paste(logs$date, logs$time), format="%Y/%m/%d %H:%M:%S")

# Convert latency to microseconds
logs$latency <- ifelse(grepl("ms", logs$latency), as.numeric(sub("ms", "", logs$latency)) * 1000, as.numeric(sub("µs", "", logs$latency)))

# Calculate throughput (requests per second)
logs <- logs %>%
  group_by(timestamp) %>%
  mutate(throughput = n())

# Plot 1: Latency over time
plot_latency <- ggplot(logs, aes(x = timestamp, y = latency)) +
  geom_line(color = "red") +
  labs(title = "Latency over Time", x = "Timestamp", y = "Latency (µs)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "10 sec") +
  theme_minimal()

# Plot 2: Throughput over time
plot_throughput <- ggplot(logs, aes(x = timestamp, y = throughput)) +
  geom_line(color = "blue") +
  labs(title = "Throughput over Time", x = "Timestamp", y = "Throughput (requests per second)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "10 sec") +
  theme_minimal()

# Save the plots
ggsave("latency_plot.png", plot = plot_latency)
ggsave("throughput_plot.png", plot = plot_throughput)

# Print the plots
print(plot_latency)
print(plot_throughput)
