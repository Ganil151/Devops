"""
Challenge: JSON Diff Tool
Scenario: You need to detect configuration changes between two versions of a service definition.

TODO: Implement `json_diff(old, new)` function.
1. Return a dictionary containing "added", "removed", and "changed" keys.
2. Identify keys that were added in the 'new' version.
3. Identify keys that were removed from the 'old' version.
4. Identify keys whose values have changed.
5. (Advanced) Handle nested dictionary structures.
"""
import json

def json_diff(old, new, path=""):
    """
    Compares two dictionaries and returns a summary of differences.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    old_config = {
        "port": 8080, 
        "debug": False, 
        "db": {"host": "localhost", "port": 5432}
    }
    
    new_config = {
        "port": 443, 
        "ssl": True, 
        "db": {"host": "prod-db.internal", "port": 5432}
    }
    
    diff = json_diff(old_config, new_config)
    print("Configuration Differences:")
    print(json.dumps(diff, indent=2))
