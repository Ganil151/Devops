"""
Solution: CLI Argument Improver
"""
import argparse
import time
import random # used to simulate check

def mock_check(server):
    """Simulates a check that might fail."""
    return random.choice([True, False])

def check_with_retries(server, max_retries):
    """Retries logic for health checks."""
    for attempt in range(max_retries + 1):
        is_healthy = mock_check(server)
        if is_healthy:
            return True, attempt
        if attempt < max_retries:
            print(f"Retrying {server}... (Attempt {attempt + 1})")
            time.sleep(1)
    return False, max_retries

def parse_new_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--retries", type=int, default=0, help="Number of retries")
    return parser.parse_args()

if __name__ == "__main__":
    # Example usage
    args = parse_new_args()
    status, tries = check_with_retries("web-server", args.retries)
    print(f"Final Status: {status} after {tries} retries.")
