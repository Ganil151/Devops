"""
Challenge: Version Bumper
Scenario: You are releasing a new version of your tool. You need to 
automatically increment the patch version (the third number) in your 
`setup.py` file.

TODO: Implement `bump_patch_version(file_path)`.
1. Read the `setup.py` file.
2. Find the line: `version="1.2.3"`.
3. Increment the `3` to `4`.
4. Write the updated content back to the file.
"""

def bump_patch_version(file_path):
    """
    Increments the patch version in a setup.py file.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create sample setup.py
    with open("setup.py", "w") as f:
        f.write('from setuptools import setup\nsetup(name="tool", version="1.5.9")')
        
    bump_patch_version("setup.py")
    
    with open("setup.py", "r") as f:
        print(f"New content: {f.read()}")
