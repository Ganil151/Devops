"""
Solution: Basic Logger Setup
"""
import logging

def setup_logger():
    """Configures console and file logging."""
    logger = logging.getLogger('deploy')
    logger.setLevel(logging.DEBUG)
    
    # Avoid duplicate handlers
    if logger.hasHandlers():
        logger.handlers.clear()
        
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    
    # Console (INFO)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(formatter)
    
    # File (DEBUG)
    fh = logging.FileHandler('deploy.log')
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)
    
    logger.addHandler(ch)
    logger.addHandler(fh)
    
    return logger

if __name__ == "__main__":
    log = setup_logger()
    log.debug("DEBUG log")
    log.info("INFO log")
