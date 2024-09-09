#!/bin/bash

init=$1
id=$1
max=$2

while true;
do
    if [ "$id" -gt "$max" ]; then
        id=$init
    fi
    start_time=$(($(date +%s%N)/1000))
    response=$(curl -s localhost:8100/persons/$id)
    end_time=$(($(date +%s%N)/1000))
    totalTime=$((end_time - start_time))
    result="Id=$id,start=$start_time,end=$end_time,totalTime=$totalTime,response=$response"
    echo "$result" >> ./logs.txt
    echo "$result"
    id=$((id+1))
done