"""
Solution: Port Scanner CLI
"""
import argparse

def main():
    parser = argparse.ArgumentParser(description="A simple port scanner CLI.")
    
    # 1. Positional argument
    parser.add_argument("host", help="The target host to scan.")
    
    # 2. Multi-value optional argument
    parser.add_argument("-p", "--ports", 
                        type=int, 
                        nargs="+", 
                        default=[80, 443],
                        help="List of ports to scan (default: 80, 443)")
    
    args = parser.parse_args()
    
    print(f"Scanning {args.host} on ports {args.ports}...")

if __name__ == "__main__":
    main()
