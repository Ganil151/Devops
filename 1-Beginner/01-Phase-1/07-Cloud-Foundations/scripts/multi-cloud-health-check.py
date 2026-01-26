"""
Multi-Cloud Health Check Dashboard
Description: Unified health check script for endpoints across AWS, Azure, and GCP
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import requests
import json
import time

# Configuration: List of endpoints to monitor
ENDPOINTS = [
    {"name": "AWS-App-Prod", "url": "https://aws.amazon.com", "cloud": "AWS"},
    {"name": "Azure-API-Gateway", "url": "https://azure.microsoft.com", "cloud": "Azure"},
    {"name": "GCP-Service-Mesh", "url": "https://cloud.google.com", "cloud": "GCP"}
]

def check_endpoint(endpoint):
    start = time.time()
    try:
        response = requests.get(endpoint['url'], timeout=5)
        latency = round((time.time() - start) * 1000, 2)
        return {
            "name": endpoint['name'],
            "cloud": endpoint['cloud'],
            "status": "UP" if response.status_code == 200 else "DOWN",
            "code": response.status_code,
            "latency_ms": latency
        }
    except Exception as e:
        return {
            "name": endpoint['name'],
            "cloud": endpoint['cloud'],
            "status": "ERROR",
            "code": 0,
            "latency_ms": 0,
            "error": str(e)
        }

def main():
    print("Multi-Cloud Service Health Check")
    print("================================")
    print(f"{'Cloud':<10} {'Service':<20} {'Status':<10} {'Code':<10} {'Latency':<10}")
    print("-" * 65)
    
    results = []
    
    for ep in ENDPOINTS:
        res = check_endpoint(ep)
        results.append(res)
        
        status_color = res['status']
        print(f"{res['cloud']:<10} {res['name']:<20} {res['status']:<10} {res['code']:<10} {res['latency_ms']}ms")

    # Export
    with open('multi-cloud-health.json', 'w') as f:
        json.dump(results, f, indent=4)
    print("\nDetailed results saved to multi-cloud-health.json")

if __name__ == "__main__":
    main()
