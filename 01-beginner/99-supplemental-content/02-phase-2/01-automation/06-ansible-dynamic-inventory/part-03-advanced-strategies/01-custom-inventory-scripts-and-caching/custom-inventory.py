#!/usr/bin/env python3
import json
import argparse
import sys

# Simulation of a slow Legacy DB call
def fetch_legacy_data():
    return [
        {"hostname": "legacy-web-01", "ip": "192.168.99.10", "role": "web"},
        {"hostname": "legacy-db-01", "ip": "192.168.99.20", "role": "db"}
    ]

def get_inventory():
    data = fetch_legacy_data()
    inventory = {
        "legacy_servers": {"hosts": [], "vars": {"provider": "on_prem"}},
        "_meta": {"hostvars": {}}
    }
    
    for server in data:
        # Add to group list
        inventory["legacy_servers"]["hosts"].append(server["hostname"])
        
        # Add variables to _meta (AVOIDS the N+1 API call issue)
        inventory["_meta"]["hostvars"][server["hostname"]] = {
            "ansible_host": server["ip"],
            "server_role": server["role"]
        }
    
    return inventory

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', action='store')
    args = parser.parse_args()

    if args.list:
        print(json.dumps(get_inventory(), indent=2))
    elif args.host:
        print(json.dumps({})) # Not needed because we used _meta
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
