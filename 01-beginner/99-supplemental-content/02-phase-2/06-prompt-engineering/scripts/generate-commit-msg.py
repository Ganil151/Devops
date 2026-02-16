"""
Commit Message Generator
Description: Generates standardized commit messages.
"""

import sys
import random

PREFIXES = {
    "feat": "New feature implementation",
    "fix": "Bug fix",
    "docs": "Documentation update",
    "style": "Code formatting change",
    "refactor": "Code refactoring",
    "test": "Adding or updating tests",
    "chore": "Maintenance task"
}

def generate_msg(type_key, message):
    if type_key not in PREFIXES:
        print(f"Unknown type. Use: {', '.join(PREFIXES.keys())}")
        return
    
    print(f"{type_key}: {message}")
    print(f"\n# Description: {PREFIXES[type_key]}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate-commit-msg.py <type> <message>")
    else:
        generate_msg(sys.argv[1], " ".join(sys.argv[2:]))
