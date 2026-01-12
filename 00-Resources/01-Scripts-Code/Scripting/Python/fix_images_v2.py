import os
import re

def fix_image_paths(base_dir):
    image_hub_dir = os.path.join(base_dir, "00-Resources", "03-Images-Diagrams")
    
    # Pre-map all images in the hub for fast lookup
    image_map = {}
    for r, d, f in os.walk(image_hub_dir):
        for file in f:
            if file.lower().endswith((".png", ".jpg", ".jpeg", ".gif", ".svg")):
                # Store the absolute path of the image
                image_map[file] = os.path.join(r, file)

    for root, dirs, files in os.walk(base_dir):
        if ".git" in root or "00-Resources" in root: continue
        for file in files:
            if file.endswith(".md"):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                except: continue
                
                new_content = content
                
                # Find all image links: ![alt](path)
                # Regex handles spaces and characters in paths
                matches = re.finditer(r'!\[(.*?)\]\((.*?)\)', content)
                for match in matches:
                    alt = match.group(1)
                    path = match.group(2)
                    clean_path = path.strip().strip("'").strip('"')
                    filename = os.path.basename(clean_path)
                    
                    # If it's an image file
                    if filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif", ".svg")):
                        abs_path = os.path.normpath(os.path.join(root, clean_path))
                        
                        # If the path doesn't exist locally
                        if not os.path.exists(abs_path):
                            if filename in image_map:
                                # Found the image in the hub!
                                hub_img_abs = image_map[filename]
                                # Calculate correct relative path from the MD file to the IMAGE file
                                new_rel_path = os.path.relpath(hub_img_abs, root)
                                new_rel_path = new_rel_path.replace("\\", "/")
                                
                                # Replace only this specific occurrence
                                old_link = f"({path})"
                                new_link = f"({new_rel_path})"
                                new_content = new_content.replace(old_link, new_link)
                                print(f"FIXED: {file} -> {filename} to {new_rel_path}")
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)

if __name__ == "__main__":
    fix_image_paths("/home/ganil/Documents/Devops")
