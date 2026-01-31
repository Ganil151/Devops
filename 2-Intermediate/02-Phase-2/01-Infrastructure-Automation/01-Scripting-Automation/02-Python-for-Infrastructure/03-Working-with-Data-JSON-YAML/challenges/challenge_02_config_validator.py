"""
Challenge: Config Validator
Scenario: You want to ensure that all team members provide a valid YAML 
configuration before deploying.

TODO: Implement `validate_config(config_dict, schema)`.
1. `schema` is a dictionary: `{"key": type}`. Example: `{"retries": int, "env": str}`.
2. Check if all keys in the `schema` exist in `config_dict`.
3. Check if the values match the expected types.
4. Return a list of error strings (empty if valid).
"""

def validate_config(config_dict, schema):
    """
    Validates a dictionary against a simple schema.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    my_schema = {
        "replicas": int,
        "image": str,
        "enabled": bool
    }
    
    # Test valid
    valid_test = {"replicas": 3, "image": "nginx:latest", "enabled": True}
    print(f"Valid Check Errors (expecting []): {validate_config(valid_test, my_schema)}")
    
    # Test invalid
    invalid_test = {"replicas": "three", "enabled": True} # Missing 'image', wrong 'replicas' type
    print(f"Invalid Check Errors: {validate_config(invalid_test, my_schema)}")
