"""
Challenge: Multi-Environment configuration
Scenario: Your automation script needs to behave differently in 'dev', 'staging', and 'prod'.
You have a base configuration, and each environment should override specific values.

TODO: Implement `get_config(env_name)`.
1. Define a `BASE_CONFIG` dictionary with: 
   - 'timeout': 30
   - 'retries': 3
   - 'debug': False
2. Define an `OVERRIDES` dictionary where keys are environment names and values are 
   specific setting changes.
3. Merge the dictionaries appropriately.
4. If `env_name` is not recognized, default to 'dev'.
"""
import os

def get_config(env_name):
    """
    Returns a merged configuration dictionary based on the environment.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test your implementation
    print(f"Prod Config: {get_config('prod')}")
    print(f"Unknown Config (should be dev): {get_config('unknown')}")
