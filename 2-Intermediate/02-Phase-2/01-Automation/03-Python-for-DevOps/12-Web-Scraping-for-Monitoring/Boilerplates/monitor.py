#!/usr/bin/env python3
"""
Name: monitor.py
Description: Simple Web Scraper for Blackbox Monitoring.
Requires: pip install requests beautifulsoup4
"""

import requests
from bs4 import BeautifulSoup
import logging
import sys

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("scraper")

def check_keyword(url: str, keyword: str) -> bool:
    """Checks if a keyword exists in the HTML body of a page."""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, "html.parser")
        
        # Get visible text only
        text = soup.get_text()
        
        if keyword in text:
            logger.info(f"✅ Found '{keyword}' on {url}")
            return True
        else:
            logger.warning(f"❌ '{keyword}' NOT found on {url}")
            return False
            
    except Exception as e:
        logger.error(f"Failed to scrape {url}: {e}")
        return False

if __name__ == "__main__":
    check_keyword("https://example.com", "Example Domain")
