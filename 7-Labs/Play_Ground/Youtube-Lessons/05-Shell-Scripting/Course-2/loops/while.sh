#!/bin/bash

# Print number 1 - 9 

set -vx

count=1

while [ $count -le 100 ]
do 
	echo "count = $count"
	count=`expr $count + 5`
done

echo "-- EOS --"

