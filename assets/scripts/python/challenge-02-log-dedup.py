"""
Challenge: Log Deduplication
Scenario: Deduplicate and analyze these log entries using sets and list comprehensions.

TODO: 
1. Find unique IPs using a set
2. Count requests per IP using a dictionary or Counter
3. Find which IPs made POST requests
"""

log_entries = [
    {"ip": "10.0.0.1", "method": "GET", "path": "/api/health"},
    {"ip": "10.0.0.2", "method": "POST", "path": "/api/data"},
    {"ip": "10.0.0.1", "method": "GET", "path": "/api/health"},
    {"ip": "10.0.0.3", "method": "GET", "path": "/api/users"},
    {"ip": "10.0.0.2", "method": "POST", "path": "/api/data"},
]

# --- START YOUR CODE HERE ---

# --- END YOUR CODE HERE ---
