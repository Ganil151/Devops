#!/bin/bash

User=$(whoami)
Hostname=$(hostname)
Shell=$BASH_VERSION
Current_Directory="$pwd" 
Date_and_Time=$(date)
OS=$(uname -a)
Uptime=$(uptime -p)

echo "The current user is: $User"
echo "The hostname is: $Hostname"
echo "The current shell is: $Shell"
echo "The current directory is: $Current_Directory"
echo "The current date and time is: $Date_and_Time"
echo "The operating system details are: $OS"
echo "The system uptime is: $Uptime"