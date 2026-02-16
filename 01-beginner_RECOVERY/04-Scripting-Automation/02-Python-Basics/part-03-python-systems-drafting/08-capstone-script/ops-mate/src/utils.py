import logging
import sys
from pathlib import Path

def setup_logging(log_file: str = "logs/ops-mate.log"):
    """
    Configure professional logging to both console and file.
    """
    # Ensure log directory exists
    log_path = Path(log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # 1. Create Logger
    logger = logging.getLogger("ops-mate")
    logger.setLevel(logging.DEBUG)

    # 2. Console Handler (INFO and above)
    c_handler = logging.StreamHandler(sys.stdout)
    c_handler.setLevel(logging.INFO)
    c_format = logging.Formatter('%(levelname)s: %(message)s')
    c_handler.setFormatter(c_format)

    # 3. File Handler (DEBUG and above)
    f_handler = logging.FileHandler(log_file)
    f_handler.setLevel(logging.DEBUG)
    f_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    f_handler.setFormatter(f_format)

    # 4. Add Handlers
    logger.addHandler(c_handler)
    logger.addHandler(f_handler)

    return logger
