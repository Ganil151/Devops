"""
Challenge: Automated Cleaner with Safety
Scenario: You are building a cleanup script. To prevent accidental data loss, 
you want two mutually exclusive modes: '--force' (actually delete) and '--dry-run' (pretend).

TODO: Implement a CLI with a mutually exclusive group.
1. Create a `mutually_exclusive_group()`.
2. Add '-f' / '--force' (action="store_true").
3. Add '-d' / '--dry-run' (action="store_true").
4. If neither is provided, default to dry-run (safety first!).
"""
import argparse

def main():
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    main()
