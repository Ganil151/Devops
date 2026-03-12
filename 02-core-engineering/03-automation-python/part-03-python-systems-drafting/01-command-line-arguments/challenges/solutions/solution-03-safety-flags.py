"""
Solution: Automated Cleaner with Safety
"""
import argparse

def main():
    parser = argparse.ArgumentParser()
    
    # Create the group
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-f", "--force", action="store_true", help="Actually delete files")
    group.add_argument("-d", "--dry-run", action="store_true", help="Show what would be deleted")
    
    args = parser.parse_args()
    
    # Logic: if neither or dry-run is specified
    if args.force:
        print("🚀 FORCE MODE: Actually deleting files...")
    else:
        # Default to dry-run for safety
        print("🔍 DRY RUN: Pretending to delete files (safe mode)...")

if __name__ == "__main__":
    main()
