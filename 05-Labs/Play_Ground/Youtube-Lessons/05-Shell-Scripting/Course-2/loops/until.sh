#!/bin/bash

a=10

until [ $a -lt 10 ]
do 
	echo "a=$a"
	a=`expr $a + 2`
done
