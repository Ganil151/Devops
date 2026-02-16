"""
Challenge: Log Error Aggregator
Scenario: You have a large log file. You need to extract all ERROR messages 
and count how many times each unique error message appears.

TODO: Implement `summarize_errors(log_text)`.
1. Use `re.findall()` or `re.finditer()` to find lines starting with `ERROR`.
2. Extract the message following the word `ERROR:`.
3. Use `collections.Counter` to count the occurrences of each message.
4. Return the counter or a dictionary.
"""
import re
from collections import Counter

def summarize_errors(log_text):
    """
    Summarizes unique error messages and their counts.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    logs = """
    2026-01-13 10:00:00 ERROR: Connection timeout
    2026-01-13 10:00:05 INFO: Heartbeat
    2026-01-13 10:00:10 ERROR: Disk full
    2026-01-13 10:00:15 ERROR: Connection timeout
    2026-01-13 10:00:20 ERROR: Connection timeout
    """
    summary = summarize_errors(logs)
    print(f"Error Summary: {summary}")
