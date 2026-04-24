"""
TOML Config Manager
Description: Reads and modifies TOML configuration files.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
Requirement: toml
"""

import toml
import argparse
import sys

def read_toml(file_path):
    try:
        data = toml.load(file_path)
        return data
    except Exception as e:
        print(f"[ERROR] Failed to read TOML: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='TOML Config Manager')
    parser.add_argument('file', help='Path to TOML file')
    args = parser.parse_args()
    
    data = read_toml(args.file)
    print(f"Successfully loaded {args.file}")
    print(toml.dumps(data))
