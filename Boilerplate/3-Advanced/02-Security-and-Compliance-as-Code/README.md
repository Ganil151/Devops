# Production Scenario: Security Anomaly Detector (MLOps)

## Overview
This Python boilerplate implements a high-performance **Security Log Analyzer** that utilizes `asyncio` for non-blocking I/O and `pandas` for advanced statistical analysis. It is designed to be integrated into CI/CD pipelines or run as a sidecar in Kubernetes.

### Real-World Use Case
In a high-scale microservices architecture, log streams can reach millions of lines per hour. A traditional script-based approach would be overwhelmed. This implementation:
1.  **Batch Processing**: Leverages `pandas` vectorization for extremely fast anomaly detection using Z-Scores.
2.  **Asynchronous Alerting**: Uses `aiohttp` to ensure that sending an alert to Slack doesn't block the next cycle of analysis.
3.  **Secret Masking**: Implements a custom `logging.Filter` to ensure that sensitive information (tokens, passwords) never reaches the stdout or external log aggregators.

## "What happens if the API rate limit is reached?"
The script handles Slack/PagerDuty rate limits through its asynchronous nature and error handling:
-   **Backpressure**: If the Slack API starts failing, the `send_alert` function captures the failure and triggers a "Critical Fallback" log.
-   **Circuit Breaker Logic**: In a production extension, one would add a stateful circuit breaker to stop attempting calls to a failing endpoint, instead buffering the alerts to a persistent queue (like Redis or SQS).
-   **Resource Management**: The `ClientSession` is managed using an asynchronous context manager to ensure sockets are cleaned up correctly even during crashes.

## Key Features
-   **Asyncio Integration**: Handles multiple log sources concurrently.
-   **Z-Score Detection**: Baseline statistical anomaly detection for request spikes.
-   **Non-Root Execution**: Designed to run under least-privilege principles (UID 1000).
