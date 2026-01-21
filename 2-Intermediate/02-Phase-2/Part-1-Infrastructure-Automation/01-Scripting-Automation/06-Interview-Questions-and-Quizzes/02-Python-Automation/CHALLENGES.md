# 🛠️ Python Interview Tasks

## Challenge 1: The S3 Auditor
**Objective**: Use Boto3.
1.  List all S3 buckets.
2.  Print only those that do NOT have "Public Access Block" enabled.
3.  Format the output as a table.

## Challenge 2: Log Aggregator
**Objective**: Data processing.
1.  Read a massive log file (1GB+).
2.  Find the Top 10 IP addresses that appear most frequently.
3.  Use the `collections.Counter` object.

## Challenge 3: API Client with Retries
**Objective**: Reliability.
1.  Build a function that calls an API.
2.  If it returns a 5xx error, retry up to 3 times with exponential backoff.
3.  Use `time.sleep()`.
