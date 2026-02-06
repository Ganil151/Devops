#!/usr/bin/env python3
"""
Name: log_parser.py
Description: Regex-based parsing of Apache/Nginx logs.
"""

import re
from collections import Counter
import logging

# Sample Log Line:
# 127.0.0.1 - - [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326

# Regex Pattern Breakdown:
# (\S+)     -> IP Address (Group 1)
# .*?       -> Skip user/auth
# \[(.*?)\] -> Timestamp (Group 2)
# ".*?"     -> Request
# (\d{3})   -> Status Code (Group 3)
LOG_PATTERN = re.compile(r'(\S+) .*? \[(.*?)\] ".*?" (\d{3})')

def parse_logs(log_data):
    ip_counter = Counter()
    status_counter = Counter()
    
    for line in log_data.strip().split('\n'):
        match = LOG_PATTERN.search(line)
        if match:
            ip = match.group(1)
            status = match.group(3)
            
            ip_counter[ip] += 1
            status_counter[status] += 1
            
    return ip_counter, status_counter

if __name__ == "__main__":
    dummy_logs = """
192.168.1.1 - - [01/Jan/2024:10:00:00] "GET / HTTP/1.1" 200 500
192.168.1.2 - - [01/Jan/2024:10:00:01] "GET /admin HTTP/1.1" 403 200
192.168.1.1 - - [01/Jan/2024:10:00:05] "POST /login HTTP/1.1" 200 100
10.0.0.1 - - [01/Jan/2024:10:00:10] "GET /missing HTTP/1.1" 404 150
    """
    
    ips, statuses = parse_logs(dummy_logs)
    
    print("--- Top IPs ---")
    for ip, count in ips.most_common(5):
        print(f"{ip}: {count}")
        
    print("\n--- Status Codes ---")
    for code, count in statuses.items():
        print(f"{code}: {count}")
