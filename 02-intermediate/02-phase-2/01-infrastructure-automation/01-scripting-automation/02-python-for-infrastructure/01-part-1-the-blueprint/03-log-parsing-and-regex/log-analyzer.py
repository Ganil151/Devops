#!/usr/bin/env python3
"""
Topic: Log Parsing and Regex
Description: High-performance log analysis using pre-compiled regex.
"""

import re
from typing import List, Dict

# 🚀 Standard: Pre-compile regex for performance
LOG_PATTERN = re.compile(
    r'(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[.*\] '
    r'"(?P<method>GET|POST|PUT|DELETE) (?P<url>.*) HTTP/.*" '
    r'(?P<status>\d{3})'
)

def analyze_logs(log_lines: List[str]) -> List[Dict[str, str]]:
    results = []
    
    for line in log_lines:
        match = LOG_PATTERN.search(line)
        if match:
            # Extract named groups into a dictionary
            results.append(match.groupdict())
            
    return results

if __name__ == "__main__":
    sample_logs = [
        '192.168.1.1 - - [30/Jan/2026:10:00:01] "GET /api/v1/health HTTP/1.1" 200',
        '10.0.0.5 - - [30/Jan/2026:10:05:22] "POST /api/v1/login HTTP/1.1" 401',
        'INVALID LINE WITHOUT LOG FORMAT'
    ]
    
    hits = analyze_logs(sample_logs)
    print(f"🔍 Analyzed {len(sample_logs)} lines. Found {len(hits)} valid entries.")
    
    for hit in hits:
        print(f"  - [{hit['status']}] {hit['method']} | {hit['url']} from {hit['ip']}")
