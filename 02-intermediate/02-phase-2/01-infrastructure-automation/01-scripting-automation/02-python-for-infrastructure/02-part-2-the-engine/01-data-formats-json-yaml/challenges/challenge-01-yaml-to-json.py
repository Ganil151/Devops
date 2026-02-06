"""
Challenge: YAML to JSON Converter
Scenario: Your legacy monitoring system only supports JSON, but your 
infrastructure configs are all in YAML. You need to automate the conversion.

TODO: Implement `convert_yaml_to_json(yaml_file)`.
1. Load the YAML content using `yaml.safe_load()`.
2. Generate a new filename replacing `.yaml` or `.yml` with `.json`.
3. Save the data to the new JSON file with an indentation of 4.
4. Return the path of the new file.
"""
import yaml
import json
from pathlib import Path

def convert_yaml_to_json(yaml_file):
    """
    Converts a single YAML file to JSON.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Setup
    test_yaml = Path("config.yaml")
    sample_data = {
        "server": {"name": "prod-01", "cpu": 4},
        "tags": ["web", "nginx"]
    }
    with open(test_yaml, "w") as f:
        yaml.dump(sample_data, f)
        
    json_path = convert_yaml_to_json(test_yaml)
    print(f"Converted to: {json_path}")
    # Verify content
    if json_path.exists():
        print(f"JSON Output: {json_path.read_text()}")
