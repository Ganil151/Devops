"""
Solution: Rotating Log Handler
"""
import logging
from logging.handlers import RotatingFileHandler

def setup_rotating_logger(filename):
    """Setup rotating file logger."""
    logger = logging.getLogger('rotating')
    logger.setLevel(logging.INFO)
    
    # 1KB max size, keep 3 backups
    handler = RotatingFileHandler(filename, maxBytes=1024, backupCount=3)
    handler.setFormatter(logging.Formatter("%(levelname)s: %(message)s"))
    
    logger.addHandler(handler)
    return logger

if __name__ == "__main__":
    log = setup_rotating_logger("app.log")
    for i in range(50):
        log.info(f"Line {i} - rotating logs soon...")
