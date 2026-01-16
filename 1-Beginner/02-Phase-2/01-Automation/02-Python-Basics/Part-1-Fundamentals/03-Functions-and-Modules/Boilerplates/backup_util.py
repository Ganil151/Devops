#!/usr/bin/env python3
"""
Boilerplate: Modular Backup Utility
DevOps Context: Reusable functions for file compression and archiving.
"""
import shutil
import logging
from pathlib import Path
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

def create_archive(source_dir, output_format="zip"):
    """
    Compress a directory into an archive.
    
    Args:
        source_dir (str): Path to directory to compress.
        output_format (str): 'zip' or 'tar'.
        
    Returns:
        str: Path to created archive or None on failure.
    """
    src = Path(source_dir)
    if not src.exists():
        logger.error(f"Source directory not found: {src}")
        return None
        
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_name = f"{src.name}_backup_{timestamp}"
    
    try:
        logger.info(f"Archiving {src}...")
        archive_path = shutil.make_archive(base_name, output_format, src)
        logger.info(f"Archive created: {archive_path}")
        return archive_path
    except Exception as e:
        logger.error(f"Failed to create archive: {e}")
        return None

def cleanup_old_backups(pattern="*_backup_*", keep=3):
    """Retention policy simulation."""
    # This logic would go here
    pass

def main():
    # Example usage
    # Ensure we have a dummy dir to zip
    dummy = Path("temp_data")
    dummy.mkdir(exist_ok=True)
    (dummy / "test_file.txt").write_text("dummy data")
    
    archive = create_archive("temp_data", "zip")
    
    # Cleanup dummy data
    if archive:
        Path(archive).unlink()
    shutil.rmtree(dummy)
    logger.info("Cleanup complete.")

if __name__ == "__main__":
    main()
