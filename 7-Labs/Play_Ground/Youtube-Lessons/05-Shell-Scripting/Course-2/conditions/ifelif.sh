#!/bin/bash

var1=5116861564
var2=1655564184

if [[ $var1 -gt $var2 ]]; then
	echo "var1 is greater than var2"
elif [[ $var1 -lt $var2 ]]; then
	echo "var1 is lesser than var2"
else
	echo "var1 is equal to var2"
fi
