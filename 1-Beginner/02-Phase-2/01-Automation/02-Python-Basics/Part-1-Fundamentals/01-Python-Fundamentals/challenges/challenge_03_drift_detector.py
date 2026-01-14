"""
Challenge: Environment Drift Detector
Scenario: Compare a list of currently running services against 
a list of required services.

TODO:
1. Loop through required_services.
2. If a service is NOT in running_services, print "MISSING: <service>"
3. Loop through running_services.
4. If a service is NOT in required_services, print "EXTRA: <service>"
"""

running_services = ["nginx", "docker", "ssh", "fail2ban", "obsolete_app"]
required_services = ["nginx", "docker", "ssh", "fail2ban", "monitoring_agent"]

# --- START YOUR CODE HERE ---

# --- END YOUR CODE HERE ---
