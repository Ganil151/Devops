"""
Simple Code Refactoring Bot
Description: Suggests style fixes using regex (Primitive Linter).
"""

import re
import sys

def refactor(file_path):
    print(f"Checking {file_path} for easy refactors...")
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines):
        line_num = i + 1
        
        # Check 1: print statements in production code
        if "print(" in line and "#" not in line:
            print(f"Line {line_num}: Consider using 'logging.info()' instead of 'print()'.")
            
        # Check 2: TODOs
        if "TODO" in line:
            print(f"Line {line_num}: Found TODO item.")
            
        # Check 3: CamelCase vars in Python (simple check)
        # Matches typical variable assignment like 'myVar =' 
        camel_match = re.search(r'\s([a-z]+[A-Z][a-zA-Z0-9]*)\s*=', line)
        if camel_match:
            print(f"Line {line_num}: Variable '{camel_match.group(1)}' uses camelCase. Python prefers snake_case.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python refactor-code-bot.py <file>")
    else:
        refactor(sys.argv[1])
