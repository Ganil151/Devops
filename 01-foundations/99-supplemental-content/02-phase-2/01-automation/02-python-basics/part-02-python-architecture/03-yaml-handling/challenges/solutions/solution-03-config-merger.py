"""
Solution: Config Merger
"""
import yaml
from copy import deepcopy

def deep_merge(base, override):
    """Recursively merge override into base."""
    result = deepcopy(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = deepcopy(value)
    return result

def merge_yaml_files(base_path, override_path):
    """Merge two YAML config files."""
    with open(base_path, 'r') as f:
        base = yaml.safe_load(f) or {}
    
    with open(override_path, 'r') as f:
        override = yaml.safe_load(f) or {}
    
    return deep_merge(base, override)

if __name__ == "__main__":
    base = {"server": {"port": 8080}, "db": {"pool": 5}}
    prod = {"server": {"port": 443}, "db": {"pool": 20}}
    final = deep_merge(base, prod)
    print(yaml.dump(final, default_flow_style=False))
