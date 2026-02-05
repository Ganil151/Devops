#!/usr/bin/env python3
"""
DevOps Repository Sanitization, Deep-Dive & Purge Audit Script
Performs comprehensive structural, content, and hygiene audit

@TRINITY: Repo Auditor | python 00-Resources/01-Scripts-Code/Maintenance/repository_audit.py
"""

import os
import re
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Set, Tuple

class DevOpsRepositoryAuditor:
    def __init__(self, tree_file: str, base_path: str):
        self.tree_file = tree_file
        self.base_path = Path(base_path)
        self.issues = defaultdict(list)
        self.purge_list = []
        self.hollow_folders = []
        self.duplicate_files = defaultdict(list)
        self.administrative_clutter = []
        
        # Patterns for administrative clutter
        self.clutter_patterns = [
            r'CLEANUP_REPORT\.md$',
            r'error_log\.log$',
            r'temp_notes\.txt$',
            r'tree_backup\.txt$',
            r'\.swp$',
            r'\.log$',
            r'_backup\.',
            r'_old\.',
            r'_temp\.',
            r'-old\.',
            r'-backup\.',
            r'broken_links_report\.json$',
            r'unfixable_links\.json$',
        ]
        
        # Required structure patterns
        self.required_structure = {
            'Boilerplates': ['README.md'],
            'challenges': ['README.md'],
            'solutions': ['README.md']
        }
        
    def parse_tree(self) -> Dict[str, List[str]]:
        """Parse tree.txt and build directory structure"""
        structure = defaultdict(list)
        current_path = []
        
        with open(self.tree_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                # Skip empty lines
                if not line.strip():
                    continue
                    
                # Calculate depth from tree characters
                depth = (len(line) - len(line.lstrip('│ ├└─'))) // 4
                
                # Extract filename/dirname
                name = line.strip().split('├── ')[-1].split('└── ')[-1].strip()
                if not name or name == '.':
                    continue
                
                # Determine if it's a directory (no extension or ends with /)
                is_dir = '.' not in name or name.endswith('/')
                
                # Build current path
                if depth < len(current_path):
                    current_path = current_path[:depth]
                
                if depth > 0:
                    full_path = '/'.join(current_path + [name])
                else:
                    full_path = name
                    current_path = [name]
                
                if is_dir:
                    current_path = current_path[:depth] + [name]
                    structure['/'.join(current_path)] = []
                else:
                    parent = '/'.join(current_path[:depth])
                    if parent:
                        structure[parent].append(name)
        
        return structure
    
    def identify_hollow_folders(self, structure: Dict[str, List[str]]) -> List[str]:
        """Identify folders that are empty or only contain README.md"""
        hollow = []
        
        for folder, files in structure.items():
            # Skip root and resource folders
            if folder in ['.', '00-Resources', '8-Porjects-Showcase']:
                continue
            
            # Empty folder
            if not files:
                hollow.append(folder)
                self.issues['hollow_folders'].append({
                    'path': folder,
                    'reason': 'Completely empty folder'
                })
            
            # Only README.md, no supporting scripts/labs
            elif len(files) == 1 and files[0] == 'README.md':
                # Check if this should have Boilerplates/challenges/solutions
                if any(tier in folder for tier in ['1-Beginner', '2-Intermediate', '3-Advanced']):
                    hollow.append(folder)
                    self.issues['hollow_folders'].append({
                        'path': folder,
                        'reason': 'Only README.md, missing Boilerplates/challenges/solutions'
                    })
        
        return hollow
    
    def identify_duplicates(self, structure: Dict[str, List[str]]) -> Dict[str, List[str]]:
        """Identify duplicate files across the repository"""
        file_locations = defaultdict(list)
        
        for folder, files in structure.items():
            for file in files:
                file_locations[file].append(folder)
        
        # Find files that appear in multiple locations
        duplicates = {
            file: locations 
            for file, locations in file_locations.items() 
            if len(locations) > 1 and file not in ['README.md', '.gitignore']
        }
        
        return duplicates
    
    def identify_administrative_clutter(self, structure: Dict[str, List[str]]) -> List[str]:
        """Identify administrative clutter files"""
        clutter = []
        
        for folder, files in structure.items():
            for file in files:
                for pattern in self.clutter_patterns:
                    if re.search(pattern, file, re.IGNORECASE):
                        full_path = f"{folder}/{file}"
                        clutter.append(full_path)
                        self.issues['administrative_clutter'].append({
                            'path': full_path,
                            'reason': f'Matches clutter pattern: {pattern}'
                        })
                        break
        
        return clutter
    
    def check_required_structure(self, structure: Dict[str, List[str]]) -> List[Dict]:
        """Check for required folder structure in learning paths"""
        missing_structure = []
        
        for folder in structure.keys():
            # Only check learning path folders
            if not any(tier in folder for tier in ['1-Beginner', '2-Intermediate', '3-Advanced']):
                continue
            
            # Skip if it's a Part or Phase folder
            if 'Part-' in folder or 'Phase-' in folder:
                continue
            
            # Check for required subfolders
            for required_folder, required_files in self.required_structure.items():
                subfolder_path = f"{folder}/{required_folder}"
                if subfolder_path not in structure:
                    missing_structure.append({
                        'parent': folder,
                        'missing': required_folder,
                        'type': 'folder'
                    })
                    self.issues['missing_structure'].append({
                        'path': folder,
                        'missing': required_folder
                    })
        
        return missing_structure
    
    def generate_health_report(self) -> str:
        """Generate comprehensive health and hygiene report"""
        report = []
        report.append("# 🏥 DevOps Repository Health & Hygiene Report\n")
        report.append(f"**Audit Date**: 2026-01-24\n")
        report.append(f"**Repository**: C:\\Users\\Ganil\\Documents\\Devops\\\n\n")
        report.append("---\n\n")
        
        # Summary table
        report.append("## 📊 Executive Summary\n\n")
        report.append("| Category | Issues Found | Severity |\n")
        report.append("|----------|--------------|----------|\n")
        
        total_issues = sum(len(v) for v in self.issues.values())
        
        for category, items in self.issues.items():
            severity = self._get_severity(category)
            report.append(f"| {category.replace('_', ' ').title()} | {len(items)} | {severity} |\n")
        
        report.append(f"| **TOTAL** | **{total_issues}** | - |\n\n")
        
        # Detailed findings
        report.append("---\n\n")
        report.append("## 🔍 Detailed Findings\n\n")
        
        for category, items in self.issues.items():
            if not items:
                continue
            
            report.append(f"### {category.replace('_', ' ').title()}\n\n")
            report.append(f"**Count**: {len(items)}\n\n")
            
            # Show first 10 examples
            for i, item in enumerate(items[:10], 1):
                if isinstance(item, dict):
                    report.append(f"{i}. **Path**: `{item.get('path', 'N/A')}`\n")
                    report.append(f"   - **Reason**: {item.get('reason', 'N/A')}\n")
                else:
                    report.append(f"{i}. `{item}`\n")
            
            if len(items) > 10:
                report.append(f"\n*...and {len(items) - 10} more*\n")
            
            report.append("\n")
        
        return ''.join(report)
    
    def generate_purge_list(self) -> str:
        """Generate list of files to be deleted"""
        report = []
        report.append("# 🗑️ Repository Purge List\n\n")
        report.append("**WARNING**: Review carefully before deletion!\n\n")
        report.append("---\n\n")
        
        report.append("## Administrative Clutter Files\n\n")
        report.append("These files are temporary artifacts and can be safely removed:\n\n")
        
        for item in self.issues.get('administrative_clutter', []):
            report.append(f"- [ ] `{item['path']}`\n")
            report.append(f"  - Reason: {item['reason']}\n")
        
        report.append("\n---\n\n")
        report.append("## Duplicate Files\n\n")
        report.append("Review these duplicates and consolidate to a single 'Golden Version':\n\n")
        
        for file, locations in self.duplicate_files.items():
            if len(locations) > 1:
                report.append(f"### `{file}`\n\n")
                report.append(f"Found in {len(locations)} locations:\n\n")
                for loc in locations:
                    report.append(f"- `{loc}`\n")
                report.append("\n")
        
        return ''.join(report)
    
    def _get_severity(self, category: str) -> str:
        """Determine severity level for issue category"""
        severity_map = {
            'hollow_folders': '⚠️ Medium',
            'administrative_clutter': '🟢 Low',
            'missing_structure': '🔴 High',
            'duplicates': '⚠️ Medium'
        }
        return severity_map.get(category, '🟡 Unknown')
    
    def run_audit(self) -> Tuple[str, str]:
        """Run complete audit and return reports"""
        print("[INFO] Parsing repository tree...")
        structure = self.parse_tree()
        
        print(f"[INFO] Found {len(structure)} directories")
        
        print("[INFO] Identifying hollow folders...")
        self.hollow_folders = self.identify_hollow_folders(structure)
        
        print("[INFO] Identifying duplicates...")
        self.duplicate_files = self.identify_duplicates(structure)
        self.issues['duplicates'] = [
            {'file': file, 'locations': locs} 
            for file, locs in self.duplicate_files.items()
        ]
        
        print("[INFO] Identifying administrative clutter...")
        self.administrative_clutter = self.identify_administrative_clutter(structure)
        
        print("[INFO] Checking required structure...")
        self.check_required_structure(structure)
        
        print("[INFO] Generating reports...")
        health_report = self.generate_health_report()
        purge_list = self.generate_purge_list()
        
        return health_report, purge_list


def main():
    """Main execution function"""
    base_path = r"C:\Users\Ganil\Documents\Devops"
    tree_file = os.path.join(base_path, "tree.txt")
    
    if not os.path.exists(tree_file):
        print(f"[ERROR] tree.txt not found at {tree_file}")
        return
    
    print("[INFO] Starting DevOps Repository Audit...")
    print("=" * 60)
    
    auditor = DevOpsRepositoryAuditor(tree_file, base_path)
    health_report, purge_list = auditor.run_audit()
    
    # Save reports
    health_report_path = os.path.join(base_path, "REPOSITORY_HEALTH_REPORT.md")
    purge_list_path = os.path.join(base_path, "PURGE_LIST.md")
    
    with open(health_report_path, 'w', encoding='utf-8') as f:
        f.write(health_report)
    
    with open(purge_list_path, 'w', encoding='utf-8') as f:
        f.write(purge_list)
    
    print("=" * 60)
    print("[SUCCESS] Audit complete!")
    print(f"[REPORT] Health Report: {health_report_path}")
    print(f"[REPORT] Purge List: {purge_list_path}")
    print(f"\n[SUMMARY]")
    print(f"   - Hollow Folders: {len(auditor.hollow_folders)}")
    print(f"   - Duplicate Files: {len(auditor.duplicate_files)}")
    print(f"   - Administrative Clutter: {len(auditor.administrative_clutter)}")
    print(f"   - Total Issues: {sum(len(v) for v in auditor.issues.values())}")


if __name__ == "__main__":
    main()
