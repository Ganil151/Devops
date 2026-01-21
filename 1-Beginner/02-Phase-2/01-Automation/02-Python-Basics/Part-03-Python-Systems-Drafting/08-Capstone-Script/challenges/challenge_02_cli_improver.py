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
    # --- START YOUR CODE HERE ---
    pass

def parse_new_args():
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test your implementation
    pass
