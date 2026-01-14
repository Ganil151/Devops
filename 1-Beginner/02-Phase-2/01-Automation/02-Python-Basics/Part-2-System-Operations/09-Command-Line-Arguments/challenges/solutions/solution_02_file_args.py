"""
Solution: File-Based Argument Passing
"""
import argparse

def main():
    # Use @ as the prefix for argument files
    parser = argparse.ArgumentParser(fromfile_prefix_chars='@')
    
    # Allow multiple --server flags
    parser.add_argument("--server", action="append", help="Target server name")
    
    args = parser.parse_args()
    
    if args.server:
        print(f"Targeting servers: {', '.join(args.server)}")
    else:
        print("No servers specified.")

if __name__ == "__main__":
    main()
