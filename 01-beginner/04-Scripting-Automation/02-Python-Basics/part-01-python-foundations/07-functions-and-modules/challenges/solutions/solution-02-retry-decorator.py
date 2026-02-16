"""
Solution: The "Chaos" Retry Decorator
"""
import time
import functools
import random

def retry(max_attempts=3, delay=1):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    print(f"⚠️ Attempt {attempt}/{max_attempts} failed: {e}")
                    if attempt < max_attempts:
                        time.sleep(delay)
            # If we get here, all retries exhausted
            print("❌ All retries exhausted.")
            raise last_exception
        return wrapper
    return decorator

# Usage Example
@retry(max_attempts=3, delay=1)
def connect_to_database():
    if random.random() < 0.7:
        raise ConnectionError("Database Connection Timeout")
    return "Connected!"

if __name__ == "__main__":
    try:
        print(connect_to_database())
    except ConnectionError:
        print("Failed to connect after retries.")
