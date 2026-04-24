"""
Solution: JSON Diff Tool
"""
import json

def json_diff(old, new, path=""):
    """Compare two JSON-like structures and return differences."""
    diff = {"added": [], "removed": [], "changed": []}
    
    old_keys = set(old.keys()) if isinstance(old, dict) else set()
    new_keys = set(new.keys()) if isinstance(new, dict) else set()
    
    # 1. Added keys
    for key in new_keys - old_keys:
        key_path = f"{path}.{key}" if path else key
        diff["added"].append({"path": key_path, "value": new[key]})
    
    # 2. Removed keys
    for key in old_keys - new_keys:
        key_path = f"{path}.{key}" if path else key
        diff["removed"].append({"path": key_path, "value": old[key]})
    
    # 3. Changed keys
    for key in old_keys & new_keys:
        key_path = f"{path}.{key}" if path else key
        old_val = old[key]
        new_val = new[key]
        
        if isinstance(old_val, dict) and isinstance(new_val, dict):
            # Recurse for nested dictionaries
            nested_diff = json_diff(old_val, new_val, key_path)
            for category in diff:
                diff[category].extend(nested_diff[category])
        elif old_val != new_val:
            diff["changed"].append({
                "path": key_path,
                "old": old_val,
                "new": new_val
            })
    
    return diff

if __name__ == "__main__":
    old_config = {"port": 8080, "debug": False, "db": {"host": "localhost"}}
    new_config = {"port": 443, "ssl": True, "db": {"host": "prod-db"}}
    
    differences = json_diff(old_config, new_config)
    print(json.dumps(differences, indent=2))
