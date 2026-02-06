# 🛠️ TOML Challenge: JSON to TOML Refactor

**Scenario**: You are modernizing a Python project. The older version used a JSON file for local configuration, but the new version must use the `pyproject.toml` standards for environment settings.

**Task**: Refactor the provided JSON configuration into a valid TOML format.

## Input: `old_config.json`
```json
{
  "database": {
    "server": "192.168.1.1",
    "ports": [ 8001, 8001, 8002 ],
    "connection_max": 5000,
    "enabled": true
  },
  "servers": {
    "alpha": {
      "ip": "10.0.0.1",
      "role": "frontend"
    },
    "beta": {
      "ip": "10.0.0.2",
      "role": "backend"
    }
  }
}
```

## Requirements:
1. **Sections**: Use TOML "Tables" (e.g., `[database]`) for organization.
2. **Types**: Ensure booleans (`true`) and integers are represented as native TOML types (unquoted).
3. **Array Consistency**: Map the ports array precisely.

## Deliverable:
Save your refactored code as `modern_config.toml` in the `solutions/` folder.
