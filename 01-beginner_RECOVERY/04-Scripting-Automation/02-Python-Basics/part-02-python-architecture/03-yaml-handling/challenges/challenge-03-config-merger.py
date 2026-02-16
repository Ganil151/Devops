"""
Challenge: Config Merger
Scenario: You have a base YAML configuration and multiple environment-specific overrides (e.g., prod.yaml, test.yaml).
You need to merge these files such that the environment overrides take precedence.

TODO: Implement `deep_merge(base, override)` and `merge_yaml_files(base_path, override_path)`.
1. Recursively merge nested dictionaries.
2. If a key is in both, use the value from the 'override' dictionary.
3. Return the merged dictionary.
"""
import yaml
from copy import deepcopy

def deep_merge(base, override):
    """
    Recursively merges 'override' into 'base'.
    """
    # --- START YOUR CODE HERE ---
    pass

def merge_yaml_files(base_path, override_path):
    """
    Loads two YAML files and returns their merged dictionary.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    base_data = {
        "server": {"port": 8080, "host": "localhost"},
        "database": {"pool": 5, "user": "dev_user"}
    }
    prod_data = {
        "server": {"host": "0.0.0.0"},
        "database": {"pool": 20, "user": "prod_user"}
    }
    
    merged = deep_merge(base_data, prod_data)
    print("Merged Configuration:")
    print(yaml.dump(merged, default_flow_style=False))
