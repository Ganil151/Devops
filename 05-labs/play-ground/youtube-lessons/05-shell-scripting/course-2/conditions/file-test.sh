#!/bin/bash

file="/mnt/c/Users/Ganil/Documents/Devops/Labs/Play_Ground/Youtube-Lessons/05-Shell-Scripting/Course-2/conditions/random.txt"

if [[ -r $file ]]
then 
	echo "File has read access"
else
	echo "File does not have read access"
fi

if [[ -w $file ]]
then
        echo "File has write permission"
else
        echo "File does not have write permission"
fi

if [[ -r $file ]]
then
        echo "File has excute permission"
else
        echo "File does not have excute permission"
fi

if [[ -d $file ]]
then
        echo "File is a directory"
else
        echo "This  is not a directory"
fi

if [[ -s $file ]]
then
        echo "File is not zero"
else
        echo "File is zero"
fi

if [[ -e $file ]]
then
        echo "File exists"
else
        echo "File does not exists"
fi
