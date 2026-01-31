# ☁️ Reference: Cloud & Networking Keywords

Python is the primary language for Cloud-Native engineering. This reference covers the keywords used for interacting with APIs and Cloud SDKs.

---

## 🚀 API Mastery (Requests)

### `requests.Session()`
*   **Definition**: A persistent object that stores cookies and keeps the TCP connection open for multiple requests (Keep-Alive).
*   **DevOps Why**: Significantly improves performance when making hundreds of API calls to a provider like GitHub or Jira.

### `Response.raise_for_status()`
*   **Definition**: Raises an `HTTPError` if the response code is 4xx or 5xx.
*   **DevOps Why**: Ensures your script doesn't continue processing if the API call failed (e.g., Auth error or Timeout).

---

## 🏛️ Cloud SDK (Boto3)

### `boto3.Session()`
*   **Definition**: The entry point for AWS SDK. It manages credentials and configuration.

### `Client` vs `Resource`
*   **Client**: Low-level, 1-to-1 mapping with the AWS API. Returns dictionaries. (Recommended for large-scale enterprise automation).
*   **Resource**: High-level, object-oriented abstraction. Easier to use for simple tasks but doesn't cover all AWS features.

### `Paginators`
*   **Definition**: Handles APIs that return data in multiple "pages" (e.g., `list_objects` in S3).
*   **DevOps Why**: Mandatory for enterprise scale. If you have 10,000 S3 buckets, a standard API call only returns the first 1,000. Paginators automate the loop to get all results.

### `Waiters`
*   **Definition**: Polling logic that pauses the script until a resource reaches a certain state (e.g., `instance_running`).
*   **DevOps Why**: Replaces messy `while True: sleep(5)` loops with professional, optimized polling.

---

## 🎙️ Staff Interview context
*   **"Explain the difference between a Boto3 Client and a Resource."**
    *   *Answer*: A Client is a low-level service representation that maps directly to the API, making it more comprehensive and faster. A Resource is a high-level, thread-safe abstraction that is more "Pythonic" but less optimized for large-scale data processing.
*   **"How do you ensure an API script handles transient network failures?"**
    *   *Answer*: Use the `HTTPAdapter` with `Retry` logic from the `urllib3` library, integrated into a `requests.Session()`.
