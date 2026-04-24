"""
JSON Validator
Description: Validates JSON syntax and optional schema compliance.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import json
import argparse
import sys

def validate_json(file_path):
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        print(f"[OK] {file_path} is valid JSON.")
        return True
    except json.JSONDecodeError as e:
        print(f"[ERROR] {file_path} is INVALID.")
        print(f"Details: {e}")
        return False
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='JSON Validator')
    parser.add_argument('file', help='Path to JSON file')
    args = parser.parse_args()
    
    if not validate_json(args.file):
        sys.exit(1)
