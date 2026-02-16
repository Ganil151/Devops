"""
Challenge: JSON Formatter
Scenario: For modern log aggregation (like ELK or Splunk), it's best to 
output logs in JSON format.

TODO: Create a `JSONFormatter` class.
1. Inherit from `logging.Formatter`.
2. Override the `format(record)` method.
3. Create a dictionary with keys: `timestamp`, `level`, `name`, `message`.
4. Return the JSON string of that dictionary.
"""
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """
    Formatter that outputs log records as JSON strings.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    logger = logging.getLogger('json_logger')
    handler = logging.StreamHandler()
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    
    logger.info("Application initialized")
    logger.warning("Configuration mismatch detected")
