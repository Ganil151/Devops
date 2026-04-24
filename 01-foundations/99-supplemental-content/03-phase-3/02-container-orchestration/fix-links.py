import os

root_dir = r"c:\Users\Ganil\Documents\Devops\1-Beginner\03-Phase-3\01-Container-Orchestration"

for dirpath, dirnames, filenames in os.walk(root_dir):
    for filename in filenames:
        if filename == "README.md":
            filepath = os.path.join(dirpath, filename)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # Simple replace
                new_content = content.replace("../../Images", "../../../images")
                
                if new_content != content:
                    print(f"Fixing {filepath}")
                    with open(filepath, "w", encoding="utf-8") as f:
                        f.write(new_content)
            except Exception as e:
                print(f"Error processing {filepath}: {e}")
