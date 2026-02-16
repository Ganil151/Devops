"""
Solution: Log Timestamp Parser
"""
from datetime import datetime

def parse_to_timestamp(log_line, log_type):
    """Parses various log timestamps into Unix epoch."""
    try:
        if log_type == 'apache':
            # Example: 12/Jan/2026:17:30:00 +0000
            dt = datetime.strptime(log_line, "%d/%b/%Y:%H:%M:%S %z")
        elif log_type == 'iso':
            # Example: 2026-01-12T17:30:05.123+00:00
            dt = datetime.fromisoformat(log_line)
        else:
            return None
        
        return dt.timestamp()
    except ValueError:
        return None

if __name__ == "__main__":
    print(parse_to_timestamp("13/Jan/2026:10:00:00 +0000", "apache"))
