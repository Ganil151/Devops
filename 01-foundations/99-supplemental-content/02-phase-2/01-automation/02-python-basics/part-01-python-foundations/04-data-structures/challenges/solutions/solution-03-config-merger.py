"""
Solution: Configuration Merger
"""

default_config = {
    "timeout": 30,
    "retries": 3,
    "ssl": True,
    "port": 80
}

production_override = {
    "port": 443,
    "timeout": 60,
    "monitoring": True
}

# 1. Merge (Python 3.9+)
final_config = default_config | production_override

# 2. Keys overridden
overridden = set(default_config.keys()) & set(production_override.keys())
print(f"Overridden keys: {overridden}")

# 3. New keys
new_keys = set(production_override.keys()) - set(default_config.keys())
print(f"New keys: {new_keys}")

print(f"Final config: {final_config}")
