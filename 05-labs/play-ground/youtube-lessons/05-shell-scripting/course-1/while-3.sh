#!/bin/bash

# Countdown Loop File

counter=10
while [ $counter -ge 1 ]; do 
	echo "Countdown: $counter"
	counter=$((counter - 1 ))
	sleep 2
done 
echo "Bomb Explodes...!!!!"
