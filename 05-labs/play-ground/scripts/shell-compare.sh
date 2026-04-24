#!/bin/bash

echo "Executing with: $0"
echo "Shell: $SHELL"
echo "Bash Version: ${BASH_VERSION:-Not Bash}"

if [ -n "$BASH_VERSION" ]; then
	arr=(apple banana cherry)
	echo "Arrays supported: ${arr[1]}"
else
	echo "Arrays not supported in this shell"
fi
