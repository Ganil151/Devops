import argparse
import logging
import os
import sys
from pathlib import Path
from typing import Optional

# --- Configuration ---
# Using logging for comprehensive output (Coding Best Practices: Comprehensive Logging)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


def setup_cli_parser() -> argparse.ArgumentParser:
    """
    Sets up the command-line argument parser.
    (Execution & Monitoring: Command-Line Interface (CLI))
    """
    parser = argparse.ArgumentParser(
        description="Automates directory and file creation with robust error handling.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "target_dir", type=str, help="The path to the directory to create."
    )
    parser.add_argument(
        "--file-name",
        type=str,
        default=None,
        help="Optional: Name of a file to create inside the target directory.",
    )
    parser.add_argument(
        "--file-content",
        type=str,
        default="Hello, automation!",
        help="Content for the optional file.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force creation of directory/file, overwriting if exists (use with caution).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate the actions without making any changes. (Testing & Validation: Dry-Run Mode)",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Enable verbose logging (DEBUG level)."
    )
    return parser


def create_directory(path: Path, force: bool, dry_run: bool) -> bool:
    """
    Creates a directory, handling existing paths and dry-run mode.
    (Coding Best Practices: Modularity, Idempotency by Design)
    """
    if dry_run:
        logging.info(f"[DRY RUN] Would create directory: {path}")
        return True

    if path.exists():
        if path.is_dir():
            logging.info(f"Directory already exists: {path}")
            return True
        else:
            if force:
                logging.warning(
                    f"Existing file at {path} will be overwritten by directory due to --force."
                )
                try:
                    path.unlink()  # Remove the file
                except OSError as e:
                    logging.error(f"Failed to remove existing file at {path}: {e}")
                    return False
            else:
                logging.error(
                    f"Cannot create directory. A file already exists at {path}. Use --force to overwrite."
                )
                return False

    try:
        path.mkdir(parents=True, exist_ok=True)
        logging.info(f"Successfully created directory: {path}")
        return True
    except OSError as e:
        logging.error(f"Failed to create directory {path}: {e}")
        return False


def create_file(
    dir_path: Path, file_name: str, content: str, force: bool, dry_run: bool
) -> bool:
    """
    Creates a file within a directory, handling existing files and dry-run mode.
    (Coding Best Practices: Modularity, Idempotency by Design)
    """
    file_path = dir_path / file_name

    if dry_run:
        logging.info(
            f"[DRY RUN] Would create file: {file_path} with content: '{content[:20]}...'"
        )
        return True

    if file_path.exists() and not force:
        logging.info(
            f"File already exists: {file_path}. Skipping creation. Use --force to overwrite."
        )
        return True

    try:
        file_path.write_text(content)
        logging.info(f"Successfully created file: {file_path}")
        return True
    except OSError as e:
        logging.error(f"Failed to create file {file_path}: {e}")
        return False


def main():
    parser = setup_cli_parser()
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    target_dir_path = Path(args.target_dir).resolve()

    # (Coding Best Practices: Guard Clauses (Fail-Fast))
    if not target_dir_path.parent.exists() and not args.dry_run:
        logging.error(
            f"Parent directory for {target_dir_path} does not exist. Please create it first or ensure full path is provided."
        )
        sys.exit(1)

    logging.info(f"Starting automation task for directory: {target_dir_path}")
    if args.dry_run:
        logging.info("DRY RUN mode is active. No actual changes will be made.")

    # (Execution & Monitoring: Exit Codes)
    if not create_directory(target_dir_path, args.force, args.dry_run):
        logging.error("Directory creation failed. Exiting.")
        sys.exit(1)

    if args.file_name:
        if not create_file(
            target_dir_path, args.file_name, args.file_content, args.force, args.dry_run
        ):
            logging.error("File creation failed. Exiting.")
            sys.exit(1)
    else:
        logging.info("No file name provided. Skipping file creation.")

    logging.info("Automation task completed successfully.")
    sys.exit(0)


if __name__ == "__main__":
    # (Planning & Setup: Virtual Environment - implied, run this script within one)
    # (Security Considerations: Least Privilege Principle - ensure the user running this has only necessary permissions)
    # (Security Considerations: Input Sanitization - Pathlib helps, but for user-provided content, further sanitization might be needed)
    main()
