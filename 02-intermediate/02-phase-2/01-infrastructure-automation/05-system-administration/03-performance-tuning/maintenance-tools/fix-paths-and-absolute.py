import os
import re

ROOT_DIR = r"C:\Users\Ganil\Documents\Devops"

# Regex for file:/// links and Windows absolute paths (C:/Users/...)
ABSOLUTE_FILE_REGEX = re.compile(r'!\[(.*?)\]\(((?:file:///|[a-zA-Z]:[\\/]).*?)\)')

def fix_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return 0

    original_content = content
    
    # Fix 1: Absolute file paths (OSI Model issue)
    def replace_absolute(match):
        alt_text = match.group(1)
        bad_path = match.group(2)
        print(f"Fixing absolute path in {os.path.basename(file_path)}: {bad_path}")
        return f"> **⚠️ Missing Image**: *{alt_text}* (Original local path: '{bad_path}')"
    
    content = ABSOLUTE_FILE_REGEX.sub(replace_absolute, content)

    # Fix 2: RDS Typo .../ -> ../
    if ".../" in content:
        print(f"Fixing typo '.../' in {os.path.basename(file_path)}")
        content = content.replace(".../", "../")

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return 1
    return 0

def main():
    print(f"Scanning {ROOT_DIR} for path issues...")
    total_fixed = 0
    
    for root, dirs, files in os.walk(ROOT_DIR):
        for file in files:
            if file.endswith('.md'):
                total_fixed += fix_file(os.path.join(root, file))
                
    print(f"Files fixed: {total_fixed}")

if __name__ == "__main__":
    main()