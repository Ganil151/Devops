"""
Solution: Robust Config Loader
"""
import json

DEFAULT_CONFIG = {"debug": False, "port": 8080}
REQUIRED_KEYS = ["database_url", "api_key"]

class ConfigError(Exception):
    """Configuration error."""
    pass

class ConfigValidationError(ConfigError):
    """Config validation failed."""
    def __init__(self, missing_keys):
        self.missing_keys = missing_keys
        super().__init__(f"Missing required keys: {missing_keys}")

def load_config(filepath):
    """Load and validate configuration file."""
    try:
        with open(filepath, 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        print(f"Config not found at {filepath}, using defaults")
        return DEFAULT_CONFIG.copy()
    except json.JSONDecodeError as e:
        raise ConfigError(f"Invalid JSON in {filepath}: {e}")
    
    # Merge with defaults
    final_config = {**DEFAULT_CONFIG, **config}
    
    # Validate required keys
    missing = [k for k in REQUIRED_KEYS if k not in final_config]
    if missing:
        raise ConfigValidationError(missing)
    
    return final_config

if __name__ == "__main__":
    # Example usage
    try:
        config = load_config("app.json")
        print(f"Loaded config: {config}")
    except ConfigError as e:
        print(f"Config error: {e}")
