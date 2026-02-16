"""
Challenge: Log Timestamp Parser
Scenario: You are parsing logs from different systems. One uses Apache format 
and the other uses ISO format. You need to convert both to a unified Unix timestamp.

TODO: Implement `parse_to_timestamp(log_line, log_type)`.
1. If `log_type == 'apache'`, use `strptime` with format: `%d/%b/%Y:%H:%M:%S %z`.
2. If `log_type == 'iso'`, use `datetime.fromisoformat()`.
3. Handle potential `ValueError` if the format is malformed.
4. Return the Unix timestamp (float) using `.timestamp()`.
"""
from datetime import datetime

def parse_to_timestamp(log_line, log_type):
    """
    Parses a log line timestamp and returns a Unix timestamp.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    apache_log = "12/Jan/2026:17:30:00 +0000"
    iso_log = "2026-01-12T17:30:05.123+00:00"
    
    print(f"Apache TS: {parse_to_timestamp(apache_log, 'apache')}")
    print(f"ISO TS:    {parse_to_timestamp(iso_log, 'iso')}")
