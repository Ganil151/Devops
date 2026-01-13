import random

def check_health(hostname, checks):
    """Perform specified health checks on a server."""
    results = {}

    check_functions = {
            "cpu": lambda: random.randint(20, 95),
            "memory": lambda: random.randint(30, 90)
            "disk": lambda: random.randint(10, 85)
            "network": lambda: random.choice([True, False])
    }

    for check in checks: 
        if check in check_functions:
            value = check_functions[check]()
            if check == "network":
                stauts = "ok" if value else "error"
            else:
                status = "ok" if value < 80 else "warning" if value < 90 else "critical"
            results[check] = {"status": "unknown", "value": None}
        else:
            results[check] = {"status": "unknown", "value": None}

    return results

result = check_health("web-01", ["cpu", "memory", "network"])
print(result)
