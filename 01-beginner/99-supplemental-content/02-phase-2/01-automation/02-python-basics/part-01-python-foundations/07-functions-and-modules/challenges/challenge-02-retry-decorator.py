"""
Challenge: The "Chaos" Retry Decorator
Scenario: Create a @retry decorator to handle flaky API calls.

TODO:
1. Create a `@retry` decorator that accepts `max_attempts` and `delay`.
2. It must catch exceptions, log a warning, wait, and try again.
3. It must raise the exception if all attempts fail.
4. Use `functools.wraps` to preserve function metadata.
"""
import time
import functools
import random

# --- START YOUR CODE HERE ---

# --- END YOUR CODE HERE ---

# Usage Example to test
@retry(max_attempts=3, delay=1)
def connect_to_database():
    # Simulate a flaky connection that fails 70% of the time
    if random.random() < 0.7:
        raise ConnectionError("Database Connection Timeout")
    return "Connected!"

if __name__ == "__main__":
    try:
        print(connect_to_database())
    except ConnectionError:
        print("Failed to connect after retries.")
