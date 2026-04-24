#!/bin/bash
# A simple script to monitor if a port is open
HOST=$1
PORT=$2

if nc -z -w 2 $HOST $PORT; then
    echo "Port $PORT on $HOST is OPEN"
else
    echo "Port $PORT on $HOST is CLOSED"
    exit 1
fi
