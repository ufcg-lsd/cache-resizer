#!/bin/bash

usage() {
  echo "Usage: $0 <qtd_clients> <iat> <execution_time>"
  exit 2
}

if [ $# -ne 3 ]; then
  usage
fi


qtd_clients=$1
iat=$2
execution_time=$3

if [ -z "$qtd_clients" ] || [ -z "$iat" ] || [ -z "$execution_time" ]; then
  usage
fi

# Run the docker-redis container
docker build --tag docker-redis ..
container_id=$(docker run -d -p 6380:6379 docker-redis)

if [ -z "$container_id" ]; then
  echo "Failed to start Docker container."
  exit 1
fi

# Load injection
python3 ../src/fill_redis.py 

# Requests 
go run ../src/client.go "$qtd_clients" "$iat" "$execution_time" &
sleep 3

# Resize
python3 ../src/resize.py

wait

# Stopping and removing the container
docker stop "$container_id"
docker rm "$container_id"