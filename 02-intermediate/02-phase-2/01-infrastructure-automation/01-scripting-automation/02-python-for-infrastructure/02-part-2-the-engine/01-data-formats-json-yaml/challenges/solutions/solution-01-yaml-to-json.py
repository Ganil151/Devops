"""
Solution: YAML to JSON Converter
"""
import yaml
import json
from pathlib import Path

def convert_yaml_to_json(yaml_file):
    path = Path(yaml_file)
    
    # Check if exists
    if not path.exists():
        raise FileNotFoundError(f"Missing {yaml_file}")
        
    # Load YAML
    with open(path, 'r') as f:
        data = yaml.safe_load(f)
        
    # Create JSON Path
    json_path = path.with_suffix(".json")
    
    # Save JSON
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=4)
        
    return json_path

if __name__ == "__main__":
    # Test logic
    pass
