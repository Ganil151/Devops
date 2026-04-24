#!/usr/bin/env python3
"""
🛡️ Multi-Cloud Infrastructure Health Check
Version 2.0 | Senior Architect Edition

This script performs basic connectivity and resource status checks
across AWS, Azure, and GCP environments.
"""

import os
import sys

def check_aws():
    print("[RUNNING] Checking AWS Environment...")
    # Check if AWS CLI is configured
    status = os.system("aws sts get-caller-identity > /dev/null 2>&1")
    if status == 0:
        print("✅ AWS: Credentials Valid.")
        # Check EC2 Running Instances
        os.system("aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].InstanceId' --output table")
    else:
        print("❌ AWS: Credentials Not Found. Run 'aws configure'.")

def check_azure():
    print("\n[RUNNING] Checking Azure Environment...")
    # Check if logged in
    status = os.system("az account show > /dev/null 2>&1")
    if status == 0:
        print("✅ Azure: Account Authenticated.")
        # List Resource Groups
        os.system("az group list --query '[].{Name:name, Location:location}' --output table")
    else:
        print("❌ Azure: Not logged in. Run 'az login'.")

def check_gcp():
    print("\n[RUNNING] Checking GCP Environment...")
    # Check project config
    status = os.system("gcloud config get-value project > /dev/null 2>&1")
    if status == 0:
        print("✅ GCP: Project Context Found.")
        # List Compute Instances
        os.system("gcloud compute instances list")
    else:
        print("❌ GCP: No active project. Run 'gcloud init'.")

def main():
    print("--- 🦅 Cloud Health Check Dispatcher ---")
    check_aws()
    check_azure()
    check_gcp()
    print("\n--- Health Check Complete ---")

if __name__ == "__main__":
    main()
