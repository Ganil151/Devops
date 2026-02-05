"""
Challenge: Secure Config Orchestrator
Scenario: Your script needs an API_KEY. You should nunca hardcode it. 
It should be pulled from an environment variable first, then from a 
local .env file, then a default value (if safe).

TODO: Implement `get_secure_key(key_name, default=None)`.
1. Check if `key_name` exists in `os.environ`.
2. Check if a file named '.secrets' exists. If so, try to parse it 
   (Format: KEY=VALUE per line).
3. If not found in either, return the `default`.
4. Log where the key was loaded from (e.g., "Loaded from ENV" vs "Loaded from File").
"""
import os

def get_secure_key(key_name, default=None):
    """
    Retrieves a configuration key securely.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Setup
    os.environ["DB_PORT"] = "5432"
    with open(".secrets", "w") as f:
        f.write("API_KEY=ABC-123\n")
        
    print(f"DB_PORT: {get_secure_key('DB_PORT')}")
    print(f"API_KEY: {get_secure_key('API_KEY')}")
    print(f"MISSING: {get_secure_key('TIMEOUT', '30')}")
