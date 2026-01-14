"""
S3 Guardian CLI: Main Entry Point
"""
import argparse
import boto3
import json
import sys
from auditor import audit_bucket

def main():
    parser = argparse.ArgumentParser(description="S3 Guardian - Cloud Security Auditor")
    parser.add_argument("--profile", help="AWS CLI Profile name")
    parser.add_argument("--json", action="store_true", help="Output results as JSON")
    args = parser.parse_args()

    # 1. Initialize AWS Session
    try:
        session = boto3.Session(profile_name=args.profile)
        s3 = session.client("s3")
        # Validate connection
        s3.list_buckets()
    except Exception as e:
        print(f"❌ AWS Connection Error: {e}")
        sys.exit(1)

    # 2. List Buckets
    print("🔍 Scanning S3 Buckets...")
    buckets_resp = s3.list_buckets()
    buckets = [b['Name'] for b in buckets_resp['Buckets']]
    
    if not buckets:
        print("✅ No S3 buckets found in this account.")
        return

    # 3. Perform Audit
    all_results = []
    for bucket in buckets:
        if not args.json:
            print(f"  - Auditing {bucket}...")
        results = audit_bucket(s3, bucket)
        all_results.append(results)

    # 4. Output results
    if args.json:
        print(json.dumps(all_results, indent=2))
    else:
        print("\n" + "="*80)
        print(f"{'BUCKET NAME':<40} | {'ENC':<5} | {'VER':<5} | {'PUB'}")
        print("-" * 80)
        for r in all_results:
            print(f"{r['Name']:<40} | {r['Encryption']:<5} | {r['Versioning']:<5} | {r['PublicBlock']}")
        print("="*80)

if __name__ == "__main__":
    main()
