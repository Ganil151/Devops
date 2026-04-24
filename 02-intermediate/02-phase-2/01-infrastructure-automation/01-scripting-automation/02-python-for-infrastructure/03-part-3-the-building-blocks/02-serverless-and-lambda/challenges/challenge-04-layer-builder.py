"""
Challenge: Lambda Layer Builder
Scenario: You need a script that automates the creation of a Lambda 
Layer ZIP file. AWS requires a specific folder structure inside the 
zip (python/lib/python3.x/site-packages/ OR just python/).

TODO: Implement `create_layer_zip(package_name, output_filename)`.
1. Create a temporary directory named 'python'.
2. Use `subprocess.run` to call `pip install <package_name> -t ./python`.
3. Compress the 'python' directory into a ZIP file using `shutil.make_archive`.
4. Return the path of the generated ZIP.
5. Clean up the temporary 'python' directory.
"""
import subprocess
import shutil
import os
from pathlib import Path

def create_layer_zip(package_name, output_filename):
    """
    Automates Lambda Layer packaging.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test with a small package like 'requests'
    zip_path = create_layer_zip("requests", "requests_layer")
    print(f"Layer created at: {zip_path}")
