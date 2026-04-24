#!/bin/bash

a=20
b=30

# Single brackets [] use -a (and) -o (or)
# double brackets [[]] user && (and) -o (or)

if [[ $a -lt 100 && $b -gt 15 ]]
then
	echo "$a -lt 100 && $b -gt 15: return true"
else
	echo "$a -lt 100 && $b -gt 15: return false"
fi

if [[ $a -lt 100 && $b -gt 35 ]]
then
        echo "$a -lt 100 && $b -gt 35: return true"
else
        echo "$a -lt 100 && $b -gt 35: return false"
fi

if [[ $a -lt 100 || $b -gt 100 ]]
then
        echo "$a -lt 100 || $b -gt 100: return true"
else
        echo "$a -lt 100 || $b -gt 100: return false"
fi

if [[ $a -lt 5 || $b -gt 100 ]]
then
        echo "$a -lt 5 || $b -gt 100: return true"
else
        echo "$a -lt 5 || $b -gt 100: return false"
fi
