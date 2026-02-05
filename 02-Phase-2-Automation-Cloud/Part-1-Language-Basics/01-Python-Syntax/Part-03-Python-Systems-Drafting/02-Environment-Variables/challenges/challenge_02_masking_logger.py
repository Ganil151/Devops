"""
Challenge: Secret Masking Logger
Scenario: For security auditing, you need to log all environment variables, 
but you must never leak actual passwords, keys, or tokens in the logs.

TODO: Implement `log_env_safely()` function.
1. Iterate through all items in `os.environ`.
2. Check if the key contains sensitive words like "PASSWORD", "SECRET", "KEY", "TOKEN".
3. If it is sensitive, mask the value (e.g., show only the first/last 2 chars and stars in between).
4. If it's not sensitive, print the key and value normally.
"""
import os

SENSITIVE_KEYWORDS = {"PASSWORD", "SECRET", "KEY", "TOKEN"}

def log_env_safely():
    """
    Prints environment variables with sensitive values masked.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Simulate some environment vars
    os.environ["APP_PORT"] = "8080"
    os.environ["DB_PASSWORD"] = "extremely-secret-pass-123"
    os.environ["AUTH_TOKEN"] = "abc123secrettoken456"
    
    log_env_safely()
