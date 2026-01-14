"""
Challenge: Inventory Set Auditor (Drift)
Scenario: You have a list of virtual machines managed by Terraform. 
Sometimes people manually create or delete VMs. You need to find the drift.

TODO: Implement `audit_inventory(desired_list, current_list)`.
1. Convert both lists to sets of strings.
2. Find 'missing' resources (in desired, but not in current).
3. Find 'unmanaged' resources (in current, but not in desired).
4. Return a dictionary: `{"missing": [...], "unmanaged": [...]}`.
"""

def audit_inventory(desired_list, current_list):
    """
    Identifies differences between desired and actual state.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    desired = ["web-01", "web-02", "db-01", "redis-01"]
    current = ["web-01", "db-01", "temp-test-vm"] # web-02 and redis-01 are missing, temp-test-vm is unmanaged
    
    report = audit_inventory(desired, current)
    print(f"Drift Report: {report}")
    # Expected: {'missing': ['web-02', 'redis-01'], 'unmanaged': ['temp-test-vm']}
