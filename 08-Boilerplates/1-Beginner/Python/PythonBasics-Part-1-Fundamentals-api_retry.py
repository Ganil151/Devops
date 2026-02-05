#!/usr/bin/env python3
"""
Boilerplate: Resilient API Caller
DevOps Context: Handling network failures/timeouts gracefully.
"""
import time
import random
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("Network")

class NetworkError(Exception):
    pass

def simulate_api_call():
    """Simulates a flaky API."""
    if random.random() < 0.7:
        raise NetworkError("Connection timed out")
    return "Success 200 OK"

def fetch_data_with_retry(max_retries=3):
    """
    Attempts to fetch data, retrying on failure.
    """
    for attempt in range(1, max_retries + 1):
        try:
            logger.info(f"Attempt {attempt}/{max_retries}...")
            result = simulate_api_call()
            logger.info(f"Call succeeded: {result}")
            return result
        except NetworkError as e:
            logger.warning(f"Error encountered: {e}")
            if attempt == max_retries:
                logger.error("Max retries reached. Giving up.")
                raise
            sleep_time = attempt * 1 # Simple backoff
            logger.info(f"Retrying in {sleep_time}s...")
            time.sleep(sleep_time)

def main():
    try:
        fetch_data_with_retry()
    except NetworkError:
        logger.error("Process failed after multiple attempts.")
        # Exit with error code in real scenario
        # sys.exit(1)

if __name__ == "__main__":
    main()
