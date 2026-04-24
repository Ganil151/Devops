import os
import re
from pathlib import Path

def update_links(root_path):
    root = Path(root_path)
    # Simple regex for markdown links
    link_pattern = re.compile(r'\[([^\]]+)\]\(([^)]+)\)')

    for dirpath, dirnames, filenames in os.walk(root):
        if any(part.startswith('.') for part in Path(dirpath).parts):
            continue
        for f in filenames:
            if f.endswith('.md'):
                p = Path(dirpath) / f
                try:
                    content = p.read_text(encoding='utf-8')
                    
                    def replace_link(match):
                        label = match.group(1)
                        url = match.group(2)
                        # Ignore external links or anchor links
                        if url.startswith('http') or url.startswith('#') or url.startswith('mailto:'):
                            return match.group(0)
                        
                        # Fix: Standardize to kebab-case
                        # We only target local paths that don't look like protocols
                        new_url = url.lower().replace(' ', '-').replace('_', '-')
                        return f"[{label}]({new_url})"

                    new_content = link_pattern.sub(replace_link, content)
                    if content != new_content:
                        p.write_text(new_content, encoding='utf-8')
                except (UnicodeDecodeError, PermissionError):
                    continue
                    # print(f"  [FIXED LINKS] {p}")

if __name__ == "__main__":
    update_links("/home/gsmash/Documents/Devops")
    print("✅ All internal README links updated to Kebab-Case.")
