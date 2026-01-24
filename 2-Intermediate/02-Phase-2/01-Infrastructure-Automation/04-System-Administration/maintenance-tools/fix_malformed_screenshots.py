import os
import re

ROOT_DIR = r"C:\Users\Ganil\Documents\Devops"

# Regex to find malformed screenshot tags like <images\Screenshot (131 or <Screenshot (136
# Captures the screenshot number/name
MALFORMED_REGEX = re.compile(r'<[\w\\/]*(Screenshot \(\d+)')

def fix_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return 0

    def replace_malformed(match):
        screenshot_name = match.group(1)
        print(f"Fixing malformed tag in {os.path.basename(file_path)}: {screenshot_name}")
        # Replace with a standardized placeholder
        return f"> **⚠️ Missing Image**: *{screenshot_name}* (Original artifact: '{match.group(0)}')"

    new_content, count = MALFORMED_REGEX.subn(replace_malformed, content)
    
    if count > 0 and new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return count
    return 0

def main():
    print(f"Scanning {ROOT_DIR} for malformed screenshot tags...")
    total_fixed = 0
    
    # Target directories known to contain these artifacts
    target_dirs = [
        os.path.join(ROOT_DIR, r"2-Intermediate"),
        os.path.join(ROOT_DIR, r"00-Resources")
    ]
    
    for target_dir in target_dirs:
        for root, dirs, files in os.walk(target_dir):
            for file in files:
                if file.endswith('.md'):
                    total_fixed += fix_file(os.path.join(root, file))
                
    print(f"Malformed tags fixed: {total_fixed}")

if __name__ == "__main__":
    main()