"""
Multi-Cloud Security Audit Tool
Description: Basic security audit for AWS (S3, SG) and basic placeholders for Azure/GCP
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
"""

import boto3
import json
import datetime

class DateTimeEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime.datetime):
            return o.isoformat()
        return super().default(o)

def audit_aws():
    print("\n[AWS] Starting Security Audit...")
    findings = []
    
    # 1. Public S3 Buckets
    try:
        s3 = boto3.client('s3')
        buckets = s3.list_buckets()['Buckets']
        
        for bucket in buckets:
            name = bucket['Name']
            try:
                pab = s3.get_public_access_block(Bucket=name)
                # Check if BlockPublicAcls is False
                if not pab['PublicAccessBlockConfiguration']['BlockPublicAcls']:
                     findings.append({"Severity": "HIGH", "Resource": f"S3: {name}", "Issue": "Public Access Block disabled"})
            except:
                # If no PAB exists, it might be open
                findings.append({"Severity": "MEDIUM", "Resource": f"S3: {name}", "Issue": "No Public Access Block config found"})
    except Exception as e:
        print(f"AWS S3 Error: {e}")

    # 2. Open Security Groups (0.0.0.0/0 on port 22)
    try:
        ec2 = boto3.client('ec2')
        sgs = ec2.describe_security_groups()['SecurityGroups']
        
        for sg in sgs:
            for rule in sg['IpPermissions']:
                if 'FromPort' in rule and rule['FromPort'] == 22:
                    for ip_range in rule['IpRanges']:
                        if ip_range['CidrIp'] == '0.0.0.0/0':
                            findings.append({
                                "Severity": "CRITICAL",
                                "Resource": f"SG: {sg['GroupName']} ({sg['GroupId']})",
                                "Issue": "SSH Open to World (0.0.0.0/0)"
                            })
    except Exception as e:
        print(f"AWS SG Error: {e}")
        
    return findings

def main():
    print("Multi-Cloud Security Audit")
    print("==========================")
    
    # Run Audits
    aws_findings = audit_aws()
    
    # Consolidate
    all_findings = []
    for f in aws_findings:
        f['Cloud'] = 'AWS'
        all_findings.append(f)
        
    # Output
    print(f"\nAudit Complete. Found {len(all_findings)} issues.")
    
    if len(all_findings) > 0:
        print(json.dumps(all_findings, indent=4, cls=DateTimeEncoder))
        
        # Save to file
        with open('security-audit-report.json', 'w') as f:
            json.dump(all_findings, f, indent=4, cls=DateTimeEncoder)
            print("\nReport saved to security-audit-report.json")
    else:
        print("No critical issues found (based on current checks).")

if __name__ == "__main__":
    main()
