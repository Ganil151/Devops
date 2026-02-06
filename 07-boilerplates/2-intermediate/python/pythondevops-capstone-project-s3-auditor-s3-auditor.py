#!/usr/bin/env python3
"""
Name: s3_auditor.py
Description: Capstone Project Skeleton.
Objectives:
1. List all S3 Buckets.
2. Check for "Public Access Block".
3. Check for "Server Side Encryption" (Default).
4. Generate a Security Report.
"""

import boto3
import logging
import json
import argparse
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("s3_guardian")

class S3Auditor:
    def __init__(self, profile):
        self.session = boto3.Session(profile_name=profile)
        self.s3 = self.session.client("s3")
        self.report = []

    def scan_buckets(self):
        """Iterates through all buckets and runs checks."""
        try:
            buckets = self.s3.list_buckets().get("Buckets", [])
            logger.info(f"Scanning {len(buckets)} buckets...")
            
            for b in buckets:
                name = b["Name"]
                logger.info(f"Checking {name}...")
                
                is_encrypted = self.check_encryption(name)
                is_public_blocked = self.check_public_access(name)
                
                self.report.append({
                    "bucket": name,
                    "encryption": is_encrypted,
                    "public_blocked": is_public_blocked,
                    "status": "pass" if is_encrypted and is_public_blocked else "FAIL"
                })
                
        except ClientError as e:
            logger.error(f"Fatal Error: {e}")

    def check_encryption(self, bucket):
        try:
            self.s3.get_bucket_encryption(Bucket=bucket)
            return True
        except ClientError:
            return False

    def check_public_access(self, bucket):
        try:
            resp = self.s3.get_public_access_block(Bucket=bucket)
            conf = resp["PublicAccessBlockConfiguration"]
            # Strict: All must be true
            return conf["BlockPublicAcls"] and conf["BlockPublicPolicy"]
        except ClientError:
            return False

    def save_report(self, filename="audit_report.json"):
        with open(filename, "w") as f:
            json.dump(self.report, f, indent=2)
        logger.info(f"Report saved to {filename}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", default="default")
    args = parser.parse_args()
    
    auditor = S3Auditor(args.profile)
    auditor.scan_buckets()
    auditor.save_report()
