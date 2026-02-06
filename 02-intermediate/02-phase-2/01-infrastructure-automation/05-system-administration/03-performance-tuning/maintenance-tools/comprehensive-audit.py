import os
import re
import json
from pathlib import Path
from datetime import datetime

# Configuration
ROOT_PATH = Path(r"C:\Users\Ganil\Documents\Devops")
OUTPUT_DIR = ROOT_PATH / "00-Resources" / "06-Docs"

# Regex Patterns
IMG_PATTERN = re.compile(r'!\[.*?\]\((.*?)\)')
LINK_PATTERN = re.compile(r'\[.*?\]\((.*?)\)')
MERMAID_PATTERN = re.compile(r'```mermaid')
PART_DIR_PATTERN = re.compile(r'Part-\d+.*')

class DevOpsAuditor:
    def __init__(self, root_path):
        self.root = Path(root_path)
        self.issues = []
        self.stats = {
            'modules_checked': 0,
            'files_scanned': 0,
            'images_found': 0,
            'links_found': 0,
            'mermaid_blocks': 0,
            'missing_standards': 0,
            'broken_links': 0,
            'broken_images': 0,
            'absolute_paths': 0
        }
        self.health_score = 100

    def log_issue(self, category, file_path, message, severity='Medium'):
        self.issues.append({
            'category': category,
            'file': str(file_path),
            'message': message,
            'severity': severity
        })
        
        deduction = {'Low': 0.1, 'Medium': 0.5, 'High': 1.0, 'Critical': 5.0}
        self.health_score -= deduction.get(severity, 0.5)

    def check_structure(self):
        """Audit 1-Beginner, 2-Intermediate, 3-Advanced hierarchy"""
        levels = ['1-Beginner', '2-Intermediate', '3-Advanced']
        
        for level in levels:
            level_path = self.root / level
            if not level_path.exists():
                self.log_issue('Structure', level_path, f"Missing top-level directory: {level}", 'Critical')
                continue
                
            # Walk through Phases and Parts
            for root, dirs, files in os.walk(level_path):
                root_path = Path(root)
                dir_name = root_path.name
                
                if PART_DIR_PATTERN.match(dir_name):
                    self.stats['modules_checked'] += 1
                    self._check_standard_files(root_path)

    def _check_standard_files(self, part_path):
        required = ['README.md', 'CHALLENGES.md', 'Boilerplates']
        for item in required:
            item_path = part_path / item
            if not item_path.exists():
                self.stats['missing_standards'] += 1
                self.log_issue('Standardization', part_path, f"Missing standard component: {item}", 'Medium')

    def check_visual_mapping(self):
        """Ensure Intermediate/Advanced modules have diagrams"""
        levels = {'2-Intermediate': 'Process Flowchart', '3-Advanced': 'Architectural Diagram'}
        
        for level, req_type in levels.items():
            level_path = self.root / level
            if not level_path.exists(): continue
            
            for root, dirs, files in os.walk(level_path):
                root_path = Path(root)
                if PART_DIR_PATTERN.match(root_path.name):
                    # Check if any md file in this part has mermaid
                    has_mermaid = False
                    for md_file in root_path.glob('*.md'):
                        try:
                            if '```mermaid' in md_file.read_text(encoding='utf-8', errors='ignore'):
                                has_mermaid = True
                                break
                        except: pass
                    
                    if not has_mermaid:
                        self.log_issue('Visual Mapping', root_path, f"Missing {req_type} (Mermaid) in module", 'Medium')

    def scan_markdown_files(self):
        """Scan all .md files for assets, links, and mermaid"""
        for md_file in self.root.rglob('*.md'):
            self.stats['files_scanned'] += 1
            try:
                content = md_file.read_text(encoding='utf-8', errors='ignore')
                self._audit_images(md_file, content)
                self._audit_links(md_file, content)
                self._audit_mermaid(md_file, content)
                self._check_navigation(md_file, content)
            except Exception as e:
                self.log_issue('File Access', md_file, f"Could not read file: {str(e)}", 'High')

    def _audit_images(self, file_path, content):
        images = IMG_PATTERN.findall(content)
        for img_path in images:
            self.stats['images_found'] += 1
            
            # Check absolute paths
            if img_path.startswith(('C:', '/', '\\')):
                self.stats['absolute_paths'] += 1
                self.log_issue('Asset Visibility', file_path, f"Absolute image path detected: {img_path}", 'High')
                continue
                
            # Check existence
            if img_path.startswith('http'):
                continue # Skip external
                
            # Resolve relative path
            clean_path = img_path.split('?')[0].split('#')[0]
            try:
                resolved_path = (file_path.parent / clean_path).resolve()
                
                if not resolved_path.exists():
                    self.stats['broken_images'] += 1
                    self.log_issue('Broken Asset', file_path, f"Image not found: {img_path}", 'High')
                
                # Check storage location
                if 'assets' not in str(resolved_path).lower() and 'images' not in str(resolved_path).lower():
                     self.log_issue('Storage Optimization', file_path, f"Image not in /assets or /images folder: {img_path}", 'Low')
            except Exception:
                self.log_issue('Broken Asset', file_path, f"Malformed image path: {img_path}", 'Medium')

    def _audit_links(self, file_path, content):
        links = LINK_PATTERN.findall(content)
        for link in links:
            if link.startswith(('http', 'mailto', '#')):
                continue
                
            self.stats['links_found'] += 1
            clean_link = link.split('#')[0] # Remove anchors
            if not clean_link: continue

            try:
                resolved_link = (file_path.parent / clean_link).resolve()
                if not resolved_link.exists():
                    self.stats['broken_links'] += 1
                    self.log_issue('Broken Link', file_path, f"Dead link: {link}", 'Medium')
            except Exception:
                self.stats['broken_links'] += 1
                self.log_issue('Broken Link', file_path, f"Malformed link: {link}", 'Medium')

    def _audit_mermaid(self, file_path, content):
        if '```mermaid' in content:
            self.stats['mermaid_blocks'] += 1
            # Basic syntax check: ensure block is closed
            blocks = content.split('```mermaid')
            for i in range(1, len(blocks)):
                if '```' not in blocks[i]:
                    self.log_issue('Mermaid Syntax', file_path, "Unclosed Mermaid block detected", 'High')

    def _check_navigation(self, file_path, content):
        if file_path.name.lower() == 'readme.md':
            # Simple check for navigation keywords
            if "Back to Overview" not in content and "Next Step" not in content:
                 self.log_issue('Navigation', file_path, "Missing 'Back to Overview' or 'Next Step' navigation links", 'Low')

    def generate_report(self):
        self.health_score = max(0, round(self.health_score, 2))
        
        report = f"""# 🏥 DevOps Repository Health Report

**Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Health Score**: {self.health_score}/100

## 📊 Statistics
- **Modules Checked**: {self.stats['modules_checked']}
- **Files Scanned**: {self.stats['files_scanned']}
- **Broken Links**: {self.stats['broken_links']}
- **Broken Images**: {self.stats['broken_images']}
- **Missing Standards**: {self.stats['missing_standards']}
- **Absolute Paths**: {self.stats['absolute_paths']}
- **Mermaid Blocks**: {self.stats['mermaid_blocks']}

## 🚨 Prioritized Fixes

| Severity | Category | File | Issue |
| :--- | :--- | :--- | :--- |
"""
        # Sort issues by severity
        severity_order = {'Critical': 0, 'High': 1, 'Medium': 2, 'Low': 3}
        sorted_issues = sorted(self.issues, key=lambda x: severity_order.get(x['severity'], 4))
        
        for issue in sorted_issues:
            try:
                rel_path = str(Path(issue['file']).relative_to(self.root))
            except ValueError:
                rel_path = issue['file']
            report += f"| **{issue['severity']}** | {issue['category']} | `{rel_path}` | {issue['message']} |\n"
            
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        
        with open(OUTPUT_DIR / "Repository_Health_Score.md", "w", encoding="utf-8") as f:
            f.write(report)
            
        with open(OUTPUT_DIR / "audit_data.json", "w", encoding="utf-8") as f:
            json.dump({'stats': self.stats, 'issues': self.issues, 'score': self.health_score}, f, indent=2)
            
        print(f"Audit Complete. Health Score: {self.health_score}/100")
        print(f"Report saved to: {OUTPUT_DIR / 'Repository_Health_Score.md'}")

if __name__ == "__main__":
    auditor = DevOpsAuditor(ROOT_PATH)
    print("Starting Structure Audit...")
    auditor.check_structure()
    print("Checking Visual Mapping...")
    auditor.check_visual_mapping()
    print("Scanning Files...")
    auditor.scan_markdown_files()
    print("Generating Report...")
    auditor.generate_report()