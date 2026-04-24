"""
Challenge: Nginx IP Counter
Scenario: You have an Nginx access log. You need to identify the most 
active users by counting their IP addresses.

TODO: Implement `count_ips(log_file)`.
1. Open the file line-by-line.
2. Use Regex `^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})` to extract the IP.
3. Store counts in a dictionary: `{ "1.2.3.4": 5 }`.
4. Sort the dictionary by value and return the Top 5.
"""
import re
from collections import Counter

def count_ips(log_file):
    """
    Returns the top 5 most frequent IPs in the log.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Mock log data
    with open("access.log", "w") as f:
        f.write("192.168.1.1 - - [13/Jan...] \"GET /...\"\n")
        f.write("192.168.1.5 - - [13/Jan...] \"GET /...\"\n")
        f.write("192.168.1.1 - - [13/Jan...] \"POST /...\"\n")

    top_ips = count_ips("access.log")
    print(f"Top IPs: {top_ips}")
