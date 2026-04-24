#!/usr/bin/env python3
"""
🚀 DevOps Repository Health & Architecture Auditor
================================================
Performs deep structural, content, and hygiene audits on the curriculum repo.
Detects hollow folders, duplicates, administrative clutter, and structural drift.

Usage:
    python3 repository_audit.py [--fix] [--report-only]
"""

import os
import re
import argparse
from pathlib import Path
from collections import defaultdict
from datetime import datetime
from typing import List, Dict, Set, Tuple, Optional

class DevOpsRepositoryAuditor:
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path).resolve()
        self.issues = defaultdict(list)
        self.duplicate_files = defaultdict(list)
        
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
        
        # Essential subfolders for a complete module
        self.required_subfolders = ['Boilerplates', 'challenges', 'solutions']
        
    def scan_repository(self) -> Dict[str, List[str]]:
        """Scan the filesystem and build a directory structure dictionary."""
        structure = {}
        for root, dirs, files in os.walk(self.base_path):
            # Skip hidden directories like .git
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            
            relative_root = os.path.relpath(root, self.base_path)
            if relative_root == '.':
                relative_root = ""
            
            structure[relative_root] = files
        return structure

    def identify_hollow_folders(self, structure: Dict[str, List[str]]):
        """Identify folders that are empty or only contain a README.md."""
        for folder, files in structure.items():
            if not folder: continue # Skip root
            
            # Skip resource and boilerplate folders
            if any(x in folder for x in ['08-Resources', '07-Boilerplates', 'assets', 'scripts']):
                continue
            
            # Completely empty folder
            if not files:
                self.issues['hollow_folders'].append({
                    'path': folder,
                    'reason': 'Completely empty folder'
                })
            
            # Only README.md (check if it's a module folder)
            elif len(files) == 1 and files[0] == 'README.md':
                # If it's a module folder in 01/02/03, it should have subs
                if any(tier in folder for tier in ['01-Beginner', '02-Intermediate', '03-Advanced']):
                    # Skip 'Part-' and 'Phase-' containers
                    if not any(x in folder for x in ['Part-', 'Phase-']):
                        self.issues['hollow_folders'].append({
                            'path': folder,
                            'reason': 'Only README.md found; missing supporting code or subfolders'
                        })

    def identify_duplicates(self, structure: Dict[str, List[str]]):
        """Identify duplicate files across the repository."""
        file_map = defaultdict(list)
        for folder, files in structure.items():
            for f in files:
                # Skip common generic files
                if f in ['README.md', '.gitignore', 'REFERENCE.md', 'requirements.txt']:
                    continue
                file_map[f].append(folder)
        
        for filename, locations in file_map.items():
            if len(locations) > 1:
                self.issues['duplicates'].append({
                    'file': filename,
                    'locations': locations
                })

    def identify_clutter(self, structure: Dict[str, List[str]]):
        """Identify administrative clutter files."""
        for folder, files in structure.items():
            for f in files:
                for pattern in self.clutter_patterns:
                    if re.search(pattern, f, re.IGNORECASE):
                        path = os.path.join(folder, f)
                        self.issues['administrative_clutter'].append({
                            'path': path,
                            'reason': f'Matches clutter pattern: {pattern}'
                        })
                        break

    def check_module_integrity(self, structure: Dict[str, List[str]]):
        """Check if learning modules have the required structure."""
        for folder in structure:
            # Check only module-level folders
            if not any(tier in folder for tier in ['01-Beginner', '02-Intermediate', '03-Advanced']):
                continue
            
            # Simple heuristic for "Is this a module folder?"
            # (Usually 3 levels deep: 01-Beginner / 01-Phase-1 / 01-Networking)
            parts = folder.split(os.sep)
            if len(parts) < 3:
                continue
            
            # Check for phase/part containers which shouldn't necessarily have these folders
            if any(x in parts[-1] for x in ['Phase-', 'Part-']):
                continue

            for sub in self.required_subfolders:
                sub_path = os.path.join(folder, sub)
                if sub_path not in structure:
                    self.issues['structural_drift'].append({
                        'path': folder,
                        'missing': sub,
                        'reason': f'Missing required subfolder: {sub}'
                    })

    def generate_report(self) -> str:
        """Generate a production-grade markdown report."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        report = [
            "# 🏥 Repository Health Audit Report",
            f"**Generated**: {now}",
            f"**Repository Root**: `{self.base_path}`",
            "\n---\n",
            "## 📊 Executive Summary",
            "| Category | Issues Found | Severity |",
            "| :--- | :--- | :--- |"
        ]
        
        severity_map = {
            'hollow_folders': '🟡 Medium',
            'duplicates': '🟠 Medium',
            'administrative_clutter': '🟢 Low',
            'structural_drift': '🔴 High'
        }
        
        for cat in ['structural_drift', 'hollow_folders', 'duplicates', 'administrative_clutter']:
            count = len(self.issues.get(cat, []))
            report.append(f"| {cat.replace('_', ' ').title()} | {count} | {severity_map.get(cat, '⚪ Unknown')} |")
        
        total = sum(len(v) for v in self.issues.values())
        report.append(f"| **TOTAL** | **{total}** | |")
        
        report.append("\n---\n")
        report.append("## 🔍 Detailed Findings")
        
        for cat in ['structural_drift', 'hollow_folders', 'duplicates', 'administrative_clutter']:
            items = self.issues.get(cat, [])
            if not items:
                continue
                
            report.append(f"\n### {cat.replace('_', ' ').title()}")
            for i, item in enumerate(items[:15], 1):
                if cat == 'duplicates':
                    report.append(f"{i}. **Duplicate**: `{item['file']}` in:")
                    for loc in item['locations']:
                        report.append(f"   - `{loc}`")
                elif 'path' in item:
                    report.append(f"{i}. `{item['path']}` - {item.get('reason', '')}")
            
            if len(items) > 15:
                report.append(f"\n*...and {len(items) - 15} more issues in this category.*")
        
        return "\n".join(report)

    def run(self):
        print(f"🔍 Starting deep audit of {self.base_path}...")
        structure = self.scan_repository()
        
        print("📁 Analyzing folder density...")
        self.identify_hollow_folders(structure)
        
        print("👯 Detecting duplicate artifacts...")
        self.identify_duplicates(structure)
        
        print("🧹 Finding administrative clutter...")
        self.identify_clutter(structure)
        
        print("🏗️ Verifying architectural integrity...")
        self.check_module_integrity(structure)
        
        report = self.generate_report()
        report_path = self.base_path / "REPOSITORY_HEALTH_REPORT.md"
        with open(report_path, "w") as f:
            f.write(report)
            
        print(f"✅ Audit complete! Report saved to: {report_path}")
        print(f"📊 Total issues found: {sum(len(v) for v in self.issues.values())}")

def main():
    parser = argparse.ArgumentParser(description="DevOps Repository Auditor")
    parser.add_argument("--path", default=".", help="Base path to audit")
    args = parser.parse_args()
    
    # Locate project root relative to this script if run from Maintenance folder
    script_path = Path(__file__).resolve()
    if "08-Resources" in str(script_path):
        # Go up to the root (Maintenance -> Scripts-Code -> Resources -> Devops)
        base = script_path.parents[3]
    else:
        base = Path(args.path)

    auditor = DevOpsRepositoryAuditor(base_path=str(base))
    auditor.run()

if __name__ == "__main__":
    main()
