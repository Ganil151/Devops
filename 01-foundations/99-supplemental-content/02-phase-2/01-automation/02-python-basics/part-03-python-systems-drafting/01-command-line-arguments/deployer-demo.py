"""
CLI Demo: Multi-Action Cloud Deployer
------------------------------------
This script acts as a professional CLI wrapper for infrastructure tasks.
Demonstrates: Argparse, Subcommands, Choices, and Mutually Exclusive Groups.
"""

import argparse
import sys

def manage_deployment():
    # 1. Initialize the Parser
    parser = argparse.ArgumentParser(
        description="🚀 Enterprise Cloud Deployment Tool v1.0",
        epilog="Use 'deployer_demo.py <command> --help' for details on specific actions."
    )

    # 2. Add Global Optional Arguments
    # Mutually Exclusive Group (You can't be both quiet and verbose)
    log_group = parser.add_mutually_exclusive_group()
    log_group.add_argument("-v", "--verbose", action="store_true", help="Enable detailed logging")
    log_group.add_argument("-q", "--quiet", action="store_true", help="Only show critical errors")

    # 3. Create Subparsers (The 'Subcommand' pattern)
    subparsers = parser.add_subparsers(dest="action", required=True, help="Management Actions")

    # --- 'provision' Subcommand ---
    provision_parser = subparsers.add_parser("provision", help="Provision new resources")
    provision_parser.add_argument("--env", choices=["dev", "stage", "prod"], default="dev", help="Target environment")
    provision_parser.add_argument("--nodes", type=int, default=1, help="Number of nodes (1-10)")

    # --- 'destroy' Subcommand ---
    destroy_parser = subparsers.add_parser("destroy", help="Safe resource destruction")
    destroy_parser.add_argument("--id", required=True, help="Unique ID of the resource to kill")
    destroy_parser.add_argument("--force", action="store_true", help="Skip the 'Are you sure?' prompt")

    # 4. Parse the Arguments
    # If no arguments are provided, argparse will automatically show help and exit.
    args = parser.parse_args()

    # 5. Application Logic
    if args.verbose:
        print("[DEBUG] Loading cloud configuration and initializing subroutines...")

    if args.action == "provision":
        # Guard logic: Prevent accidental prod provisioning without sufficient scale
        if args.env == "prod" and args.nodes < 3:
            print("❌ SECURITY ERROR: Production requires at least 3 nodes for High Availability.")
            sys.exit(1)
        
        print(f"🏗️  Provisioning {args.nodes} node(s) in the [{args.env.upper()}] environment...")

    elif args.action == "destroy":
        if not args.force:
            # Simple interactive safety check
            print(f"‼️  DANGER: You are about to destroy {args.id}.")
            response = input(f"Confirm (y/N): ")
            if response.lower() != 'y':
                print("🛑 Destruction aborted.")
                return
        
        print(f"🔥 Destroying resource ID: {args.id}")

# --- Execution ---
if __name__ == "__main__":
    manage_deployment()
