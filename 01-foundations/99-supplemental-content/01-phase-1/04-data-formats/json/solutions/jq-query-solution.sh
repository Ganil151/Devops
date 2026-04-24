#!/bin/bash
# 🛠️ JQ Query Solution for log parsing challenge

# 1. Pretty-print the raw logs
cat raw_logs.json | jq '.'

# 2. Filter for errors and map fields to new keys
# Command Explanation:
# .[] - Iterate over the array
# select(.level == "error") - Filter objects matching the condition
# {time: .timestamp, error: .msg} - Create new objects with renamed keys
cat raw_logs.json | jq '.[] | select(.level == "error") | {time: .timestamp, error: .msg}'
