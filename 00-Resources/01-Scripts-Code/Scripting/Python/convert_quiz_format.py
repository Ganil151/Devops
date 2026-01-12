#!/usr/bin/env python3
"""
Script to convert Terraform documentation quiz answers from plain text to collapsible HTML details format.
Converts: *Answer: B* -> <details><summary>Show Answer</summary>**Answer: B**</details>
"""

import re
import os
from pathlib import Path

def convert_quiz_answers(content):
    """
    Convert quiz answer format from plain text to collapsible HTML details.
    
    Pattern matches:
    - *Answer: A*
    - *Answer: B*
    - Answer: C (without asterisks)
    etc.
    """
    # Pattern to match answer lines
    # Matches: *Answer: X* or Answer: X (with optional explanation after)
    pattern = r'^\s*\*?Answer:\s*([A-D])\*?\s*(.*)$'
    
    lines = content.split('\n')
    result = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        match = re.match(pattern, line)
        
        if match:
            answer_letter = match.group(1)
            explanation = match.group(2).strip()
            
            # Create the collapsible answer block
            details_block = [
                '',
                '<details>',
                '<summary>Show Answer</summary>',
                '',
                f'**Answer: {answer_letter}**'
            ]
            
            # Add explanation if it exists (remove leading dash if present)
            if explanation:
                explanation = explanation.lstrip('- ')
                if explanation:
                    details_block.append(f' - {explanation}')
            
            details_block.extend(['', '</details>'])
            
            result.extend(details_block)
        else:
            result.append(line)
        
        i += 1
    
    return '\n'.join(result)

def should_process_file(filepath):
    """Check if file should be processed (has quiz content)."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Check if file contains quiz answers
            return bool(re.search(r'\*?Answer:\s*[A-D]\*?', content))
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False

def process_file(filepath):
    """Process a single markdown file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        # Convert quiz answers
        new_content = convert_quiz_answers(original_content)
        
        # Only write if content changed
        if new_content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def process_directory(directory_path):
    """Process all markdown files in directory recursively."""
    processed_count = 0
    skipped_count = 0
    error_count = 0
    
    base_path = Path(directory_path)
    
    # Find all .md files recursively
    md_files = list(base_path.rglob('*.md'))
    
    print(f"Found {len(md_files)} markdown files")
    print("Processing files with quiz content...\n")
    
    for md_file in md_files:
        if should_process_file(md_file):
            print(f"Processing: {md_file.relative_to(base_path)}")
            if process_file(md_file):
                processed_count += 1
                print(f"  ✓ Updated")
            else:
                skipped_count += 1
                print(f"  - No changes needed")
        else:
            skipped_count += 1
    
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Files processed: {processed_count}")
    print(f"  Files skipped: {skipped_count}")
    print(f"  Errors: {error_count}")
    print(f"{'='*60}")

if __name__ == "__main__":
    terraform_dir = r"C:\Users\Ganil\Documents\Devops\2-Intermediate\03-Terraform"
    process_directory(terraform_dir)
