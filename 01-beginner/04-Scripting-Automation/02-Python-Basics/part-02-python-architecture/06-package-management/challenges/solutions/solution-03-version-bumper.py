"""
Solution: Version Bumper
"""
import re

def bump_patch_version(file_path):
    """Parses and increments the patch version."""
    with open(file_path, 'r') as f:
        content = f.read()
        
    # Find version pattern
    match = re.search(r'version=["\'](\d+)\.(\d+)\.(\d+)["\']', content)
    if match:
        major, minor, patch = match.groups()
        new_patch = int(patch) + 1
        new_version = f'{major}.{minor}.{new_patch}'
        
        # Replace in content
        new_content = re.sub(r'version=["\']\d+\.\d+\.\d+["\']', f'version="{new_version}"', content)
        
        with open(file_path, 'w') as f:
            f.write(new_content)
        print(f"Bumped version to {new_version}")

if __name__ == "__main__":
    bump_patch_version("setup.py")
