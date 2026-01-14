"""
Solution: Contextual Logging
"""
import logging

# Configure basic logging with custom fields
logging.basicConfig(
    level=logging.INFO,
    format='[%(request_id)s] %(user)s: %(message)s'
)

logger = logging.getLogger('context')

def process_request(rid, user):
    """Log with request context."""
    logger.info("Process started", extra={"request_id": rid, "user": user})
    # ... logic ...
    logger.info("Process finished", extra={"request_id": rid, "user": user})

if __name__ == "__main__":
    process_request("REQ-001", "ganil")
    process_request("REQ-002", "admin")
