# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)

setwd("/home/augusto/workspace/cache-resizer/redis/src")

logs <- read.table("resources/r50/logs.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(logs) <- c("date", "timestamp", "client", "key", "latency", "status")

# 1 min after real start (without warmup)
start_time <- as.POSIXct("11:46:19", format="%H:%M:%S", tz="UTC")
logs$timest <- as.POSIXct(logs$time, format="%H:%M:%S", tz="UTC")
logs$latency <- as.numeric(sub("µs", "", logs$latency))

# Only hits and without warmup
logs <- filter(logs, timest >= start_time, status == "hit", latency < 1000) # Review latency < 1000


# Throughput and Average Latency
logs_summary <- logs %>%
  group_by(timest) %>%
  summarise(
    avg_latency = mean(latency),
    throughput = n()
  )

# Plot 1: Average Latency over time (per second)
plot_latency <- ggplot(logs_summary, aes(x = timest, y = avg_latency)) +
  geom_line(color = "red") +
  labs(title = "Average Latency over Time", x = "Timestamp", y = "Average Latency (µs)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

# Plot 2: Throughput over time (requests per second)
plot_throughput <- ggplot(logs_summary, aes(x = timest, y = throughput)) +
  geom_line(color = "blue") +
  labs(title = "Throughput over Time", x = "Timestamp", y = "Throughput (requests per second)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

ggsave("resources/r50/latency_plot.png", plot = plot_latency)
ggsave("resources/r50/throughput_plot.png", plot = plot_throughput)

print(plot_latency)
print(plot_throughput)
