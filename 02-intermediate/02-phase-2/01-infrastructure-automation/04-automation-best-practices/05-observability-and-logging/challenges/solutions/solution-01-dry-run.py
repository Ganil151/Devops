"""
Solution: Dry-Run Guardrail
"""
import os
import logging

def cleanup_logs(directory, dry_run=True):
    if not os.path.exists(directory):
        logging.error(f"Directory {directory} not found.")
        return
        
    files = os.listdir(directory)
    if not files:
        logging.info("Nothing to clean.")
        return
        
    for filename in files:
        path = os.path.join(directory, filename)
        if os.path.isfile(path):
            if dry_run:
                logging.info(f"[DRY-RUN] Would delete file: {filename}")
            else:
                try:
                    os.remove(path)
                    logging.warning(f"[ACTION] Deleted file: {filename}")
                except Exception as e:
                    logging.error(f"Failed to delete {filename}: {e}")

if __name__ == "__main__":
    pass
