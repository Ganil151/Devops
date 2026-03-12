import os
import re

base_dir = r"C:\Users\Ganil\Documents\Devops\1-Beginner\02-Phase-2\01-Automation\02-Python-Basics"

# Define the pattern to find links like ../02-Data-Structures/
# We want to change them to ../Part-02-Data-Structures/
pattern = re.compile(r'(\.\.\/)([0-9]{2}-)')
replacement = r'\1Part-\2'

# We also need to handle the case where they might be [Name](Part-X-Fundamentals/01-Module/README.md)
# Since we flattened it, the Part-X-Fundamentals/ part should be removed.
# Pattern: (\[.*?\]\()Part-[0-9]-.*?\/([0-9]{2}-.*?\/README\.md)
# Replacement: \1Part-\2
flatten_pattern = re.compile(r'(\[.*?\]\()Part-[0-9]-.*?\/([0-9]{2}-.*?\/README\.md)')
flatten_replacement = r'\1Part-\2'

# Also handle (../Part-4-Professional-Standards/99-Topical-Extras/01-Working-with-the-Web.md)
# Should become (../Part-18-Working-with-the-Web/README.md)
topical_map = {
    "01-Working-with-the-Web.md": "Part-18-Working-with-the-Web/README.md",
    "02-Web-Automation.md": "Part-19-Web-Automation/README.md",
    "03-Micro-Frameworks-and-Async.md": "Part-20-Micro-Frameworks-and-Async/README.md"
}

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Update Part numbering to Part-XX
    new_content = pattern.sub(replacement, content)
    
    # 2. Flatten sub-directory paths
    new_content = flatten_pattern.sub(flatten_replacement, new_content)
    
    # 3. Handle Topical Extras
    for old, new in topical_map.items():
        new_content = new_content.replace(old, new)
        # Also handle if they were in the 99-Topical-Extras folder link
        if "99-Topical-Extras/" in new_content:
             new_content = new_content.replace(f"99-Topical-Extras/{old}", f"{new}")

    if content != new_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith(".md"):
            update_file(os.path.join(root, file))
