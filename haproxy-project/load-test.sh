#!/bin/bash

init=$1
id=$1
max=$2

while true;
do
    if [ "$id" -gt "$max" ]; then
        id=$init
    fi
    start_time=$(date +%s%N)
    start_date=$(date +"%Y-%m-%d %H:%M:%S.%6N")
    response=$(curl -s localhost:8100/persons/$id)
    end_time=$(date +%s%N)
    totalTime=$(((end_time - start_time) / 1000))
    result="Id=$id,start_date=$start_date,totalTime=$totalTime,response=$response"
    echo "$result" >> ./logs.txt
    echo "$result"
    id=$((id+1))
done