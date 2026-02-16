"""
DevOps Tool Integration: Ansible Inventory Generator
----------------------------------------------------
Challenge: Create a Python script that generates a dynamic Ansible inventory in YAML format.

Scenario:
You have a list of server dictionaries (simulated below). You need to classify them 
by environment (prod/stage) and role (web/db) and output a YAML structure compatible 
with Ansible.

Requirements:
1. Define a list of servers:
   servers = [
       {"hostname": "web-prod-01", "ip": "10.0.1.10", "env": "prod", "role": "web"},
       {"hostname": "db-prod-01", "ip": "10.0.1.20", "env": "prod", "role": "db"},
       {"hostname": "web-stage-01", "ip": "10.0.2.10", "env": "stage", "role": "web"}
   ]
2. Transform this list into a nested dictionary structure:
   all:
     children:
       prod:
         hosts:
           web-prod-01: {ansible_host: 10.0.1.10}
       ...
3. Use the `yaml` library (PyYAML) to dump the dictionary to stdout (print it).
4. Include a try/except block to handle potential import errors (if PyYAML is missing).

Hint: Ansible inventories can be complex. Start simple: group by 'env'.
"""

import sys

# servers data definition
servers = [
    {"hostname": "web-prod-01", "ip": "10.0.1.10", "env": "prod", "role": "web"},
    {"hostname": "db-prod-01", "ip": "10.0.1.20", "env": "prod", "role": "db"},
    {"hostname": "web-stage-01", "ip": "10.0.2.10", "env": "stage", "role": "web"},
    {"hostname": "db-stage-01", "ip": "10.0.2.20", "env": "stage", "role": "db"}
]

def generate_inventory():
    # TODO: Create the dictionary structure
    
    # TODO: Print as YAML
    pass

if __name__ == "__main__":
    generate_inventory()
