#!/usr/bin/env python3
"""
Lab: The JSON/YAML Transformer
Task: Convert Kubernetes manifests from YAML to JSON with validation and atomicity.
Focus: Atomicity, Validation, and Tooling Standards.
"""

import os
import sys
import json
import yaml
import argparse
from typing import Dict, Any, List

def validate_manifest(content: Dict[str, Any]) -> bool:
    """
    🔍 Pre-flight Check: Ensure the manifest has required K8s fields.
    """
    required_keys = ["apiVersion", "kind", "metadata"]
    return all(key in content for key in required_keys)

def atomic_write_json(data: Dict[str, Any], output_path: str):
    """
    🛡️ Atomic Operation: Write to temp file then rename.
    Prevents half-written files if the script crashes.
    """
    temp_path = f"{output_path}.tmp"
    try:
        with open(temp_path, 'w') as f:
            json.dump(data, f, indent=4)
        
        # OS-level atomic rename (overwrites if exists)
        os.replace(temp_path, output_path)
    except Exception as e:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise e

def process_file(input_file: str, output_dir: str):
    """
    The 'Act' phase of the automation.
    """
    print(f"🔄 Processing {input_file}...")
    
    try:
        with open(input_file, 'r') as f:
            # YAML can contain multiple documents
            manifests = list(yaml.safe_load_all(f))

        for i, manifest in enumerate(manifests):
            if not manifest: continue
            
            # 1. Validate
            if not validate_manifest(manifest):
                print(f"❌ Error: {input_file} (doc {i}) is not a valid K8s manifest. Skipping.")
                continue

            # 2. Transform & Write Atomically
            base_name = os.path.splitext(os.path.basename(input_file))[0]
            suffix = f"-{i}" if len(manifests) > 1 else ""
            output_name = f"{base_name}{suffix}.json"
            output_path = os.path.join(output_dir, output_name)

            atomic_write_json(manifest, output_path)
            print(f"✅ Success: Generated {output_path}")

    except Exception as e:
        print(f"💥 Failed to process {input_file}: {e}")

def main():
    parser = argparse.ArgumentParser(description="K8s Manifest Transformer (YAML -> JSON)")
    parser.add_argument("input", help="Input YAML file or directory")
    parser.add_argument("--output-dir", default=".", help="Directory to save JSON files")
    
    args = parser.parse_args()

    # 🛑 Guard Clause: Check output directory
    if not os.path.isdir(args.output_dir):
        os.makedirs(args.output_dir)

    # Process single file or directory
    if os.path.isfile(args.input):
        process_file(args.input, args.output_dir)
    elif os.path.isdir(args.input):
        for f in os.listdir(args.input):
            if f.endswith((".yaml", ".yml")):
                process_file(os.path.join(args.input, f), args.output_dir)
    else:
        print(f"❌ Error: {args.input} is not a valid file or directory.")
        sys.exit(1)

if __name__ == "__main__":
    main()
