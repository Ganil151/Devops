#!/usr/bin/env python3
"""
DevOps Directory Audit Script
Scans the entire Devops directory and creates a comprehensive inventory
of all files, directories, and their metadata.
"""

import os
import json
from pathlib import Path
from collections import defaultdict
import re

class DevOpsAuditor:
    def __init__(self, root_path):
        self.root_path = Path(root_path)
        self.inventory = {
            'directories': [],
            'files': {
                'markdown': [],
                'shell': [],
                'python': [],
                'go': [],
                'images': [],
                'yaml': [],
                'terraform': [],
                'other': []
            },
            'statistics': defaultdict(int),
            'links': [],
            'mermaid_diagrams': []
        }
    
    def scan(self):
        """Perform comprehensive directory scan"""
        print(f"[*] Scanning directory: {self.root_path}")
        
        for root, dirs, files in os.walk(self.root_path):
            # Skip hidden and git directories
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            
            rel_root = Path(root).relative_to(self.root_path)
            
            # Record directory
            if str(rel_root) != '.':
                self.inventory['directories'].append(str(rel_root))
            
            # Process files
            for file in files:
                if file.startswith('.'):
                    continue
                    
                file_path = Path(root) / file
                rel_path = file_path.relative_to(self.root_path)
                
                file_info = {
                    'path': str(rel_path),
                    'name': file,
                    'size': file_path.stat().st_size,
                    'extension': file_path.suffix
                }
                
                # Categorize by type
                if file.endswith('.md'):
                    self.inventory['files']['markdown'].append(file_info)
                    self._scan_markdown_file(file_path, rel_path)
                elif file.endswith('.sh'):
                    self.inventory['files']['shell'].append(file_info)
                elif file.endswith('.py'):
                    self.inventory['files']['python'].append(file_info)
                elif file.endswith('.go'):
                    self.inventory['files']['go'].append(file_info)
                elif file.endswith(('.png', '.jpg', '.jpeg', '.svg', '.gif')):
                    self.inventory['files']['images'].append(file_info)
                elif file.endswith(('.yml', '.yaml')):
                    self.inventory['files']['yaml'].append(file_info)
                elif file.endswith('.tf'):
                    self.inventory['files']['terraform'].append(file_info)
                else:
                    self.inventory['files']['other'].append(file_info)
    
    def _scan_markdown_file(self, file_path, rel_path):
        """Scan markdown file for links and Mermaid diagrams"""
        try:
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            
            # Find markdown links [text](url)
            link_pattern = r'\[([^\]]+)\]\(([^\)]+)\)'
            links = re.findall(link_pattern, content)
            
            for text, url in links:
                if not url.startswith(('http://', 'https://', '#')):
                    self.inventory['links'].append({
                        'source': str(rel_path),
                        'text': text,
                        'target': url
                    })
            
            # Find Mermaid diagrams
            if '```mermaid' in content:
                mermaid_blocks = re.findall(r'```mermaid\n(.*?)\n```', content, re.DOTALL)
                for block in mermaid_blocks:
                    self.inventory['mermaid_diagrams'].append({
                        'file': str(rel_path),
                        'content': block[:100] + '...' if len(block) > 100 else block
                    })
        except Exception as e:
            print(f"[!] Error scanning {rel_path}: {e}")
    
    def generate_statistics(self):
        """Generate summary statistics"""
        stats = {
            'total_directories': len(self.inventory['directories']),
            'total_files': sum(len(files) for files in self.inventory['files'].values()),
            'markdown_files': len(self.inventory['files']['markdown']),
            'shell_scripts': len(self.inventory['files']['shell']),
            'python_scripts': len(self.inventory['files']['python']),
            'go_files': len(self.inventory['files']['go']),
            'images': len(self.inventory['files']['images']),
            'yaml_files': len(self.inventory['files']['yaml']),
            'terraform_files': len(self.inventory['files']['terraform']),
            'internal_links': len(self.inventory['links']),
            'mermaid_diagrams': len(self.inventory['mermaid_diagrams'])
        }
        self.inventory['statistics'] = stats
        return stats
    
    def save_report(self, output_path):
        """Save audit report to JSON"""
        stats = self.generate_statistics()
        
        # Print summary
        print("\n[+] Audit Summary:")
        print("=" * 60)
        for key, value in stats.items():
            print(f"  {key.replace('_', ' ').title()}: {value}")
        print("=" * 60)
        
        # Save to JSON
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.inventory, f, indent=2)
        
        print(f"\n[+] Full audit report saved to: {output_path}")
        
        # Generate markdown report
        self._generate_markdown_report(output_path.replace('.json', '.md'))
    
    def _generate_markdown_report(self, output_path):
        """Generate human-readable markdown report"""
        stats = self.inventory['statistics']
        
        report = f"""# DevOps Directory Audit Report

**Generated**: {os.popen('date').read().strip()}
**Root Path**: `{self.root_path}`

## Summary Statistics

| Metric | Count |
|--------|-------|
| Total Directories | {stats['total_directories']} |
| Total Files | {stats['total_files']} |
| Markdown Files | {stats['markdown_files']} |
| Shell Scripts | {stats['shell_scripts']} |
| Python Scripts | {stats['python_scripts']} |
| Go Files | {stats['go_files']} |
| Images | {stats['images']} |
| YAML Files | {stats['yaml_files']} |
| Terraform Files | {stats['terraform_files']} |
| Internal Links | {stats['internal_links']} |
| Mermaid Diagrams | {stats['mermaid_diagrams']} |

## Directory Structure

### Beginner Level
- Directories: {len([d for d in self.inventory['directories'] if d.startswith('1-Beginner')])}

### Intermediate Level
- Directories: {len([d for d in self.inventory['directories'] if d.startswith('2-Intermediate')])}

### Advanced Level
- Directories: {len([d for d in self.inventory['directories'] if d.startswith('3-Advanced')])}

## File Type Breakdown

### Markdown Files ({stats['markdown_files']})
Top 10 largest markdown files:
"""
        # Sort markdown files by size
        sorted_md = sorted(self.inventory['files']['markdown'], key=lambda x: x['size'], reverse=True)[:10]
        for f in sorted_md:
            report += f"\n- `{f['path']}` ({f['size']} bytes)"
        
        report += f"""

### Images ({stats['images']})
Image files found across the repository.

### Scripts
- Shell Scripts: {stats['shell_scripts']}
- Python Scripts: {stats['python_scripts']}
- Go Files: {stats['go_files']}

## Link Analysis

Total internal links found: **{stats['internal_links']}**

### Potentially Broken Links
Links that may break after reorganization:
"""
        
        # Identify links that go up multiple levels
        deep_links = [link for link in self.inventory['links'] if link['target'].count('../') > 2]
        for link in deep_links[:20]:  # Show first 20
            report += f"\n- In `{link['source']}`: `{link['target']}`"
        
        report += f"""

## Mermaid Diagrams

Total Mermaid diagrams found: **{stats['mermaid_diagrams']}**

Files containing Mermaid diagrams:
"""
        for diag in self.inventory['mermaid_diagrams'][:10]:
            report += f"\n- `{diag['file']}`"
        
        report += """

## Recommendations

1. **Before Reorganization**:
   - Create backup of entire directory
   - Review all deep relative links (3+ levels up)
   - Document current module dependencies

2. **During Reorganization**:
   - Use automated link-fixing script
   - Validate Mermaid diagrams after move
   - Check image paths in all markdown files

3. **After Reorganization**:
   - Run link validation
   - Test build/compile of all scripts
   - Verify all images load correctly

---

**Note**: This is an automated audit. Manual review recommended before proceeding with reorganization.
"""
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"[+] Markdown report saved to: {output_path}")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        root_path = sys.argv[1]
    else:
        root_path = "C:/Users/Ganil/Documents/Devops"
    
    auditor = DevOpsAuditor(root_path)
    auditor.scan()
    auditor.save_report(os.path.join(root_path, "audit_report.json"))
    
    print("\n[+] Audit complete!")
