"""
Solution: Secret Masking Logger
"""
import os

SENSITIVE_KEYWORDS = {"PASSWORD", "SECRET", "KEY", "TOKEN"}

def log_env_safely():
    """Logs environment variables while masking sensitive values."""
    for key, value in os.environ.items():
        # Check if any sensitive keyword is in the key name (case-insensitive)
        is_sensitive = any(word in key.upper() for word in SENSITIVE_KEYWORDS)
        
        if is_sensitive:
            # Mask the value: show start and end if long enough
            if len(value) > 4:
                masked = value[:2] + "*" * (len(value) - 4) + value[-2:]
            else:
                masked = "****"
            print(f"{key}: {masked}")
        else:
            print(f"{key}: {value}")

if __name__ == "__main__":
    os.environ["DB_PASSWORD"] = "my-secret-123"
    os.environ["APP_ENV"] = "production"
    log_env_safely()
