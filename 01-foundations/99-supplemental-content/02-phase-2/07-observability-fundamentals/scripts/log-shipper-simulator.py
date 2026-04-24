"""
Log Shipper Simulator
Description: Simulates sending logs to an HTTP endpoint (like Logstash/Splunk)
"""

import time
import requests
import json
import random

API_ENDPOINT = "http://localhost:8000/logs" # Change me in real use

def generate_log():
    levels = ["INFO", "WARN", "ERROR"]
    messages = ["User logged in", "Database slow", "Payment failed", "Cache miss"]
    
    return {
        "timestamp": time.time(),
        "level": random.choice(levels),
        "service": "checkout-service",
        "message": random.choice(messages)
    }

def ship_logs(count=5):
    print(f"Shipping {count} logs to {API_ENDPOINT} (Dry Run)...")
    
    for i in range(count):
        log_entry = generate_log()
        print(f"Sending: {json.dumps(log_entry)}")
        
        # Real implementation would be:
        # requests.post(API_ENDPOINT, json=log_entry)
        
        time.sleep(0.5)

if __name__ == "__main__":
    ship_logs()
