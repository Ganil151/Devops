"""
Solution: Ansible Inventory Generator
-------------------------------------
Demonstrates:
- Creating nested dictionary structures.
- Grouping data by specific keys (env).
- dumping data to YAML using PyYAML.
- Error handling for imports.
"""

import sys

try:
    import yaml
except ImportError:
    print("❌ Error: PyYAML is not installed.")
    print("   Please install it using: pip install PyYAML")
    sys.exit(1)

# servers data definition
servers = [
    {"hostname": "web-prod-01", "ip": "10.0.1.10", "env": "prod", "role": "web"},
    {"hostname": "db-prod-01", "ip": "10.0.1.20", "env": "prod", "role": "db"},
    {"hostname": "web-stage-01", "ip": "10.0.2.10", "env": "stage", "role": "web"},
    {"hostname": "db-stage-01", "ip": "10.0.2.20", "env": "stage", "role": "db"}
]

def generate_inventory():
    # Ansible YAML inventory structure:
    # all:
    #   children:
    #     group_name:
    #       hosts:
    #         hostname: {ansible_host: ip}

    children = {}

    for server in servers:
        env = server["env"]
        hostname = server["hostname"]
        ip = server["ip"]
        
        # Initialize the environment group if it doesn't exist
        if env not in children:
            children[env] = {"hosts": {}}
        
        # Add host to the environment group
        children[env]["hosts"][hostname] = {"ansible_host": ip}
        
        # Optional: You could also group by role, but this simple structure meets the brief.

    inventory = {
        "all": {
            "children": children
        }
    }

    try:
        print("---")
        print(yaml.dump(inventory, default_flow_style=False, sort_keys=False))
        print("✅ Inventory generated successfully.")
    except Exception as e:
        print(f"❌ Failed to generate YAML: {e}")

if __name__ == "__main__":
    generate_inventory()
