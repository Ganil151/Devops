"""
Challenge: Prefix-Based Config Loader
Scenario: Your application has many settings in the environment, all prefixed with `APP_` 
(e.g., `APP_PORT`, `APP_TIMEOUT`). You want to extract them into a clean dictionary.

TODO: Implement `get_app_config(prefix="APP_")` function.
1. Iterate over all keys in `os.environ`.
2. Find keys that start with the given prefix.
3. Add them to a new dictionary, but remove the prefix from the key name and make it lowercase.
4. Return the dictionary.
"""
import os

def get_app_config(prefix="APP_"):
    """
    Extracts prefixed environment variables into a dictionary.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Simulate environment vars
    os.environ["APP_PORT"] = "9000"
    os.environ["APP_DEBUG"] = "true"
    os.environ["APP_DB_HOST"] = "db.internal"
    os.environ["OTHER_VAR"] = "ignore_me"
    
    config = get_app_config()
    print("Application Config:", config)
    # Expected: {'port': '9000', 'debug': 'true', 'db_host': 'db.internal'}
