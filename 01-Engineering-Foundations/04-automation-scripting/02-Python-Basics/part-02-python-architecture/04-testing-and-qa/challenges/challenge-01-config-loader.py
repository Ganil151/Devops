"""
Challenge: Robust Config Loader
Scenario: Create a config loader that handles multiple error scenarios gracefully.

TODO: Implement `load_config(filepath)` function:
1. Return config dict on success.
2. Use `DEFAULT_CONFIG` if the file is not found (and log it).
3. Raise a custom `ConfigError` if the JSON is invalid.
4. Validate that all `REQUIRED_KEYS` exist, otherwise raise `ConfigValidationError`.
"""
import json

DEFAULT_CONFIG = {"debug": False, "port": 8080}
REQUIRED_KEYS = ["database_url", "api_key"]

class ConfigError(Exception):
    """Base Configuration error."""
    pass

class ConfigValidationError(ConfigError):
    """Config validation failed."""
    pass

def load_config(filepath):
    """Load and validate configuration file."""
    # --- START YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    # 1. Test missing file
    print("Test Missing:", load_config("nonexistent.json"))
    
    # 2. Test invalid JSON
    with open("invalid.json", "w") as f:
        f.write("{ invalid json")
    try:
        load_config("invalid.json")
    except ConfigError as e:
        print("Caught Expected Error:", e)
        
    # 3. Test missing keys
    with open("missing_keys.json", "w") as f:
        json.dump({"debug": True}, f)
    try:
        load_config("missing_keys.json")
    except ConfigValidationError as e:
        print("Caught Expected Validation Error:", e)
