"""
Challenge: Adaptive Retry Session
Scenario: A legacy API you use is flaky and often returns 503 errors. 
Instead of manual retries, you want to use a `requests.Session` 
that handles retries automatically with exponential backoff.

TODO: Implement `get_retry_session(retries=3)`.
1. Use `urllib3.util.retry.Retry`.
2. Configure it to retry on status codes: 502, 503, 504.
3. Set a `backoff_factor`.
4. Create a `requests.Session` and mount an `HTTPAdapter` with the retry strategy.
5. Return the session object.
"""
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def get_retry_session(retries=3):
    """
    Creates a requests Session with automatic retry logic.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    session = get_retry_session(retries=5)
    # This URL simulates a 503 error for testing retries
    try:
        print("Attempting connection to flaky service...")
        response = session.get("https://httpbin.org/status/503", timeout=2)
        print(f"Final status: {response.status_code}")
    except Exception as e:
        print(f"Request failed after retries: {e}")
