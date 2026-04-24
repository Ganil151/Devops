#!/bin/bash

echo "Enter Your Password"
read password
length=${#password}

if [ $length -lt 8 ]; then
	echo "Your Password is to Weak - Lesssthan 8 chars"
elif [ $length -ge 8 ] && [ $length -lt 12 ]; then
	echo "Your Password is moderate - Between 8-12 chars"
else 
	echo "Your Password is Strong - Morethan 12 chars"
fi
