from pathlib import Path
import tempfile

# This module provides robust file handling utilities for automation scripts.
# It implements patterns to prevent data corruption during system failures.

def atomic_write(dest: Path, content: str):
  """Write to a temp file then moves into place to prevent corruption."""
  # 1. Create a temporary file in the same directory as the target.
  # We use the same directory to ensure the move operation is on the same filesystem,
  # which is required for the rename to be atomic (instant).
  with tempfile.NamedTemporaryFile(
    'w', 
    delete=False, 
    dir=dest.parent
    ) as tf:
    tf.write(content)
    # Store the temp file path so we can refer to it after the context manager closes
    temp_path = Path(tf.name)

  # 2. Perform the atomic swap. If the script crashes before this line,
  # the original 'dest' file is untouched.
  temp_path.replace(dest)