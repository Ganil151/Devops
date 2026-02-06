"""
API Load Tester (Multi-threaded)
Description: Simple stress tester for endpoints using concurrent futures.
"""

import concurrent.futures
import requests
import time
import argparse
import logging
from statistics import mean

# Setup Logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def test_endpoint(url):
    """Makes a single request and returns latency."""
    start = time.time()
    try:
        resp = requests.get(url, timeout=5)
        latency = time.time() - start
        return resp.status_code, latency
    except requests.RequestException:
        return 0, time.time() - start

def load_test(url, requests_count, workers):
    logging.info(f"Starting Load Test: {url} | Req: {requests_count} | Workers: {workers}")
    
    results = []
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(test_endpoint, url) for _ in range(requests_count)]
        
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())
            
    total_time = time.time() - start_time
    
    # Process Results
    latencies = [r[1] for r in results]
    codes = [r[0] for r in results]
    success_count = codes.count(200)
    
    report = {
        "url": url,
        "total_requests": requests_count,
        "success_rate": f"{(success_count/requests_count)*100}%" if requests_count > 0 else "0%",
        "total_time_sec": round(total_time, 2),
        "avg_latency_sec": round(mean(latencies), 3) if latencies else 0,
        "requests_per_sec": round(requests_count / total_time, 2) if total_time > 0 else 0
    }
    
    return report

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="API Load Tester")
    parser.add_argument("url", help="Target URL")
    parser.add_argument("--requests", type=int, default=50, help="Total requests")
    parser.add_argument("--workers", type=int, default=5, help="Concurrent threads")
    
    args = parser.parse_args()
    
    stats = load_test(args.url, args.requests, args.workers)
    
    print("\n--- Load Test Report ---")
    for k, v in stats.items():
        print(f"{k}: {v}")
