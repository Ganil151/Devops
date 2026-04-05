"""
Solution: Log Error Aggregator
"""
import re
from collections import Counter

def summarize_errors(log_text):
    """Counts occurrences of unique error messages."""
    # Pattern: match ERROR: followed by the rest of the line
    pattern = r'ERROR: (.+)'
    
    errors = re.findall(pattern, log_text)
    return dict(Counter(errors))

if __name__ == "__main__":
    logs = """
    ERROR: Database down
    INFO: Retry
    ERROR: Database down
    ERROR: Auth failed
    """
    print(summarize_errors(logs))
