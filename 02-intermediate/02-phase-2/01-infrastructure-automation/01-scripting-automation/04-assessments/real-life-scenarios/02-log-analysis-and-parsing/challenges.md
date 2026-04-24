# 🛠️ Log Analysis Challenges

## Challenge 1: The Hourly Report
**Objective**: Count hits per hour.
1.  Logs have timestamp format: `[15/Jan/2024:14:05:01 +0000]`.
2.  Use `cut` or `awk` to extract just the hour (`14`).
3.  Count occurrences per hour for the whole day.

## Challenge 2: Slow Request Finder
**Objective**: Filter by response time.
1.  Assuming the last column in your log is "response time" in milliseconds.
2.  Find all lines where response time > 500ms.
3.  Print the URL and the Time.

## Challenge 3: Bot Hunter
**Objective**: User-Agent analysis.
1.  The User-Agent is usually the last quoted string in a log.
2.  Find all lines that mention "Googlebot" or "AdsBot".
3.  Count how many times they hit your site today.
