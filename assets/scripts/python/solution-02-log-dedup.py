"""
Solution: Log Deduplication
"""
from collections import Counter

log_entries = [
    {"ip": "10.0.0.1", "method": "GET", "path": "/api/health"},
    {"ip": "10.0.0.2", "method": "POST", "path": "/api/data"},
    {"ip": "10.0.0.1", "method": "GET", "path": "/api/health"},
    {"ip": "10.0.0.3", "method": "GET", "path": "/api/users"},
    {"ip": "10.0.0.2", "method": "POST", "path": "/api/data"},
]

# 1. Unique IPs
unique_ips = set(entry["ip"] for entry in log_entries)
print(f"Unique IPs: {unique_ips}")

# 2. Count per IP
ip_counts = Counter(entry["ip"] for entry in log_entries)
print(f"Requests per IP: {dict(ip_counts)}")

# 3. POST requests
post_ips = {entry["ip"] for entry in log_entries if entry["method"] == "POST"}
print(f"IPs making POST: {post_ips}")
