"""
Lab 1: Log Level Filter
-----------------------
Scenario: You are building a CLI tool that filters system logs based on severity.

Goal:
1. Capture user input for the log level.
2. Use conditionals to print a specific message for DEBUG, INFO, and ERROR.
3. Handle unknown levels gracefully.
"""
import sys

# 1. Get user input (Hint: Use .strip().upper() to make it robust)
level = input("Enter log level to view (DEBUG, INFO, ERROR): ").strip().upper()

# 2. Implement logic using if/elif/else structure (or match-case)
if level == "DEBUG":
    print("[DEBUG] Database connection pool initialized with 10 connections.")

elif level == "INFO":
    print("[INFO] System update completed in 2.4s.")

elif level == "ERROR":
    print("[ERROR] Permission denied: Cannot write to /var/log/syslog.")

else:
    print(f"Unknown Log Level: {level}")
