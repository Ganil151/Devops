"""
Solution: Nginx IP Counter
"""
import re
from collections import Counter

def count_ips(log_file):
    ip_counter = Counter()
    # Pattern for IP at start of line
    pattern = re.compile(r"^(\d{1,3}(?:\.\d{1,3}){3})")

    try:
        with open(log_file, "r") as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    ip = match.group(1)
                    ip_counter[ip] += 1
    except FileNotFoundError:
        print("Log file not found.")
        
    return ip_counter.most_common(5)

if __name__ == "__main__":
    pass
