#!/usr/bin/env python3
"""
Name: api_client.py
Description: Production-ready API client with retries and timeout.
"""

import logging
import time
import sys
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("api_client")

def get_robust_session(retries: int = 3, backoff_factor: float = 0.5) -> requests.Session:
    """
    Creates a requests Session with automatic retries for failed connections
    and specific HTTP codes (500, 502, 503, 504).
    """
    session = requests.Session()
    
    retry_strategy = Retry(
        total=retries,
        backoff_factor=backoff_factor,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS"]
    )
    
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    
    return session

if __name__ == "__main__":
    url = "https://api.github.com/zen" # A reliable public endpoint
    
    session = get_robust_session()
    
    try:
        logger.info(f"Fetching {url}...")
        # Always set a timeout!
        response = session.get(url, timeout=5)
        response.raise_for_status() # Raise error for 4xx/5xx
        
        logger.info(f"Success! Response: {response.text.strip()}")
        logger.info(f"Status Code: {response.status_code}")
        
    except requests.exceptions.Timeout:
        logger.error("Request timed out.")
        sys.exit(1)
    except requests.exceptions.HTTPError as err:
        logger.error(f"HTTP Error: {err}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Fatal Error: {e}")
        sys.exit(1)
