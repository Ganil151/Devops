"""
API Endpoint Tester
Description: Validates Status, Headers, Body, and Latency of an API endpoint.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
Requirement: requests
"""

import requests
import argparse
import time
import json

def test_api(url, method="GET", data=None):
    print(f"Testing {method} {url}...")
    
    start_time = time.time()
    try:
        if method == "GET":
            response = requests.get(url, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=10)
        
        latency = (time.time() - start_time) * 1000
        
        print(f"Status Code: {response.status_code}")
        print(f"Latency: {latency:.2f} ms")
        print("Headers:")
        for k, v in response.headers.items():
            print(f"  {k}: {v}")
            
        try:
            body = response.json()
            print("Response Body (JSON):")
            print(json.dumps(body, indent=2))
        except:
            print(f"Response Body (Text): {response.text[:200]}...")

        if 200 <= response.status_code < 300:
            print("\n[PASS] API Check Successful")
            return True
        else:
            print("\n[FAIL] API returned error status")
            return False

    except Exception as e:
        print(f"\n[ERROR] Request failed: {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("url", help="API URL")
    parser.add_argument("--method", default="GET", choices=["GET", "POST"])
    parser.add_argument("--data", help="JSON data for POST", default="{}")
    args = parser.parse_args()
    
    payload = json.loads(args.data)
    test_api(args.url, args.method, payload)
