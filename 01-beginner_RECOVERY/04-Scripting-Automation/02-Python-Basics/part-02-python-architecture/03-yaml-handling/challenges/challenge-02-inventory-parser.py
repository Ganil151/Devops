"""
Challenge: Ansible Inventory Parser
Scenario: You need to extract host information from an Ansible YAML inventory file to use in a custom script.

TODO: Implement `parse_inventory(yaml_content)` function.
1. Parse the YAML content into a Python dictionary.
2. Recursively or iteratively extract all hosts from all groups (webservers, databases, etc.).
3. Return a list of host dictionaries, each containing:
   - 'name': The host name (e.g., 'web-01')
   - 'ip': The 'ansible_host' value
   - 'group': The name of the group it belongs to
"""
import yaml

inventory_yaml = """
all:
  children:
    webservers:
      hosts:
        web-01:
          ansible_host: 10.0.1.10
        web-02:
          ansible_host: 10.0.1.11
    databases:
      hosts:
        db-01:
          ansible_host: 10.0.2.10
          db_role: primary
        db-02:
          ansible_host: 10.0.2.11
          db_role: replica
"""

def parse_inventory(yaml_content):
    """
    Parses Ansible inventory and returns host details.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    hosts = parse_inventory(inventory_yaml)
    print("Parsed Hosts:")
    for h in hosts:
        print(f"- {h['name']} ({h['ip']}) in group '{h['group']}'")
