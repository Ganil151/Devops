"""
Challenge: Configuration Merger
Scenario: Merge these configuration dictionaries using dictionary merging.

TODO: 
1. Create final_config with production values overriding defaults
2. Find which keys were overridden (existed in both)
3. Find which keys are new in production (only in production_override)
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

# --- START YOUR CODE HERE ---

# --- END YOUR CODE HERE ---
