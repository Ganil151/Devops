"""
Challenge: Dry-Run Guardrail
Scenario: You are writing a script that deletes old log files. 
Destructive actions MUST have a --dry-run flag to prevent accidents.

TODO: Implement `cleanup_logs(directory, dry_run=True)`.
1. List all files in the `directory`.
2. If `dry_run` is True:
   - Print "[DRY-RUN] Would delete file: {filename}"
3. If `dry_run` is False:
   - Print "[ACTION] Deleting file: {filename}"
   - Actually call `os.remove(path)`.
4. Use the `logging` module to log these actions instead of just `print`.
"""
import os
import logging
import argparse

# Setup structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def cleanup_logs(directory, dry_run=True):
    """
    Safely cleans up logs with a dry-run option.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dir", default="logs", help="Directory to clean")
    parser.add_argument("--execute", action="store_false", dest="dry_run", help="Actually delete files")
    parser.set_defaults(dry_run=True)
    args = parser.parse_args()

    # Setup dummy files for testing
    if not os.path.exists(args.dir):
        os.makedirs(args.dir)
    with open(f"{args.dir}/old_app.log", "w") as f: f.write("test")
    
    cleanup_logs(args.dir, dry_run=args.dry_run)
