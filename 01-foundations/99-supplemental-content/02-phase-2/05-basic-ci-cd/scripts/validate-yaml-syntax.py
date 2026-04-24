"""
YAML Syntax Validator
Description: Validates YAML files (useful for CI configs).
Requirement: PyYAML
"""

import yaml
import sys
import argparse

def validate_yaml(file_path):
    print(f"Validating {file_path}...")
    try:
        with open(file_path, 'r') as f:
            yaml.safe_load(f)
        print("[OK] Valid YAML.")
        return True
    except yaml.YAMLError as exc:
        print("[ERROR] Invalid YAML.")
        if hasattr(exc, 'problem_mark'):
            mark = exc.problem_mark
            print(f"Error position: ({mark.line+1}:{mark.column+1})")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="YAML file path")
    args = parser.parse_args()
    
    if not validate_yaml(args.file):
        sys.exit(1)
