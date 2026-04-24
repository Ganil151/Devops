"""
Solution: Config Validator
"""

def validate_config(config_dict, schema):
    errors = []
    
    for key, expected_type in schema.items():
        # Check existence
        if key not in config_dict:
            errors.append(f"Missing key: '{key}'")
            continue
            
        # Check type
        actual_value = config_dict[key]
        if not isinstance(actual_value, expected_type):
            errors.append(f"Invalid type for '{key}': expected {expected_type.__name__}, got {type(actual_value).__name__}")
            
    return errors

if __name__ == "__main__":
    # Test cases included in challenge file
    pass
