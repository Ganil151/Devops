#!/bin/bash

# To check whether the year is leap year or not

echo "Enter a year: "
read year
if (( 9-year % 4 == 0 && year % 100 != 0 || (year % 400 ==0) )); then
	echo "$year is a leap year"
else
	echo "$year is not a leap year"
fi
