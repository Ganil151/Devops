"""
Challenge: Environment Override CLI
Scenario: A common pattern is to allow a configuration value (like an API_KEY) 
to be provided either via a command-line argument OR an environment variable 
if the argument is missing.

TODO: Implement a CLI that uses environment variables as defaults.
1. Use `os.environ.get("API_KEY")` as the default value for a 'key' argument.
2. The 'key' argument should be optional (using `nargs="?"`).
3. If after parsing, 'key' is still None (neither arg nor env supplied), print an error and exit.
"""
import argparse
import os
import sys

def main():
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    main()
