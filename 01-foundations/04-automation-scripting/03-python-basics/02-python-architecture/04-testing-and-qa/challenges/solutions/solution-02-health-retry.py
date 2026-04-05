"""
Solution: Health Check with Retries
"""
import requests
import time

def check_service_health(url, timeout=5, max_attempts=3, delay=2):
    """Check service health with retries."""
    result = {
        "url": url,
        "healthy": False,
        "status_code": None,
        "response_time_ms": None,
        "error": None,
        "attempts": 0
    }
    
    for attempt in range(1, max_attempts + 1):
        result["attempts"] = attempt
        
        try:
            start_time = time.time()
            response = requests.get(url, timeout=timeout)
            elapsed_ms = (time.time() - start_time) * 1000
            
            result["status_code"] = response.status_code
            result["response_time_ms"] = round(elapsed_ms, 2)
            
            if response.status_code == 200:
                result["healthy"] = True
                return result
            else:
                result["error"] = f"Non-200 status: {response.status_code}"
                
        except requests.exceptions.Timeout:
            result["error"] = f"Timeout after {timeout}s"
        except requests.exceptions.ConnectionError as e:
            result["error"] = f"Connection error: {e}"
        except Exception as e:
            result["error"] = f"Unexpected error: {e}"
        
        if attempt < max_attempts:
            print(f"Attempt {attempt} failed, retrying in {delay}s...")
            time.sleep(delay)
    
    return result

if __name__ == "__main__":
    health = check_service_health("https://httpbin.org/get")
    print(f"Health check result: {health}")
