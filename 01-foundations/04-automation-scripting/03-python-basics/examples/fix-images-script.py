import os
import re

def fix_image_paths(base_dir):
    image_hub_rel = "00-Resources/03-Images-Diagrams"
    
    for root, dirs, files in os.walk(base_dir):
        if ".git" in root: continue
        for file in files:
            if file.endswith(".md"):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
                    continue
                
                new_content = content
                
                # Find all image links: ![alt](path)
                matches = re.findall(r'!\[(.*?)\]\((.*?)\)', content)
                for alt, path in matches:
                    # Clean the path from potential URL encoding or quotes
                    clean_path = path.strip().strip("'").strip('"')
                    
                    if "Images/" in clean_path or clean_path.endswith((".png", ".jpg", ".jpeg", ".gif", ".svg")):
                        # Check if path is already relative/absolute and exists
                        # First try as relative to current file
                        abs_path = os.path.normpath(os.path.join(root, clean_path))
                        
                        if not os.path.exists(abs_path):
                            # It's broken. Let's try to find the filename in our hub.
                            filename = os.path.basename(clean_path)
                            
                            # Calculate relative path from this file to the root hub
                            rel_to_root = os.path.relpath(base_dir, root)
                            
                            # Possible hub locations relative to base_dir
                            possible_hubs = [
                                os.path.join(image_hub_rel, "Kubernetes", filename),
                                os.path.join(image_hub_rel, "AWS", filename),
                                os.path.join(image_hub_rel, "General", filename),
                                os.path.join(image_hub_rel, filename)
                            ]
                            
                            found = False
                            for hub_path in possible_hubs:
                                full_hub_path = os.path.join(base_dir, hub_path)
                                if os.path.exists(full_hub_path):
                                    # Calculate the new relative path from the current file's directory to the hub file
                                    new_path = os.path.relpath(full_hub_path, root)
                                    # Standardize to forward slashes for cross-platform compatibility
                                    new_path = new_path.replace("\\", "/")
                                    
                                    # Replace in content. Use a safer replacement to avoid partial matches
                                    # We use the original path string caught by regex
                                    new_content = new_content.replace(f"({path})", f"({new_path})")
                                    found = True
                                    print(f"Fixed: {filepath} -> {filename} to {new_path}")
                                    break
                                    
                if new_content != content:
                    try:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                    except Exception as e:
                        print(f"Error writing {filepath}: {e}")

if __name__ == "__main__":
    fix_image_paths("/home/ganil/Documents/Devops")
