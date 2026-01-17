#!/usr/bin/env python3
"""
Name: resilient_api.py
Description: Demonstrates an API client with robust retry logic.
"""

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("api_client")

def get_resilient_session():
    """Configures a requests session with automatic retries."""
    session = requests.Session()
    
    # Configure retry logic
    retries = Retry(
        total=3,           # Total number of retries
        backoff_factor=2,  # Wait 2s, 4s, 8s...
        status_forcelist=[429, 500, 502, 503, 504], # Retry on these codes
        raise_on_status=False
    )
    
    # Mount the adapter to both HTTP and HTTPS
    adapter = HTTPAdapter(max_retries=retries)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    
    return session

if __name__ == "__main__":
    client = get_resilient_session()
    
    # Test URL (HTTPBin is great for testing status codes)
    url = "https://httpbin.org/status/500"
    
    try:
        logger.info(f"Attempting to call {url}...")
        response = client.get(url, timeout=5)
        
        if response.status_code == 200:
            logger.info("Success!")
        else:
            logger.error(f"Request failed with status: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        logger.error(f"Fatal request error: {e}")
