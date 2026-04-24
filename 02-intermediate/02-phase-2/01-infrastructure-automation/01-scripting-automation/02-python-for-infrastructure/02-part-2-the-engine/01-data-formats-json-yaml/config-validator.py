#!/usr/bin/env python3
"""
Topic: Working with Data (JSON/YAML)
Description: Demonstrates safe parsing and validation of configuration files.
"""

import json
import yaml
import sys
from typing import Dict, Any

def validate_config(config: Dict[str, Any]) -> bool:
    """🔍 Pattern: Check-Act-Verify."""
    required_keys = ["version", "environment", "database"]
    
    # Check for missing keys
    missing = [key for key in required_keys if key not in config]
    if missing:
        print(f"❌ Validation Error: Missing keys: {missing}")
        return False
    
    # Validate value types
    if not isinstance(config["version"], (int, float)):
        print(f"❌ Validation Error: 'version' must be a number.")
        return False
        
    return True

def process_yaml_config(file_path: str):
    try:
        with open(file_path, 'r') as f:
            # 🛡️ Standard: Use safe_load to prevent RCE
            data = yaml.safe_load(f)
            
        if validate_config(data):
            print("✅ Configuration is valid.")
            # Convert to JSON for API delivery
            print("📦 Minified JSON for API:")
            print(json.dumps(data, separators=(',', ':')))
            
    except FileNotFoundError:
        print(f"❌ Error: Config file not found: {file_path}")
    except yaml.YAMLError as e:
        print(f"❌ Error: Invalid YAML format: {e}")

if __name__ == "__main__":
    # Create a dummy config for demo
    dummy_yaml = "config.yml"
    with open(dummy_yaml, "w") as f:
        f.write("version: 1.0\nenvironment: prod\ndatabase: primary-db")
        
    process_yaml_config(dummy_yaml)
