"""
Challenge: Sensitive Data Masker
Scenario: You need to sanitize log files by masking sensitive information 
like passwords in URLs and full IP addresses.

TODO: Implement `sanitize_logs(text)`.
1. Use `re.sub()` to mask password parameters in strings like `user:password@host`.
   - Replace the password with `****`.
2. Use `re.sub()` to mask the last two octets of IPv4 addresses.
   - Example: `192.168.1.100` -> `192.168.x.x`.
3. Return the sanitized text.
"""
import re

def sanitize_logs(text):
    """
    Masks passwords and IP addresses in logs.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    raw_log = "Connected to postgres://admin:secret123@db.internal:5432 from 10.0.0.55"
    print(f"Original:  {raw_log}")
    print(f"Sanitized: {sanitize_logs(raw_log)}")
