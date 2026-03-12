"""
Challenge: Type-Safe Bool Parser
Scenario: Environment variables are always strings in Python. You need a reliable 
way to convert values like "true", "1", "yes", or "on" into actual Python booleans.

TODO: Implement `get_env_bool(name, default=False)` function.
1. Read the variable from `os.environ`.
2. Compare the lowercase value against a list of truthy strings: ("true", "1", "t", "y", "yes", "on").
3. Return `True` if matches, `False` otherwise (or the default).
"""
import os

def get_env_bool(name, default=False):
    """
    Safely parses an environment variable as a boolean.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test cases
    os.environ["DEBUG_MODE"] = "True"
    os.environ["USE_SSL"] = "yes"
    os.environ["ANALYTICS"] = "0"
    
    print(f"DEBUG_MODE: {get_env_bool('DEBUG_MODE')}") # Expected: True
    print(f"USE_SSL: {get_env_bool('USE_SSL')}")       # Expected: True
    print(f"ANALYTICS: {get_env_bool('ANALYTICS')}")   # Expected: False
    print(f"NOT_SET: {get_env_bool('NOT_SET', True)}") # Expected: True
