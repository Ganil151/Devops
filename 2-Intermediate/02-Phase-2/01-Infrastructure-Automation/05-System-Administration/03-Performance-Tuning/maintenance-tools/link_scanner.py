#!/usr/bin/env python3
"""
Link Scanner for DevOps Documentation
Scans all markdown files and validates internal links.
Outputs a report of broken links that need to be fixed.
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import unquote
from collections import defaultdict

# Base directory to scan
BASE_DIR = Path(r"C:\Users\Ganil\Documents\Devops")

# Pattern to match markdown links: [text](path)
LINK_PATTERN = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')

# Directories/files to ignore
IGNORE_PATTERNS = ['.git', '.obsidian', 'node_modules', '__pycache__']

def should_ignore(path):
    """Check if path should be ignored."""
    path_str = str(path)
    return any(pattern in path_str for pattern in IGNORE_PATTERNS)

def is_internal_link(link):
    """Check if link is internal (not http/https/mail/anchor only)."""
    if link.startswith(('http://', 'https://', 'mailto:', 'tel:')):
        return False
    if link.startswith('#'):  # Anchor only
        return False
    return True

def normalize_path(link):
    """Normalize the link path by removing anchors and URL decoding."""
    # Remove anchor
    if '#' in link:
        link = link.split('#')[0]
    # URL decode
    link = unquote(link)
    return link

def resolve_link(source_file, link):
    """Resolve a relative link to an absolute path."""
    source_dir = source_file.parent
    normalized = normalize_path(link)
    if not normalized:  # Was just an anchor
        return None
    
    # Handle relative paths
    try:
        resolved = (source_dir / normalized).resolve()
        return resolved
    except Exception as e:
        return None

def scan_file(file_path):
    """Scan a markdown file for links and return list of (line_num, link_text, link_target)."""
    links = []
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                for match in LINK_PATTERN.finditer(line):
                    link_text = match.group(1)
                    link_target = match.group(2)
                    if is_internal_link(link_target):
                        links.append((line_num, link_text, link_target))
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    return links

def find_possible_targets(broken_path, base_dir):
    """Try to find possible matching targets for a broken link."""
    path_name = Path(broken_path).name
    possible = []
    
    for root, dirs, files in os.walk(base_dir):
        # Filter out ignored directories
        dirs[:] = [d for d in dirs if not should_ignore(Path(root) / d)]
        
        for f in files:
            if f == path_name or f.replace(' ', '%20') == path_name:
                possible.append(Path(root) / f)
    
    return possible[:5]  # Limit to top 5

def main():
    print(f"Scanning {BASE_DIR} for markdown files...")
    
    broken_links = []
    valid_links = 0
    total_files = 0
    
    # Find all markdown files
    for md_file in BASE_DIR.rglob('*.md'):
        if should_ignore(md_file):
            continue
            
        total_files += 1
        links = scan_file(md_file)
        
        for line_num, link_text, link_target in links:
            resolved = resolve_link(md_file, link_target)
            
            if resolved is None:
                continue  # Anchor-only links
                
            if resolved.exists():
                valid_links += 1
            else:
                # Try with common variations
                exists = False
                variations = [
                    resolved,
                    Path(str(resolved).replace('%20', ' ')),
                    Path(str(resolved).replace(' ', '%20')),
                ]
                
                for var in variations:
                    if var.exists():
                        exists = True
                        valid_links += 1
                        break
                
                if not exists:
                    rel_source = md_file.relative_to(BASE_DIR)
                    possible = find_possible_targets(resolved, BASE_DIR)
                    broken_links.append({
                        'source_file': str(rel_source),
                        'line': line_num,
                        'link_text': link_text,
                        'link_target': link_target,
                        'resolved_to': str(resolved),
                        'possible_matches': [str(p.relative_to(BASE_DIR)) for p in possible]
                    })
    
    # Generate report
    print(f"\n{'='*60}")
    print(f"LINK SCAN REPORT")
    print(f"{'='*60}")
    print(f"Total markdown files scanned: {total_files}")
    print(f"Valid internal links: {valid_links}")
    print(f"Broken links found: {len(broken_links)}")
    print(f"{'='*60}\n")
    
    # Save detailed report to JSON
    report_path = BASE_DIR / 'broken_links_report.json'
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump({
            'summary': {
                'total_files': total_files,
                'valid_links': valid_links,
                'broken_links': len(broken_links)
            },
            'broken_links': broken_links
        }, f, indent=2)
    
    print(f"\n[+] Detailed report saved to: {report_path}")

    if broken_links:
        print("BROKEN LINKS:\n")
        
        # Group by source file
        by_file = defaultdict(list)
        for bl in broken_links:
            by_file[bl['source_file']].append(bl)
        
        for source, links in sorted(by_file.items()):
            print(f"\n[F] {source}")
            print("-" * 50)
            for link in links:
                try:
                    print(f"  Line {link['line']}: [{link['link_text'][:40]}...]")
                    print(f"    Target: {link['link_target']}")
                    if link['possible_matches']:
                        print(f"    Possible matches:")
                        for pm in link['possible_matches']:
                            print(f"      + {pm}")
                    print()
                except UnicodeEncodeError:
                    print(f"  Line {link['line']}: [Link text contains unicode]")

    return broken_links

if __name__ == '__main__':
    broken = main()
