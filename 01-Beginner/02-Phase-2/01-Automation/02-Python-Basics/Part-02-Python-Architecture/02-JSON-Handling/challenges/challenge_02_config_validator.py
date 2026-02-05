"""
Challenge: Config Validator
Scenario: You are building a deployment tool that requires specific configuration settings.
Before starting, you must validate that the JSON config file provided by the user is valid according to a schema.

TODO: Implement `validate_config(config, schema)` function.
1. Check if all required fields in the schema exist in the config.
2. Check if the types of the fields in the config match the types specified in the schema.
3. Return a list of error strings. If no errors, return an empty list.
"""
import json

SCHEMA = {
    "required": ["database_url", "port", "debug"],
    "types": {
        "port": int,
        "debug": bool,
        "database_url": str
    }
}

def validate_config(config, schema):
    """
    Validates a configuration dictionary against a schema.
    Returns a list of errors found.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test 1: Invalid Config
    bad_config = {
        "port": "8080",  # Should be int
        "debug": True
        # Missing database_url
    }
    
    errors = validate_config(bad_config, SCHEMA)
    print("Validation Errors (Bad Config):", errors)
    
    # Test 2: Valid Config
    good_config = {
        "port": 5432,
        "debug": False,
        "database_url": "postgresql://db.prod.internal:5432/myapp"
    }
    errors = validate_config(good_config, SCHEMA)
    print("Validation Errors (Good Config):", errors)
