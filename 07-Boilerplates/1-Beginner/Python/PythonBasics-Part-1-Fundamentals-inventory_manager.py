#!/usr/bin/env python3
"""
Boilerplate: Inventory Manager
DevOps Context: Managing lists of servers and their metadata using dictionaries and lists.
"""
import logging
import json

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def main():
    # List of dictionaries - Common pattern for inventories (Ansible/Terraform)
    inventory = [
        {"hostname": "web-01", "ip": "10.0.1.10", "role": "web", "active": True},
        {"hostname": "web-02", "ip": "10.0.1.11", "role": "web", "active": True},
        {"hostname": "db-01",  "ip": "10.0.2.10", "role": "db",  "active": True},
        {"hostname": "db-02",  "ip": "10.0.2.11", "role": "db",  "active": False}
    ]

    logger.info("Full Inventory:")
    print(json.dumps(inventory, indent=2))

    # 1. Filter: Get all active web servers
    logger.info("Filtering Active Web Servers...")
    active_web = [
        s["ip"] for s in inventory 
        if s["role"] == "web" and s["active"]
    ]
    print(f"Active Web IPs: {active_web}")

    # 2. Transform: Create a map of hostname -> IP
    logger.info("Creating Host Lookup Map...")
    host_map = {s["hostname"]: s["ip"] for s in inventory}
    print(f"Lookups: {host_map}")

    # 3. Aggregation: Count servers by role
    logger.info("Counting Roles...")
    role_counts = {}
    for s in inventory:
        role = s["role"]
        role_counts[role] = role_counts.get(role, 0) + 1
    print(f"Counts: {role_counts}")

if __name__ == "__main__":
    main()
