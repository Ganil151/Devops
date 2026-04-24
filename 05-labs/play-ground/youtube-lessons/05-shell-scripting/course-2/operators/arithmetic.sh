#!/bin/bash

########################################
# Author: Ganil
#
# Arithmetic Operators
#
# Link: 
#
########################################

var1=30
var2=20

echo "var1=$var1 var2=$var2 \n"

add=`expr $var1 + $var2`
echo "var1 + var2 : $add"

sub=`expr $var1 - $var2`
echo "var1 - var2 : $sub"

# negate * with \
mul=`expr $var1 * $var2`
echo "var1 * var2 : $mul"

div=`expr $var2 / $var1`
echo "var2 / var1 : $div"

mod=`expr $var2 % $var1`
echo "var2 % var1 : $mod"

