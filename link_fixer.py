#!/usr/bin/env python3
"""
Link Fixer for DevOps Documentation
Automatically fixes broken links by finding correct targets.
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import unquote, quote
from collections import defaultdict

# Base directory
BASE_DIR = Path(r"C:\Users\Ganil\Documents\Devops")

# Load the broken links report
with open(BASE_DIR / 'broken_links_report.json', 'r', encoding='utf-8') as f:
    report = json.load(f)

# Build a complete index of all files
print("Building file index...")
file_index = {}  # filename -> list of full paths
dir_index = {}   # dirname -> list of full paths

for root, dirs, files in os.walk(BASE_DIR):
    # Skip .git and other hidden
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    
    root_path = Path(root)
    for f in files:
        full_path = root_path / f
        rel_path = full_path.relative_to(BASE_DIR)
        
        if f not in file_index:
            file_index[f] = []
        file_index[f].append(rel_path)
    
    for d in dirs:
        full_path = root_path / d
        rel_path = full_path.relative_to(BASE_DIR)
        
        if d not in dir_index:
            dir_index[d] = []
        dir_index[d].append(rel_path)

def calculate_relative_path(source_file, target_file):
    """Calculate the relative path from source to target."""
    source_dir = Path(source_file).parent
    target = Path(target_file)
    
    try:
        # Both paths are relative to BASE_DIR
        source_abs = BASE_DIR / source_dir
        target_abs = BASE_DIR / target
        
        rel = os.path.relpath(target_abs, source_abs)
        # Convert Windows backslash to forward slash for markdown
        rel = rel.replace('\\', '/')
        # URL encode spaces
        rel = rel.replace(' ', '%20')
        return rel
    except Exception as e:
        print(f"Error calculating path: {e}")
        return None

def find_best_match(broken_link, source_file):
    """Find the best matching file/directory for a broken link."""
    link_path = unquote(broken_link.get('link_target', ''))
    
    # Remove anchor if any
    if '#' in link_path:
        link_path = link_path.split('#')[0]
    
    # Get the final component(s) of the path
    parts = Path(link_path.replace('/', '\\')).parts
    
    if not parts:
        return None
    
    # Check if it ends with directory
    is_dir = link_path.endswith('/') or not any(c in parts[-1] for c in ['.'])
    
    target_name = parts[-1].replace('%20', ' ')
    
    # First, check the suggested matches from the scanner
    possible_matches = broken_link.get('possible_matches', [])
    if possible_matches:
        # Prefer match that contains the same parent directory names
        source_parts = set(Path(source_file).parts)
        
        scored_matches = []
        for pm in possible_matches:
            pm_parts = set(Path(pm).parts)
            # Score based on common directories
            common = len(source_parts & pm_parts)
            
            # Boost if path contains expected parent directories from the broken link
            expected_parents = set(parts[:-1])
            parent_match = len(expected_parents & pm_parts)
            
            scored_matches.append((pm, common + parent_match * 2))
        
        scored_matches.sort(key=lambda x: x[1], reverse=True)
        if scored_matches:
            return scored_matches[0][0]
    
    # Search in file/dir index
    if is_dir:
        if target_name in dir_index:
            matches = dir_index[target_name]
            if len(matches) == 1:
                return str(matches[0])
    else:
        if target_name in file_index:
            matches = file_index[target_name]
            if len(matches) == 1:
                return str(matches[0])
            
            # Try to find best match based on path similarity
            if len(matches) > 1:
                source_parts = set(Path(source_file).parts)
                expected_parts = set(parts[:-1])
                
                best = None
                best_score = -1
                
                for m in matches:
                    m_parts = set(Path(m).parts)
                    score = len(source_parts & m_parts) + len(expected_parts & m_parts) * 2
                    if score > best_score:
                        best_score = score
                        best = m
                
                if best:
                    return str(best)
    
    return None

def fix_links_in_file(file_path, fixes):
    """Apply fixes to a single file."""
    full_path = BASE_DIR / file_path
    
    try:
        with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return False
    
    original = content
    
    # Sort fixes by line number descending so we don't mess up line positions
    fixes.sort(key=lambda x: x['line'], reverse=True)
    
    for fix in fixes:
        old_target = fix['old_target']
        new_target = fix['new_target']
        
        # Create the pattern to match the link
        pattern = re.escape(f']({old_target})')
        replacement = f']({new_target})'
        
        content = re.sub(pattern, replacement, content, count=1)
    
    if content != original:
        try:
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        except Exception as e:
            print(f"Error writing {file_path}: {e}")
            return False
    
    return False

# Process broken links
print(f"\nProcessing {len(report['broken_links'])} broken links...")

fixes_by_file = defaultdict(list)
unfixable = []
fixed_count = 0

for bl in report['broken_links']:
    source_file = bl['source_file']
    best_match = find_best_match(bl, source_file)
    
    if best_match:
        new_rel_path = calculate_relative_path(source_file, best_match)
        if new_rel_path:
            fixes_by_file[source_file].append({
                'line': bl['line'],
                'old_target': bl['link_target'],
                'new_target': new_rel_path,
                'link_text': bl['link_text']
            })
            fixed_count += 1
        else:
            unfixable.append(bl)
    else:
        unfixable.append(bl)

print(f"\nFound fixes for {fixed_count} links")
print(f"Unable to fix {len(unfixable)} links")

# Apply fixes
print(f"\nApplying fixes to {len(fixes_by_file)} files...")
files_modified = 0

for file_path, fixes in fixes_by_file.items():
    if fix_links_in_file(file_path, fixes):
        files_modified += 1
        print(f"  [+] Fixed {len(fixes)} links in {file_path}")

print(f"\n{'='*60}")
print(f"LINK FIX SUMMARY")
print(f"{'='*60}")
print(f"Total broken links: {len(report['broken_links'])}")
print(f"Links fixed: {fixed_count}")
print(f"Files modified: {files_modified}")
print(f"Unfixable links: {len(unfixable)}")

# Save unfixable links for manual review
if unfixable:
    unfixable_path = BASE_DIR / 'unfixable_links.json'
    with open(unfixable_path, 'w', encoding='utf-8') as f:
        json.dump(unfixable, f, indent=2)
    print(f"\nUnfixable links saved to: {unfixable_path}")
    
    print("\n\nSample of unfixable links (first 10):")
    for link in unfixable[:10]:
        print(f"  File: {link['source_file']}")
        print(f"  Line {link['line']}: [{link['link_text'][:30]}...]")
        print(f"  Target: {link['link_target']}")
        print()

print("\n✅ Done!")
