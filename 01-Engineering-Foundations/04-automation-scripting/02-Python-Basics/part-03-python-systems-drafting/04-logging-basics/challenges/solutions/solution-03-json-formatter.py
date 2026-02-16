"""
Solution: JSON Formatter
"""
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """Outputs logs as JSON strings."""
    def format(self, record):
        log_entry = {
            "timestamp": datetime.fromtimestamp(record.created).isoformat(),
            "level": record.levelname,
            "name": record.name,
            "message": record.getMessage()
        }
        return json.dumps(log_entry)

if __name__ == "__main__":
    logger = logging.getLogger('json_solution')
    handler = logging.StreamHandler()
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    logger.info("JSON log test")
