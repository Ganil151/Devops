"""
Solution: Server Inventory Management
"""

inventory = []

def add_server(name, ip, role):
    inventory.append({
        "name": name,
        "ip": ip,
        "role": role
    })

def find_by_role(role):
    return [s for s in inventory if s["role"] == role]

def remove_server(name):
    global inventory
    inventory = [s for s in inventory if s["name"] != name]

# Test
if __name__ == "__main__":
    add_server("web-01", "10.0.1.50", "web")
    add_server("api-01", "10.0.1.51", "api")
    add_server("web-02", "10.0.1.52", "web")
    
    print("Web Servers:", find_by_role("web"))
    
    remove_server("web-01")
    print("After removal:", inventory)
