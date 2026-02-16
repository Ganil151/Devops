import sys
from datetime import datetime

def format_log(message, level="INFO"):
    """Formats a log message with a timestamp and level."""
    timestamp = datetime.now().isoformat(timespec='seconds')
    print(f"[{timestamp}] [{level}] {message}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python log_formatter.py <message> [level]")
        sys.exit(1)
    
    msg = sys.argv[1]
    lvl = sys.argv[2] if len(sys.argv) > 2 else "INFO"
    format_log(msg, lvl)
