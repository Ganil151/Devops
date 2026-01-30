"""
Challenge: Health Check with Retries
Scenario: Build a service checker that doesn't give up on the first failure.

TODO: Implement `check_service_health(url, timeout=5)` function:
1. Check if an HTTP endpoint is reachable using `requests.get`.
2. Retry up to 3 times with a 2-second delay between attempts if it fails.
3. Return a dictionary containing health status, response time, and attempt count.
4. Handle Timeout and ConnectionError specifically.
"""

import requests
import time


def check_service_health(url, timeout=5, max_attempts=3, delay=2):
    """Check service health with automatic retries."""
    for attempt in range(1, max_attempts + 1):
        try:
            start_time = time.time()
            response = requests.get(url, timeout=timeout)
            response_time = time.time() - start_time

            if response.status_code == 200:
                return {
                    "status": "UP",
                    "response_time": response_time,
                    "attempts": attempt,
                }

        except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
            # Continue to retry logic on specific errors
            pass

        if attempt < max_attempts:
            time.sleep(delay)

    return {"status": "DOWN", "response_time": None, "attempts": max_attempts}


# Test your code
if __name__ == "__main__":
    # Test with a reliable endpoint
    health = check_service_health("https://httpbin.org/get")
    print(f"Health Check (Healthy): {health}")

    # Test with a failing endpoint (simulated)
    health = check_service_health("https://httpbin.org/status/500")
    print(f"Health Check (Failing): {health}")
