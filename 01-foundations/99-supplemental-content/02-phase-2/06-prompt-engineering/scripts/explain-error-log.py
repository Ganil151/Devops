"""
Error Log Explainer
Description: Simple pattern matching for error logs.
"""

import re
import sys

PATTERNS = {
    r"Connection refused": "Service is down or firewall blocking port.",
    r"Timeout": "Service taking too long, network delay, or overloaded.",
    r"404 Not Found": "Check URL path and routing.",
    r"500 Internal Server Error": "Check application logs for exceptions.",
    r"disk full": "Clear space in /var/log or /tmp.",
    r"Out of memory": "Increase RAM or fix memory leak."
}

def explain(log_line):
    found = False
    for pattern, explanation in PATTERNS.items():
        if re.search(pattern, log_line, re.IGNORECASE):
            print(f"[Analysis] {explanation}")
            found = True
            
    if not found:
        print("[Analysis] No specific pattern matched. Check traceback.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python explain-error-log.py '<log_line>'")
    else:
        explain(sys.argv[1])
