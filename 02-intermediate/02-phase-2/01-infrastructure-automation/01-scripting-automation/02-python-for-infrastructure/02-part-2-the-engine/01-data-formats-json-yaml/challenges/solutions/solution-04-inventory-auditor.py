"""
Solution: Inventory Set Auditor (Drift)
"""

def audit_inventory(desired_list, current_list):
    set_desired = set(desired_list)
    set_current = set(current_list)
    
    missing = list(set_desired - set_current)
    unmanaged = list(set_current - set_desired)
    
    return {
        "missing": sorted(missing),
        "unmanaged": sorted(unmanaged)
    }

if __name__ == "__main__":
    # Test logic
    pass
