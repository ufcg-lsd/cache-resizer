library(ggplot2)
library(dplyr)
library(lubridate)

setwd("/home/augusto/workspace/cache-resizer/redis/src")

logs <- read.table("resources/r90/logs.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(logs) <- c("date", "time", "client", "key", "latency", "status")

resize_timestamp <- as.POSIXct("12:05:36", format="%H:%M:%S", tz="UTC")

# 1 min after real start (without warmup)
start_time <- as.POSIXct("12:04:36", format="%H:%M:%S", tz="UTC")
logs$timest <- as.POSIXct(logs$time, format="%H:%M:%S", tz="UTC")
logs$latency <- as.numeric(sub("µs", "", logs$latency))

# Only hits and without warmup
logs <- filter(logs, timest >= start_time, status == "hit")

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
  geom_vline(xintercept = resize_timestamp, color = "gray", linetype = "dotdash", size = 1) +
  labs(title = "Average Latency over Time", x = "Timestamp", y = "Average Latency (µs)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

# Plot 2: Throughput over time (requests per second)
plot_throughput <- ggplot(logs_summary, aes(x = timest, y = throughput)) +
  geom_line(color = "blue") +
  geom_vline(xintercept = as.numeric(resize_timestamp), color = "gray", linetype = "dotdash", size = 1) +
  labs(title = "Throughput over Time", x = "Timestamp", y = "Throughput (requests per second)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

ggsave("resources/r90/latency_plot.png", plot = plot_latency)
ggsave("resources/r90/throughput_plot.png", plot = plot_throughput)

print(plot_latency)
print(plot_throughput)
