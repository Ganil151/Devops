"""
Challenge: Multi-Service Health Checker
Scenario: Create a unified way to report server status for multiple metrics.

TODO:
1. Create a function `check_health(hostname, checks)`
2. `checks` is a list of services to inspect (e.g., ['cpu', 'disk'])
3. Return a dictionary where keys are the service names and values are standardized status objects.
   - Example status object: {'status': 'ok', 'value': 85}
4. Use random to simulate values (0-100).
5. Determine status thresholds:
   - < 80: 'ok'
   - 80-90: 'warning'
   - > 90: 'critical'
   - For 'network', use random.choice([True, False]) -> 'ok' or 'error'
"""
import random

def check_health(hostname, checks):
    """
    Perform specified health checks on a server.
    """
    # --- START YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    server_status = check_health("prod-web-01", ["cpu", "memory", "network"])
    print(f"Health Report for prod-web-01: {server_status}")
