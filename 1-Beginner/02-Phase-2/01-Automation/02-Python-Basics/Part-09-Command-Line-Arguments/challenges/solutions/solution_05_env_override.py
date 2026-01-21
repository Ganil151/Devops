"""
Solution: Environment Override CLI
"""
import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    
    # Use environment variable as the default for the positional argument
    parser.add_argument("key", 
                        nargs="?", 
                        default=os.environ.get("API_KEY"),
                        help="API Key (can also be set via API_KEY env var)")
    
    args = parser.parse_args()
    
    if not args.key:
        # Custom error message if neither provided
        parser.error("API_KEY must be provided via argument or environment variable.")
    
    print(f"✅ Success: Using API Key: {args.key}")

if __name__ == "__main__":
    main()
