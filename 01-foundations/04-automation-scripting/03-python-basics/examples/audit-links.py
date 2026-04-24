import os
import re
from pathlib import Path
from urllib.parse import unquote

def check_links_in_file(file_path, base_root):
    broken_links = []
    mermaid_blocks = 0
    images_found = []
    broken_images = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [f"Error reading file {file_path}: {e}"], 0, [], []

    # Find all Markdown links: [label](path)
    links = re.findall(r'\[.*?\]\((?!http|mailto)(.*?)\)', content)
    
    # Find all image links: ![label](path)
    images = re.findall(r'!\[.*?\]\((?!http)(.*?)\)', content)
    
    # Count mermaid blocks
    mermaid_blocks = len(re.findall(r'```mermaid', content))

    file_dir = os.path.dirname(file_path)

    for link in links:
        # Remove anchors
        clean_link = unquote(link.split('#')[0])
        if not clean_link or clean_link.startswith('file:///tmp'):
            if clean_link.startswith('file:///tmp'):
                broken_links.append(link)
            continue
        
        # Handle file:/// protocol locally if it points to the repo
        if clean_link.startswith('file:///'):
            # Just mark it as broken/suspicious for now
            broken_links.append(link)
            continue

        # Determine target path
        target_path = Path(file_dir) / clean_link
        if not target_path.exists():
            broken_links.append(link)

    for img in images:
        clean_img = unquote(img.split('?')[0])
        if clean_img.startswith('file:///tmp'):
            broken_images.append(img)
            continue
            
        target_path = Path(file_dir) / clean_img
        if not target_path.exists():
            broken_images.append(img)
        images_found.append(img)

    return broken_links, mermaid_blocks, images_found, broken_images

def main():
    root_dir = r'C:\Users\Ganil\Documents\Devops'
    report = []
    total_files = 0
    total_broken_links = 0
    total_broken_images = 0

    target_folders = ['1-Beginner', '2-Intermediate', '3-Advanced', '00-Resources', 'Quizzes']
    
    root_readme = os.path.join(root_dir, 'README.md')
    if os.path.exists(root_readme):
        bl, mb, img, bi = check_links_in_file(root_readme, root_dir)
        if bl or bi:
            report.append(f"### {root_readme}")
            if bl: report.append(f"Broken Links: {bl}")
            if bi: report.append(f"Broken Images: {bi}")
            total_broken_links += len(bl)
            total_broken_images += len(bi)

    for folder in target_folders:
        folder_path = os.path.join(root_dir, folder)
        if not os.path.exists(folder_path):
            continue
            
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                if file.endswith('.md'):
                    total_files += 1
                    file_path = os.path.join(root, file)
                    bl, mb, img, bi = check_links_in_file(file_path, root_dir)
                    
                    if bl or bi:
                        report.append(f"### {file_path}")
                        if bl: report.append(f"Broken Links: {bl}")
                        if bi: report.append(f"Broken Images: {bi}")
                        total_broken_links += len(bl)
                        total_broken_images += len(bi)

    print(f"Total files checked: {total_files}")
    print(f"Total broken links: {total_broken_links}")
    print(f"Total broken images: {total_broken_images}")
    print("\n".join(report))

if __name__ == "__main__":
    main()
