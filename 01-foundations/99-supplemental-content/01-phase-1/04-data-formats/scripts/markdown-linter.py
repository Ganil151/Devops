"""
Markdown Linter (Simple)
Description: Checks Markdown files for basic style violations.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import argparse
import re

def lint_markdown(file_path):
    issues = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for i, line in enumerate(lines):
            line_num = i + 1
            
            # Check 1: Trailing whitespace
            if line.rstrip('\n') != line.rstrip():
                issues.append(f"Line {line_num}: Trailing whitespace found")
                
            # Check 2: Header formatting
            if line.startswith('#'):
                if not re.match(r'^#+\s', line):
                    issues.append(f"Line {line_num}: invalid header syntax (missing space after #)")
                    
            # Check 3: Long lines
            if len(line) > 120:
                issues.append(f"Line {line_num}: Line exceeds 120 characters")
                
        if issues:
            print(f"[WARN] Found {len(issues)} issues in {file_path}:")
            for issue in issues:
                print(f"  - {issue}")
            return False
        else:
            print(f"[OK] {file_path} looks good!")
            return True
            
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Simple Markdown Linter')
    parser.add_argument('file', help='Path to Markdown file')
    args = parser.parse_args()
    
    lint_markdown(args.file)
