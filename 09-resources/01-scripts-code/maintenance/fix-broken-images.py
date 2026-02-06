import os
import re
import urllib.parse

ROOT_DIR = r"C:\Users\Ganil\Documents\Devops"

# Regex to find markdown images: !alt text
IMAGE_REGEX = re.compile(r'!\[(.*?)\]\((.*?)\)')

def is_image_broken(file_path, image_rel_path):
    # Ignore web links
    if image_rel_path.startswith(('http://', 'https://', 'ftp://')):
        return False
    
    # Decode URL encoding (e.g., %20 -> space)
    image_rel_path = urllib.parse.unquote(image_rel_path)
    
    # Calculate absolute path
    base_dir = os.path.dirname(file_path)
    abs_image_path = os.path.normpath(os.path.join(base_dir, image_rel_path))
    
    return not os.path.exists(abs_image_path)

def fix_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return 0

    def replace_broken(match):
        alt_text = match.group(1)
        image_path = match.group(2)
        
        if is_image_broken(file_path, image_path):
            print(f"Fixing broken image in {os.path.basename(file_path)}: {image_path}")
            # Replace with a blockquote placeholder
            return f"> **⚠️ Missing Image**: *{alt_text}* ('{image_path}')"
        return match.group(0)

    new_content, count = IMAGE_REGEX.subn(replace_broken, content)
    
    if count > 0 and new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return count
    return 0

def main():
    print(f"Scanning {ROOT_DIR} for broken images...")
    total_fixed = 0
    files_checked = 0
    
    for root, dirs, files in os.walk(ROOT_DIR):
        # Skip .git and other hidden folders
        if '.git' in dirs:
            dirs.remove('.git')
            
        for file in files:
            if file.endswith('.md'):
                files_checked += 1
                total_fixed += fix_file(os.path.join(root, file))
                
    print(f"\nScan complete.")
    print(f"Files checked: {files_checked}")
    print(f"Broken images converted to placeholders: {total_fixed}")

if __name__ == "__main__":
    main()