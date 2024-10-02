library(ggplot2)
library(dplyr)
library(lubridate)

setwd("/home/augusto/workspace/cache-resizer/redis/src")

logs <- read.table("resources/r50/logs.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(logs) <- c("date", "time", "client", "key", "latency", "status")

resize_timestamp <- as.POSIXct("11:47:19", format="%H:%M:%S", tz="UTC")

# 1 min after real start (without warmup)
start_time <- as.POSIXct("11:46:19", format="%H:%M:%S", tz="UTC")
logs$timest <- as.POSIXct(logs$time, format="%H:%M:%S", tz="UTC")
logs$latency <- as.numeric(sub("µs", "", logs$latency))

# Only hits and without warmup
logs <- filter(logs, timest >= start_time)
logs_latency <- filter(logs, status == "hit")

# Average Latency
logs_avg_latency <- logs_latency %>%
  group_by(timest) %>%
  summarise(
    avg_latency = mean(latency)
  )

# Throughput
logs_throughput <- logs %>%
  group_by(timest) %>%
  summarise(
    throughput = n()
  )

# Plot 1: Average Latency over time (per second)
plot_latency <- ggplot(logs_avg_latency, aes(x = timest, y = avg_latency)) +
  geom_line(color = "red") +
  geom_vline(xintercept = resize_timestamp, color = "gray", linetype = "dotdash", size = 1) +
  labs(title = "Latência média ao longo do tempo", x = "Tempo", y = "Latência média (µs)") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

# Plot 2: Throughput over time (requests per second)
plot_throughput <- ggplot(logs_throughput, aes(x = timest, y = throughput)) +
  geom_line(color = "blue") +
  geom_vline(xintercept = as.numeric(resize_timestamp), color = "gray", linetype = "dotdash", size = 1) +
  labs(title = "Vazão ao longo do tempo", x = "Tempo", y = "Vazão") +
  scale_x_datetime(date_labels = "%H:%M:%S", date_breaks = "30 sec") +
  theme_minimal()

ggsave("resources/r50/latency_plot.png", plot = plot_latency)
ggsave("resources/r50/throughput_plot.png", plot = plot_throughput)

print(plot_latency)
print(plot_throughput)
