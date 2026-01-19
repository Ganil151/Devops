#!/usr/bin/env python3
"""
Name: robust_template.py
Description: A production-ready Python script template.
Features:
  - Argument parsing
  - Logging setup (File + Console)
  - Error handling
  - Type hinting
  - Main execution block
"""

import sys
import argparse
import logging
from typing import List, Optional

# Configure Logging
# Use a format that is easy to parse: Timestamp - Level - Message
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("script_execution.log")
    ]
)
logger = logging.getLogger(__name__)

def process_data(data: List[str], dry_run: bool = False) -> bool:
    """
    Simulates a data processing task.
    
    Args:
        data: List of strings to process.
        dry_run: If True, simulate without side effects.
        
    Returns:
        bool: True if successful, False otherwise.
    """
    logger.info("Starting processing...")
    
    if not data:
        logger.warning("No data provided!")
        return False

    for item in data:
        if dry_run:
            logger.info(f"[DRY-RUN] Would process: {item}")
        else:
            logger.info(f"Processing: {item}")
            # Simulate error condition
            if "error" in item.lower():
                raise ValueError(f"Invalid data detected: {item}")
                
    return True

def main() -> None:
    """Main execution entry point."""
    parser = argparse.ArgumentParser(description="A Robust Python Automation Template")
    parser.add_argument("items", nargs="*", help="List of items to process")
    parser.add_argument("--dry-run", action="store_true", help="Enable dry-run mode")
    parser.add_argument("--verbose", action="store_true", help="Enable debug logging")

    args = parser.parse_args()

    # Adjust logging level based on flag
    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logger.debug("Verbose mode enabled.")

    try:
        success = process_data(args.items, args.dry_run)
        if success:
            logger.info("Operation completed successfully.")
            sys.exit(0)
        else:
            logger.error("Operation failed.")
            sys.exit(1)

    except ValueError as ve:
        logger.error(f"Validation Error: {ve}")
        sys.exit(1)
    except Exception as e:
        logger.critical(f"Unexpected System Error: {e}", exc_info=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
