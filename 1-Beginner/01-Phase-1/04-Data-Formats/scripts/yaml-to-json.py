"""
YAML to JSON Converter
Description: Converts YAML files to JSON format.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
Requirement: PyYAML
"""

import yaml
import json
import argparse
import sys

def convert(yaml_file, json_file=None):
    try:
        with open(yaml_file, 'r') as f:
            data = yaml.safe_load(f)
            
        if json_file:
            with open(json_file, 'w') as f:
                json.dump(data, f, indent=4)
            print(f"[OK] Converted {yaml_file} to {json_file}")
        else:
            print(json.dumps(data, indent=4))
            
    except Exception as e:
        print(f"[ERROR] Conversion failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YAML to JSON Converter')
    parser.add_argument('file', help='Path to YAML file')
    parser.add_argument('--output', '-o', help='Path to output JSON file')
    args = parser.parse_args()
    
    convert(args.file, args.output)
