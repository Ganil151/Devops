#!/usr/bin/env python3
"""
Name: data_parser.py
Description: Safe parsing of JSON and YAML configuration files.
"""

import json
import logging
import sys
from typing import Dict, Any

# Optional: PyYAML must be installed (pip install pyyaml)
# We handle the import safely
try:
    import yaml
except ImportError:
    yaml = None

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("data_parser")

def load_json(path: str) -> Dict[str, Any]:
    """Loads a JSON file safely."""
    try:
        with open(path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        logger.error(f"File not found: {path}")
        return {}
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in {path}: {e}")
        return {}

def load_yaml(path: str) -> Dict[str, Any]:
    """Loads a YAML file safely."""
    if yaml is None:
        logger.error("PyYAML library is not installed.")
        return {}
        
    try:
        with open(path, "r") as f:
            # SafeLoader is crucial prevents code execution exploits
            return yaml.safe_load(f)
    except FileNotFoundError:
        logger.error(f"File not found: {path}")
        return {}
    except yaml.YAMLError as e:
        logger.error(f"Invalid YAML in {path}: {e}")
        return {}

def get_nested(data: Dict, path: str, default: Any = None) -> Any:
    """
    Retrieves a nested value using dot notation.
    Example: path="server.ports.http"
    """
    keys = path.split(".")
    current = data
    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return default
    return current

if __name__ == "__main__":
    # Create dummy JSON
    dummy_json = "config_test.json"
    with open(dummy_json, "w") as f:
        json.dump({"server": {"host": "localhost", "port": 8080}}, f)
        
    data = load_json(dummy_json)
    port = get_nested(data, "server.port")
    logger.info(f"Loaded Port: {port}")
    
    # Create dummy YAML
    if yaml:
        dummy_yaml = "config_test.yaml"
        with open(dummy_yaml, "w") as f:
            f.write("server:\n  host: 0.0.0.0\n  port: 9090")
            
        y_data = load_yaml(dummy_yaml)
        host = get_nested(y_data, "server.host")
        logger.info(f"Loaded YAML Host: {host}")
