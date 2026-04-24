"""
Solution: Multi-Service Health Checker
"""
import random

def check_health(hostname, checks):
    """
    Perform specified health checks on a server.
    """
    results = {}
    
    # Mock functions to simulate real system checks
    check_functions = {
        "cpu": lambda: random.randint(20, 95),
        "memory": lambda: random.randint(30, 90),
        "disk": lambda: random.randint(10, 85),
        "network": lambda: random.choice([True, False])
    }
    
    for check in checks:
        if check in check_functions:
            value = check_functions[check]()
            # Determine status based on thresholds
            if check == "network":
                status = "ok" if value else "error"
            else:
                status = "ok" if value < 80 else "warning" if value < 90 else "critical"
            
            results[check] = {"status": status, "value": value}
        else:
            results[check] = {"status": "unknown", "value": None}
    
    return results

# Test the function
if __name__ == "__main__":
    server_status = check_health("prod-web-01", ["cpu", "memory", "network"])
    print(f"Health Report for prod-web-01: {server_status}")
