#!/bin/bash

echo "Current Directory: $(pwd)"
echo ""
echo "Contents:"
ls -lh
echo ""
echo "Disk Usage:"
du -sh .
echo ""
echo "Date and Time: $(date)"
echo ""echo "Uptime:"
uptime
echo """Memory Usage:"
free -h
echo "Recent Directories:"
dirs -v 2>/dev/null || echo "No recent directories."
echo ""
echo "Environment Variables:"
printenv | sort