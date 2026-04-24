"""
Solution: Lambda Layer Builder
"""
import subprocess
import shutil
import os
from pathlib import Path

def create_layer_zip(package_name, output_filename):
    # 1. Setup paths
    layer_dir = Path("layer_temp")
    python_dir = layer_dir / "python"
    
    if layer_dir.exists():
        shutil.rmtree(layer_dir)
    python_dir.mkdir(parents=True)
    
    # 2. Install package to target
    print(f"Installing {package_name}...")
    subprocess.run([
        "pip", "install", package_name, 
        "-t", str(python_dir)
    ], check=True)
    
    # 3. Create Zip
    # make_archive appends .zip automatically
    print(f"Creating zip {output_filename}.zip...")
    zip_path = shutil.make_archive(
        output_filename, 
        'zip', 
        root_dir=layer_dir,
        base_dir="python"
    )
    
    # 4. Cleanup
    shutil.rmtree(layer_dir)
    
    return zip_path

if __name__ == "__main__":
    # Test logic
    pass
