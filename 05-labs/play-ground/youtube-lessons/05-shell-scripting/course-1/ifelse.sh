#! /bin/bash

echo "Enter File Name: "
read filename

if [ -e "$filename" ]; then
	echo "The '$filename' is available"
else 
	echo "The '$filename' is not available"
fi
