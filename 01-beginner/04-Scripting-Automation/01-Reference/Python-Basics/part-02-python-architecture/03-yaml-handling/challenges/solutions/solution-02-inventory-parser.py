"""
Solution: Ansible Inventory Parser
"""
import yaml

def parse_inventory(yaml_content):
    """Parse Ansible inventory and return host details."""
    data = yaml.safe_load(yaml_content)
    hosts = []
    
    def extract_hosts(group_data, group_name):
        if not isinstance(group_data, dict):
            return
            
        # 1. Process hosts directly in this group
        if "hosts" in group_data:
            for host_name, host_vars in group_data["hosts"].items():
                hosts.append({
                    "name": host_name,
                    "group": group_name,
                    "ip": host_vars.get("ansible_host"),
                    "vars": {k: v for k, v in host_vars.items() if k != "ansible_host"}
                })
        
        # 2. Recurse into child groups
        if "children" in group_data:
            for child_name, child_data in group_data["children"].items():
                extract_hosts(child_data, child_name)
    
    # Start extraction from the 'all' group
    extract_hosts(data.get("all", {}), "all")
    return hosts

if __name__ == "__main__":
    inventory = """
    all:
      children:
        webservers:
          hosts:
            web-01:
              ansible_host: 10.0.1.10
        databases:
          hosts:
            db-01:
              ansible_host: 10.0.2.10
    """
    hosts = parse_inventory(inventory)
    for host in hosts:
        print(f"{host['name']} ({host['ip']}) - Group: {host['group']}")
