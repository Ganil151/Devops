#!/bin/bash
# -----------------------------------------------------------------------------
# Name: analyze_logs.sh
# Description: A Swiss-army knife for log analysis in the CLI.
# -----------------------------------------------------------------------------

FILE="${1:-access.log}"

if [[ ! -f "$FILE" ]]; then
    echo "ERROR: File $FILE not found."
    exit 1
fi

echo "--- Top 10 IP Addresses ---"
awk '{print $1}' "$FILE" | sort | uniq -c | sort -nr | head -n 10

echo -e "\n--- Top 5 Requested Pages ---"
awk '{print $7}' "$FILE" | sort | uniq -c | sort -nr | head -n 5

echo -e "\n--- Status Code Distribution ---"
awk '{print $9}' "$FILE" | sort | uniq -c | sort -nr

echo -e "\n--- Error occurrences (4xx/5xx) ---"
grep -E " 4[0-9]{2} | 5[0-9]{2} " "$FILE" | wc -l
