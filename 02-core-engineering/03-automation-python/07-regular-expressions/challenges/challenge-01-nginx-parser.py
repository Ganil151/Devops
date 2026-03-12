"""
Challenge: NGINX Log Parser
Scenario: You need to parse an NGINX access log line and extract key fields 
into a dictionary for monitoring.

Log Format Example:
10.0.0.1 - - [12/Jan/2026:10:30:45 +0000] "GET /api/health HTTP/1.1" 200 1234

TODO: Implement `parse_nginx_log(log_line)`.
1. Use `re.match()` with a pattern.
2. Use named groups `(?P<name>...)` for:
   - `ip`: The client IP address.
   - `timestamp`: The content inside `[]`.
   - `method`: GET, POST, etc.
   - `path`: The requested URL path.
   - `status`: The HTTP status code (integer).
   - `size`: The response size (integer).
3. Return the `groupdict()` if matched, else `None`.
"""
import re

def parse_nginx_log(log_line):
    """
    Parses a single NGINX access log line.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    sample = '192.168.1.100 - - [13/Jan/2026:12:00:00 +0000] "POST /login HTTP/1.1" 401 567'
    result = parse_nginx_log(sample)
    if result:
        print(f"Parsed Log: {result}")
    else:
        print("Failed to parse log.")
