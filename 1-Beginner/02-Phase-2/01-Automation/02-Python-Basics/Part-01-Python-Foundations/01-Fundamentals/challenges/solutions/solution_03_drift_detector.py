"""
Solution: Environment Drift Detector
"""

running_services = ["nginx", "docker", "ssh", "fail2ban", "obsolete_app"]
required_services = ["nginx", "docker", "ssh", "fail2ban", "monitoring_agent"]

print("--- Compliance Check ---")

# Check for missing
for req in required_services:
    if req not in running_services:
        print(f"MISSING: {req}")

# Check for unauthorized extras
for run in running_services:
    if run not in required_services:
        print(f"EXTRA: {run} (Consider removing)")
