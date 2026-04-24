#!/usr/bin/env python3
"""
Create Missing Challenge/Solution Files
Reads unfixable_links.json and creates stub files for missing code files
to resolve broken links.
"""

import os
import json
from pathlib import Path

BASE_DIR = Path(r"C:\Users\Ganil\Documents\Devops")

def create_stubs():
    # Load unfixable links
    try:
        with open(BASE_DIR / 'unfixable_links.json', 'r', encoding='utf-8') as f:
            links = json.load(f)
    except FileNotFoundError:
        print("unfixable_links.json not found!")
        return

    # Filter for code files
    code_extensions = ['.py', '.go', '.sh', '.tf', '.js', '.json', '.yaml', '.yml']
    
    files_to_create = []
    
    for link in links:
        target = link['link_target']
        # Resolve target relative to source file
        source_file = BASE_DIR / link['source_file']
        source_dir = source_file.parent
        
        # Simple resolution (handle logical paths)
        try:
            # Clean up target path (remove URL encoding)
            clean_target = target.replace('%20', ' ')
            
            # Construct absolute path
            target_path = (source_dir / clean_target).resolve()
            
            # Check if it has an extension we care about
            if any(str(target_path).endswith(ext) for ext in code_extensions):
                # Only if it's inside our repo
                if str(BASE_DIR) in str(target_path):
                    files_to_create.append(target_path)
        except Exception as e:
            print(f"Skipping malformed link {target}: {e}")

    # Remove duplicates
    files_to_create = list(set(files_to_create))
    
    print(f"Found {len(files_to_create)} missing code files to create.")
    
    created_count = 0
    
    for file_path in files_to_create:
        try:
            # Create directories if needed
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Determine content based on extension
            ext = file_path.suffix
            content = ""
            
            if ext == '.py':
                content = (
                    '#!/usr/bin/env python3\n'
                    '"""\n'
                    f'Placeholder for {file_path.name}\n'
                    'TODO: Implement this challenge/solution\n'
                    '"""\n'
                    'pass\n'
                )
            elif ext == '.go':
                content = (
                    'package main\n\n'
                    '// TODO: Implement this challenge/solution\n'
                    'func main() {\n'
                    '}\n'
                )
            elif ext == '.sh':
                content = (
                    '#!/bin/bash\n'
                    '# TODO: Implement this script\n'
                )
            elif ext == '.tf':
                content = (
                    '# TODO: Implement Terraform configuration\n'
                )
            else:
                content = f"# Placeholder for {file_path.name}\n"
            
            # Write file if it doesn't exist
            if not file_path.exists():
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                created_count += 1
                print(f"Created: {file_path.relative_to(BASE_DIR)}")
            else:
                print(f"Existed: {file_path.relative_to(BASE_DIR)}")
                
        except Exception as e:
            print(f"Failed to create {file_path}: {e}")

    print(f"\nSuccessfully created {created_count} stub files.")

if __name__ == "__main__":
    create_stubs()
