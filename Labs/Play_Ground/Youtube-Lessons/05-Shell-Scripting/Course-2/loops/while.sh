#!/bin/bash

# Print number 1 - 9 

count=1

while [ $count -le 9 ]
do 
	echo "count = $count"
	count=`expr $count + 1`
done

echo "-- EOS --"

