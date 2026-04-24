"""
Solution: CLI Wrapper (kubectl-like)
------------------------------------
Demonstrates:
- Complex `argparse` with subcommands (`add_subparsers`).
- Global vs Subcommand-specific arguments.
- Handling distinct logic paths based on user input.
"""

import argparse
import sys

def handle_get(args, dry_run):
    action = "Fetching"
    if dry_run:
        print(f"🔍 [DRY-RUN] Would fetch {args.resource} from namespace '{args.namespace}'")
    else:
        print(f"📋 {action} {args.resource} from namespace '{args.namespace}'...")
        # Simulation of API call
        print(f"   found 3 {args.resource} (running)")

def handle_create(args, dry_run):
    action = "Creating"
    if dry_run:
        print(f"🔍 [DRY-RUN] Would create {args.resource} with {args.replicas} replicas")
    else:
        print(f"✨ {action} {args.resource} with {args.replicas} replicas...")
        # Simulation of Resource creation
        print(f"   {args.resource} created successfully.")

def handle_delete(args, dry_run):
    action = "Deleting"
    if dry_run:
        print(f"🔍 [DRY-RUN] Would delete {args.resource}")
    else:
        print(f"🔥 {action} {args.resource}...")
        print(f"   {args.resource} deleted.")

def main():
    parser = argparse.ArgumentParser(
        description="DevOps CLI Tool - Manage infrastructure resources."
    )
    
    # Global flag
    parser.add_argument(
        "--dry-run", 
        action="store_true", 
        help="Simulate actions without execution"
    )

    # Subcommands
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    subparsers.required = True # Force user to choose a subcommand

    # 'get' command
    parser_get = subparsers.add_parser("get", help="Retrieve resources")
    parser_get.add_argument("resource", help="Resource type (pods, services, etc.)")
    parser_get.add_argument("--namespace", default="default", help="Target namespace")

    # 'create' command
    parser_create = subparsers.add_parser("create", help="Create resources")
    parser_create.add_argument("resource", help="Resource type to create")
    parser_create.add_argument("--replicas", type=int, default=1, help="Number of replicas")

    # 'delete' command
    parser_delete = subparsers.add_parser("delete", help="Delete resources")
    parser_delete.add_argument("resource", help="Resource type to delete")

    # Parse
    args = parser.parse_args()

    # Route Logic
    if args.command == "get":
        handle_get(args, args.dry_run)
    elif args.command == "create":
        handle_create(args, args.dry_run)
    elif args.command == "delete":
        handle_delete(args, args.dry_run)

if __name__ == "__main__":
    main()
