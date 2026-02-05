#!/bin/bash

################################
# Author: Ganil
#
# Functions & Conditionals
#
################################

echo "Enter the numbers"
read num1
read num2

if [ $num1 == $num2 ]; then
	echo "$num1 is equal to $num2"
elif [ $num1 > $num2 ]; then
	echo "$num1 is greater than $num2"
else
	echo "$num1 is less than $num2"
fi
