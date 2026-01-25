"""
Challenge: CLI Argument Improver
Scenario: You want to add a `--retries` argument to your script so that
failed checks are retried before being marked as unhealthy.

TODO:
1. Modify the `argparse` setup to add `--retries` (type `int`, default `0`).
2. Implement a loop in the check logic that retries `N` times if `healthy` is False.
3. Wait 1 second between retries.
"""

import argparse
import time


def check_with_retries(server, max_retries):
    """
    Retries a check Multiple times before giving up.
    """
    for i in range(max_retries + 1):
        # Simulate a check (In a real script, this would call a checking function)
        # For demonstration, we assume it fails to trigger retries
        healthy = False
        print(f"Checking {server}... (Attempt {i+1}/{max_retries+1})")

        if healthy:
            return True

        if i < max_retries:
            time.sleep(1)

    return False


def parse_new_args():
    parser = argparse.ArgumentParser(description="Server Health Monitor")
    parser.add_argument("server", help="The server URL to check")
    parser.add_argument(
        "--retries", type=int, default=0, help="Number of retries on failure"
    )
    return parser.parse_args()


if __name__ == "__main__":
    # Test your implementation
    args = parse_new_args()
    result = check_with_retries(args.server, args.retries)
    print(f"Final Result for {args.server}: {'Healthy' if result else 'Unhealthy'}")
