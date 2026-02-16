"""
Solution: Config Validator
"""

def validate_config(config, schema):
    """Parses a configuration dictionary and cross-references it with a schema."""
    errors = []
    
    # 1. Check required fields
    for field in schema.get("required", []):
        if field not in config:
            errors.append(f"Missing required field: {field}")
    
    # 2. Check field types
    for field, expected_type in schema.get("types", {}).items():
        if field in config:
            actual_type = type(config[field])
            if actual_type != expected_type:
                errors.append(
                    f"Field '{field}' should be {expected_type.__name__}, "
                    f"got {actual_type.__name__}"
                )
    
    return errors

if __name__ == "__main__":
    SCHEMA = {
        "required": ["database_url", "port"],
        "types": {
            "port": int,
            "debug": bool,
            "database_url": str
        }
    }
    
    config = {
        "port": "8080",  # Wrong type
        "debug": True
    }
    
    print("Errors:", validate_config(config, SCHEMA))
