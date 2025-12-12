#!/bin/bash
echo "=== User Account Activity Monitoring ==="
echo "Enter username:"
read username


# Check user activity in system logs
echo "=== Recent Logins ==="
last | grep $username

# Check for changes to user's home directory 
echo "=== User Home Directory Changes ==="
auditctl -w /home/$username
