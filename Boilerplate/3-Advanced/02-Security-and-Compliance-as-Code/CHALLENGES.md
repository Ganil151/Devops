# Advanced Challenges: Security & Compliance

### Challenge 1: The 10k Concurrent Log Stream
**Scenario**: Refactor the `fetch_logs` method to handle a stream of 10,000 log entries per second from an S3 bucket using `smart_open` or direct `boto3` streaming.
-   **Requirement**: Process logs in chunks of 1,000 to keep memory consumption below 500MB while using `pandas`.
-   **Metric**: Total processing time for 1 million logs should be under 30 seconds.

### Challenge 2: Multi-Dimensional Anomaly Detection
**Scenario**: The current Z-Score only checks `request_count`. 
-   **Requirement**: Update the detection logic to include `latency` and `error_rate`. An anomaly should only be triggered if at least two dimensions exceed their threshold simultaneously.

### Challenge 3: Slack Rate Limit Protection
**Scenario**: Slack has a tier-based rate limit. 
-   **Requirement**: Implement a `Token Bucket` algorithm to ensure the `send_alert` function never exceeds 1 request per second globally across all instances of the script.
