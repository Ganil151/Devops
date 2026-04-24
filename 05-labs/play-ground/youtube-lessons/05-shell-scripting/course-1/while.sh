#!/bin/bash

# Ash for a password until the correct password is entered

password="secret"
user_input=""

while [ "$user_input" != "$password" ]
do
	echo "Enter Correct Password:"
	read user_input
done
