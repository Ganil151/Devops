"""
Challenge: Server Inventory Management
Scenario: Create a server inventory system using lists and dictionaries.

TODO: Implement these functions
1. add_server(name, ip, role): Add a server to inventory
2. find_by_role(role): Return all servers with given role
3. remove_server(name): Remove server by name
"""

inventory = []

def add_server(name, ip, role):
    """Add a server to inventory"""
    # --- YOUR CODE HERE ---
    pass

def find_by_role(role):
    """Return all servers with given role"""
    # --- YOUR CODE HERE ---
    pass

def remove_server(name):
    """Remove server by name"""
    # --- YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    add_server("web-01", "10.0.1.50", "web")
    add_server("api-01", "10.0.1.51", "api")
    add_server("web-02", "10.0.1.52", "web")
    
    print("Web Servers:", find_by_role("web"))
    
    remove_server("web-01")
    print("After removal:", inventory)
