import re


inventory = []

def add_server(name, ip, role):
  """Add a server to inventory."""
  inventory.append({"name": name, "ip": ip, "role": role})    
  return inventory

def find_by_role(role):
  """Return all servers with given role."""
  return [s for s in inventory if s["role"] == role]

def remove_server(name):
  """Remove server by name."""
  global inventory
  inventory = [s for s in inventory if s["name"] != name]
  return inventory

add_server("web-01", "10.0.1.50", "web")
add_server("web-01", "10.0.1.51", "web")
add_server("web-01", "10.0.1.52", "web")
print(find_by_role("web"))
