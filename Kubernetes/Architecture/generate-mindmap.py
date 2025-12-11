#!/usr/bin/env python3
"""
Kubernetes Architecture Mind Map Generator
Generates various formats of mind maps from the directory structure
"""

import os
import json
from pathlib import Path

def scan_architecture():
    """Scan the Kubernetes Architecture directory structure"""
    base_path = Path(".")
    structure = {}
    
    # Define the main categories
    categories = {
        "Control-Plane": "Control Plane Components",
        "kubelet": "Node Components", 
        "nodes": "Node Components",
        "crictl": "Node Components",
        "pods": "Workload Resources",
        "deployments": "Workload Resources", 
        "statefulsets": "Workload Resources",
        "daemonsets": "Workload Resources",
        "jobs": "Workload Resources",
        "cronjobs": "Workload Resources",
        "services": "Networking",
        "ingress": "Networking", 
        "network-policies": "Networking",
        "persistent-volumes": "Storage",
        "storage-class": "Storage",
        "configMaps": "Configuration",
        "secrets": "Configuration",
        "rbac": "Security",
        "service-accounts": "Security",
        "namespaces": "Security", 
        "hpa": "Autoscaling",
        "vpa": "Autoscaling",
        "pdb": "Autoscaling",
        "kubectl": "Tools",
        "cluster": "Foundation"
    }
    
    for item in base_path.iterdir():
        if item.is_dir() and item.name != "Images" and item.name != "__pycache__":
            category = categories.get(item.name, "Other")
            if category not in structure:
                structure[category] = []
            structure[category].append(item.name)
    
    return structure

def generate_ascii_mindmap(structure):
    """Generate ASCII art mind map"""
    output = []
    output.append("KUBERNETES ARCHITECTURE")
    output.append("│")
    
    categories = list(structure.keys())
    for i, category in enumerate(categories):
        if i == len(categories) - 1:
            output.append(f"└── {category}")
            prefix = "    "
        else:
            output.append(f"├── {category}")
            prefix = "│   "
        
        components = structure[category]
        for j, component in enumerate(components):
            if j == len(components) - 1:
                output.append(f"{prefix}└── {component}")
            else:
                output.append(f"{prefix}├── {component}")
    
    return "\n".join(output)

def generate_mermaid_mindmap(structure):
    """Generate Mermaid mind map syntax"""
    output = []
    output.append("```mermaid")
    output.append("mindmap")
    output.append("  root((Kubernetes Architecture))")
    
    for category, components in structure.items():
        output.append(f"    {category}")
        for component in components:
            # Clean component name for display
            display_name = component.replace("-", " ").replace("_", " ").title()
            output.append(f"      {display_name}")
    
    output.append("```")
    return "\n".join(output)

def generate_json_structure(structure):
    """Generate JSON representation"""
    return json.dumps(structure, indent=2)

def main():
    """Main function to generate mind maps"""
    print("Scanning Kubernetes Architecture...")
    structure = scan_architecture()
    
    # Generate ASCII mind map
    print("\n" + "="*50)
    print("ASCII MIND MAP")
    print("="*50)
    ascii_map = generate_ascii_mindmap(structure)
    print(ascii_map)
    
    # Save ASCII mind map
    with open("kubernetes-ascii-mindmap.txt", "w") as f:
        f.write(ascii_map)
    
    # Generate Mermaid mind map
    print("\n" + "="*50)
    print("MERMAID MIND MAP")
    print("="*50)
    mermaid_map = generate_mermaid_mindmap(structure)
    print(mermaid_map)
    
    # Save Mermaid mind map
    with open("kubernetes-mermaid-generated.md", "w") as f:
        f.write("# Kubernetes Architecture - Generated Mermaid Mind Map\n\n")
        f.write(mermaid_map)
    
    # Generate JSON structure
    json_structure = generate_json_structure(structure)
    with open("kubernetes-structure.json", "w") as f:
        f.write(json_structure)
    
    print(f"\nGenerated files:")
    print("- kubernetes-ascii-mindmap.txt")
    print("- kubernetes-mermaid-generated.md") 
    print("- kubernetes-structure.json")

if __name__ == "__main__":
    main()