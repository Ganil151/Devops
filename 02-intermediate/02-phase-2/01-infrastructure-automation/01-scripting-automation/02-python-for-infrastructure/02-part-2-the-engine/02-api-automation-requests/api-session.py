#!/usr/bin/env python3
"""
Topic: API Mastery with Requests
Description: Demonstrates persistent sessions and robust error handling.
"""

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def get_automated_session() -> requests.Session:
    """🏗️ Creates a robust session with retry logic for transient failures."""
    session = requests.Session()
    
    # Configure Retries (Backoff strategy)
    retries = Retry(
        total=3,
        backoff_factor=1, # Wait 1s, 2s, 4s
        status_forcelist=[500, 502, 503, 504]
    )
    
    session.mount("https://", HTTPAdapter(max_retries=retries))
    return session

def fetch_health_status(url: str):
    session = get_automated_session()
    
    try:
        print(f"📡 Querying {url}...")
        response = session.get(url, timeout=5)
        
        # 🛡️ Standard: Fail-Fast if status is not 2xx
        response.raise_for_status()
        
        data = response.json()
        print(f"✅ Connection successful. Status: {data.get('status', 'OK')}")
        
    except requests.exceptions.HTTPError as e:
        print(f"❌ API Error: {e}")
    except requests.exceptions.Timeout:
        print("❌ Error: Request timed out.")
    except Exception as e:
        print(f"💥 Unexpected Error: {e}")

if __name__ == "__main__":
    # Example using a public test API
    fetch_health_status("https://httpbin.org/get")
