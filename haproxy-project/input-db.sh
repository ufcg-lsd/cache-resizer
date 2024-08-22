#!/bin/bash

id=1
max=15

while  [ $id -lt $max ]
do
    curl -X POST --location localhost:8100/persons/random/500
    id=$((id+1))
done