# 🎯 Challenges: Observability Fundamentals

## 🟢 Challenge 1: The Status 200 Hunt
**Objective**: Write a one-liner command using `curl` and `grep` to check if `google.com` is up and print only the HTTP status code.
**Hint**: `curl -Is google.com | head -n 1`

## 🟡 Challenge 2: Resource Watchdog
**Objective**: Create a script that checks if the disk usage of the root directory (`/`) is above 80%. If it is, append a warning message with a timestamp to `/tmp/disk_warnings.log`.
**Hint**: Use `df -h` and `awk`.

## 🔴 Challenge 3: Log Pattern Matcher
**Objective**: Given a log file `app.log`, find all occurrences of "ERROR" that happened between 10:00 AM and 11:00 AM.
**Hint**: Use `grep` with a timestamp pattern.
