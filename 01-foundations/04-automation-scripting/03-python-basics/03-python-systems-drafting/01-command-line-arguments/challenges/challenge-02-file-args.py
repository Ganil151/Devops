"""
Challenge: File-Based Argument Passing
Scenario: Sometimes your CLI needs to target dozens of servers. Instead of typing 
them all on the command line, you want to allow users to provide a file containing 
the argument list.

TODO: Implement a CLI with `fromfile_prefix_chars`.
1. Initialize `ArgumentParser` with `fromfile_prefix_chars='@'`.
2. Add an argument '--server' that can be specified multiple times (`action="append"`).
3. Print the resulting list of servers.
"""
import argparse

# To test: 
# 1. Create a file 'servers.txt' with contents:
# --server
# web-01
# --server
# db-01
# 2. Run: python challenge_02_file_args.py @servers.txt

def main():
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    main()
