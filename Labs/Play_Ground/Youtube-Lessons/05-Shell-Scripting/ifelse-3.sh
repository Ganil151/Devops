#!/bin/bash

# Day of the week
#
echo "Enter a number (1-7) for the day of a week:"
read day 

if [ "$day" -eq 1 ]; then
	echo "Sunday"
elif [ "$day" -eq 2 ]; then
	echo "Monday"
elif [ "$day" -eq 3 ]; then
        echo "Tuesday"
elif [ "$day" -eq 4 ]; then
        echo "Wendsday"
elif [ "$day" -eq 5 ]; then
        echo "Thursday"
elif [ "$day" -eq 6 ]; then
        echo "Friday"
elif [ "$day" -eq 7 ]; then
        echo "Saturday"
else
	echo "Invalid number"
fi
