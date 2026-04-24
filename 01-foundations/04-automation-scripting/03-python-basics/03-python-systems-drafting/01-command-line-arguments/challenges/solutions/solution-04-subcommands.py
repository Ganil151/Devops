"""
Solution: Subcommand Router
"""
import argparse

def main():
    parser = argparse.ArgumentParser(prog="calc")
    subparsers = parser.add_subparsers(dest="command", help="Mathematical operations")
    
    # Add parser
    add_parser = subparsers.add_parser("add", help="Add two numbers")
    add_parser.add_argument("x", type=int, help="First number")
    add_parser.add_argument("y", type=int, help="Second number")
    
    # Multiply parser
    mult_parser = subparsers.add_parser("multiply", help="Multiply two numbers")
    mult_parser.add_argument("x", type=int, help="First number")
    mult_parser.add_argument("y", type=int, help="Second number")
    
    args = parser.parse_args()
    
    if args.command == "add":
        print(f"Result: {args.x + args.y}")
    elif args.command == "multiply":
        print(f"Result: {args.x * args.y}")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
