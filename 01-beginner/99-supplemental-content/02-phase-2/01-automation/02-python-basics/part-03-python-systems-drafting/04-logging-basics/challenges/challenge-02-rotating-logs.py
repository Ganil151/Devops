"""
Challenge: Rotating Log Handler
Scenario: To prevent your log files from growing indefinitely and filling 
up the disk, you need to implement size-based log rotation.

TODO: Implement `setup_rotating_logger(filename)`.
1. Use `logging.handlers.RotatingFileHandler`.
2. Set `maxBytes` to 1024 (1KB) for this exercise.
3. Set `backupCount` to 3 (keeps 3 old log files).
4. Use a simple formatter: `%(levelname)s: %(message)s`.
"""
import logging
from logging.handlers import RotatingFileHandler

def setup_rotating_logger(filename):
    """
    Configures a logger that rotates files when they reach a certain size.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    logger = setup_rotating_logger("app.log")
    
    # Generate enough logs to trigger rotation
    for i in range(100):
        logger.info(f"Log entry number {i} - padding text to ensure rotation happens quickly...")
