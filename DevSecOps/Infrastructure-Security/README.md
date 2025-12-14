# Infrastructure Security

Complete guide to securing cloud and on-premises infrastructure in DevSecOps environments.

## Infrastructure as Code Security

### Terraform Security Scanning
```bash
# Checkov - Infrastructure security scanning
checkov -f main.tf --framework terraform
checkov -d . --framework terraform --output json

# tfsec - Terraform security scanner
tfsec .
tfsec --format json --out results.json .

# Terrascan - Multi-cloud security scanner
terrascan scan -t terraform
terrascan scan -t terraform -o json

# Custom Terraform security policies
# security-policies.rego
package terraform.security

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  msg := "S3 bucket must have encryption enabled"
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"
  rule := resource.change.after.ingress[_]
  rule.from_port == 22
  rule.cidr_blocks[_] == "0.0.0.0/0"
  msg := "SSH should not be open to the world"
}
```

### CloudFormation Security
```yaml
# AWS Config Rules for CloudFormation
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  S3BucketEncryptionRule:
    Type: AWS::Config::ConfigRule
    Properties:
      ConfigRuleName: s3-bucket-server-side-encryption-enabled
      Source:
        Owner: AWS
        SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
      Scope:
        ComplianceResourceTypes:
          - AWS::S3::Bucket

# CloudFormation Guard Rules
# s3-encryption.guard
rule S3_BUCKET_ENCRYPTION {
  AWS::S3::Bucket {
    Properties {
      BucketEncryption exists
      BucketEncryption {
        ServerSideEncryptionConfiguration exists
        ServerSideEncryptionConfiguration[*] {
          ServerSideEncryptionByDefault exists
          ServerSideEncryptionByDefault {
            SSEAlgorithm exists
          }
        }
      }
    }
  }
}

# Validate with cfn-guard
cfn-guard validate -r s3-encryption.guard -d template.yaml
```

### Kubernetes Security Scanning
```bash
# Kubesec - Kubernetes security scanner
kubesec scan pod.yaml
kubesec scan https://raw.githubusercontent.com/user/repo/main/pod.yaml

# Polaris - Kubernetes best practices validation
polaris audit --audit-path ./k8s-manifests/

# Falco - Runtime security monitoring
# /etc/falco/falco_rules.yaml
- rule: Detect shell in container
  desc: Detect shell spawned in container
  condition: >
    spawned_process and container and
    (proc.name in (shell_binaries))
  output: >
    Shell spawned in container (user=%user.name container_id=%container.id 
    image=%container.image.repository proc=%proc.cmdline)
  priority: WARNING

# OPA Gatekeeper policies
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredsecuritycontext
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredSecurityContext
      validation:
        properties:
          runAsNonRoot:
            type: boolean
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecuritycontext
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Container must run as non-root user"
        }
```

## Cloud Security Posture Management

### AWS Security Assessment
```bash
# AWS Config compliance checking
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name s3-bucket-public-access-prohibited

# AWS Security Hub findings
aws securityhub get-findings \
  --filters '{"SeverityLabel":[{"Value":"HIGH","Comparison":"EQUALS"}]}'

# AWS Well-Architected Tool
aws wellarchitected list-workloads
aws wellarchitected get-workload --workload-id workload-123

# Custom AWS security checks
#!/bin/bash
# aws-security-audit.sh

echo "=== AWS Security Audit ==="

# Check for public S3 buckets
echo "Checking for public S3 buckets..."
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
while read bucket; do
  policy=$(aws s3api get-bucket-policy --bucket $bucket 2>/dev/null)
  if echo "$policy" | grep -q "\"Principal\": \"*\""; then
    echo "WARNING: Bucket $bucket may be publicly accessible"
  fi
done

# Check for security groups with wide-open access
echo "Checking security groups..."
aws ec2 describe-security-groups \
  --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId,GroupName]' \
  --output table

# Check for unencrypted EBS volumes
echo "Checking for unencrypted EBS volumes..."
aws ec2 describe-volumes \
  --query 'Volumes[?Encrypted==`false`].[VolumeId,State]' \
  --output table
```

### Azure Security Assessment
```bash
# Azure Security Center recommendations
az security assessment list --query '[].{Name:displayName,Status:status.code}'

# Azure Policy compliance
az policy state list --filter "complianceState eq 'NonCompliant'"

# Azure Resource Graph queries for security
az graph query -q "
  Resources
  | where type == 'microsoft.storage/storageaccounts'
  | where properties.supportsHttpsTrafficOnly == false
  | project name, resourceGroup, subscriptionId
"

# Custom Azure security script
#!/bin/bash
# azure-security-audit.sh

echo "=== Azure Security Audit ==="

# Check for storage accounts without HTTPS enforcement
echo "Checking storage accounts..."
az storage account list --query '[?enableHttpsTrafficOnly==`false`].[name,resourceGroup]' -o table

# Check for VMs without managed disks encryption
echo "Checking VM disk encryption..."
az vm list --query '[].{Name:name,ResourceGroup:resourceGroup,OsDiskEncryption:storageProfile.osDisk.encryptionSettings}' -o table

# Check for network security groups with permissive rules
echo "Checking NSG rules..."
az network nsg list --query '[].{Name:name,ResourceGroup:resourceGroup}' -o table
```

### Google Cloud Security Assessment
```bash
# GCP Security Command Center findings
gcloud scc findings list organizations/123456789 \
  --filter="state=\"ACTIVE\" AND severity=\"HIGH\""

# GCP Asset Inventory
gcloud asset search-all-resources \
  --query="securityCenterProperties.resourceType:google.compute.Instance"

# Custom GCP security checks
#!/bin/bash
# gcp-security-audit.sh

echo "=== GCP Security Audit ==="

# Check for compute instances with external IPs
echo "Checking compute instances with external IPs..."
gcloud compute instances list \
  --filter="networkInterfaces.accessConfigs:*" \
  --format="table(name,zone,networkInterfaces[].accessConfigs[0].natIP)"

# Check for storage buckets with public access
echo "Checking storage buckets..."
gsutil ls -L -b gs://* | grep -A 5 "ACL:"

# Check for unencrypted disks
echo "Checking disk encryption..."
gcloud compute disks list \
  --filter="NOT diskEncryptionKey:*" \
  --format="table(name,zone,sizeGb)"
```

## Network Security

### Network Segmentation
```bash
# AWS VPC Security Groups
aws ec2 create-security-group \
  --group-name web-tier-sg \
  --description "Web tier security group" \
  --vpc-id vpc-12345678

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 80 \
  --source-group sg-87654321

# Network ACLs
aws ec2 create-network-acl-entry \
  --network-acl-id acl-12345678 \
  --rule-number 100 \
  --protocol tcp \
  --port-range From=80,To=80 \
  --cidr-block 10.0.0.0/8 \
  --rule-action allow

# Azure Network Security Groups
az network nsg create \
  --resource-group myResourceGroup \
  --name myNetworkSecurityGroup

az network nsg rule create \
  --resource-group myResourceGroup \
  --nsg-name myNetworkSecurityGroup \
  --name AllowHTTP \
  --protocol Tcp \
  --priority 1000 \
  --destination-port-range 80 \
  --access Allow
```

### Network Monitoring
```bash
# AWS VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-12345678 \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name VPCFlowLogs

# Network traffic analysis with ELK
# Logstash configuration for VPC Flow Logs
input {
  cloudwatch_logs {
    log_group => "VPCFlowLogs"
    region => "us-east-1"
  }
}

filter {
  grok {
    match => { "message" => "%{DATA:version} %{DATA:account_id} %{DATA:interface_id} %{IP:srcaddr} %{IP:dstaddr} %{INT:srcport} %{INT:dstport} %{INT:protocol} %{INT:packets} %{INT:bytes} %{INT:windowstart} %{INT:windowend} %{DATA:action} %{DATA:flowlogstatus}" }
  }
  
  if [action] == "REJECT" {
    mutate {
      add_tag => ["security_event"]
    }
  }
}

output {
  if "security_event" in [tags] {
    elasticsearch {
      hosts => ["elasticsearch:9200"]
      index => "security-events-%{+YYYY.MM.dd}"
    }
  }
}
```

## Identity and Access Management Security

### IAM Policy Analysis
```bash
# AWS IAM policy simulation
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/testuser \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::mybucket/*

# IAM Access Analyzer
aws accessanalyzer create-analyzer \
  --analyzer-name security-analyzer \
  --type ACCOUNT

aws accessanalyzer list-findings \
  --analyzer-arn arn:aws:access-analyzer:us-east-1:123456789012:analyzer/security-analyzer

# Custom IAM security checks
#!/bin/bash
# iam-security-audit.sh

echo "=== IAM Security Audit ==="

# Check for users with administrative privileges
echo "Users with administrative access:"
aws iam list-attached-user-policies --user-name admin-user

# Check for unused access keys
echo "Checking for old access keys..."
aws iam list-users --query 'Users[].UserName' --output text | \
while read user; do
  aws iam list-access-keys --user-name $user \
    --query 'AccessKeyMetadata[?Status==`Active`].[AccessKeyId,CreateDate]' \
    --output text
done

# Check for overly permissive policies
echo "Checking for policies with wildcard permissions..."
aws iam list-policies --scope Local --query 'Policies[].Arn' --output text | \
while read policy_arn; do
  policy_doc=$(aws iam get-policy-version --policy-arn $policy_arn --version-id v1 --query 'PolicyVersion.Document')
  if echo "$policy_doc" | grep -q '"Resource": "*"'; then
    echo "WARNING: Policy $policy_arn has wildcard resource permissions"
  fi
done
```

### Zero Trust Architecture
```yaml
# Istio Service Mesh Security Policies
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: frontend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/api-service"]
  - to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]

---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

## Compliance and Governance

### Compliance Frameworks
```bash
# CIS Benchmarks automation
# AWS CIS Benchmark
git clone https://github.com/prowler-cloud/prowler.git
cd prowler
./prowler -g cislevel2

# Azure CIS Benchmark
git clone https://github.com/Azure/azure-policy.git
az policy assignment create \
  --name 'CIS Microsoft Azure Foundations Benchmark' \
  --policy-set-definition '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'

# NIST Cybersecurity Framework
# Implement NIST controls with automation
```

### Automated Compliance Checking
```python
# Compliance checker script
import boto3
import json
from datetime import datetime

class ComplianceChecker:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.s3 = boto3.client('s3')
        self.iam = boto3.client('iam')
        self.compliance_results = []
    
    def check_s3_encryption(self):
        """Check if S3 buckets have encryption enabled"""
        buckets = self.s3.list_buckets()['Buckets']
        
        for bucket in buckets:
            bucket_name = bucket['Name']
            try:
                encryption = self.s3.get_bucket_encryption(Bucket=bucket_name)
                self.compliance_results.append({
                    'resource': bucket_name,
                    'type': 'S3 Bucket',
                    'check': 'Encryption',
                    'status': 'COMPLIANT',
                    'details': 'Encryption enabled'
                })
            except:
                self.compliance_results.append({
                    'resource': bucket_name,
                    'type': 'S3 Bucket',
                    'check': 'Encryption',
                    'status': 'NON_COMPLIANT',
                    'details': 'Encryption not enabled'
                })
    
    def check_ec2_security_groups(self):
        """Check for overly permissive security groups"""
        security_groups = self.ec2.describe_security_groups()['SecurityGroups']
        
        for sg in security_groups:
            for rule in sg.get('IpPermissions', []):
                for ip_range in rule.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        self.compliance_results.append({
                            'resource': sg['GroupId'],
                            'type': 'Security Group',
                            'check': 'Open to Internet',
                            'status': 'NON_COMPLIANT',
                            'details': f"Port {rule.get('FromPort', 'All')} open to 0.0.0.0/0"
                        })
    
    def generate_report(self):
        """Generate compliance report"""
        total_checks = len(self.compliance_results)
        compliant_checks = len([r for r in self.compliance_results if r['status'] == 'COMPLIANT'])
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'total_checks': total_checks,
            'compliant_checks': compliant_checks,
            'compliance_percentage': (compliant_checks / total_checks) * 100 if total_checks > 0 else 0,
            'results': self.compliance_results
        }
        
        return report

# Usage
checker = ComplianceChecker()
checker.check_s3_encryption()
checker.check_ec2_security_groups()
report = checker.generate_report()

print(json.dumps(report, indent=2))
```

## Infrastructure Monitoring and Alerting

### Security Event Monitoring
```yaml
# Prometheus alerting rules for infrastructure security
groups:
- name: infrastructure-security
  rules:
  - alert: UnauthorizedAPICall
    expr: increase(aws_cloudtrail_events{event_name="AssumeRole",error_code!=""}[5m]) > 0
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: "Unauthorized API call detected"
      description: "Failed AssumeRole attempt detected in CloudTrail logs"
  
  - alert: SecurityGroupModification
    expr: increase(aws_cloudtrail_events{event_name=~"AuthorizeSecurityGroupIngress|RevokeSecurityGroupIngress"}[5m]) > 0
    for: 0m
    labels:
      severity: critical
    annotations:
      summary: "Security group modification detected"
      description: "Security group rules have been modified"
  
  - alert: RootAccountUsage
    expr: increase(aws_cloudtrail_events{user_name="root"}[5m]) > 0
    for: 0m
    labels:
      severity: critical
    annotations:
      summary: "Root account usage detected"
      description: "AWS root account has been used"
```

### SIEM Integration
```bash
# Splunk Universal Forwarder for AWS CloudTrail
# inputs.conf
[aws-cloudtrail]
aws_account = 123456789012
aws_iam_role = arn:aws:iam::123456789012:role/SplunkRole
s3_bucket = my-cloudtrail-bucket
host_name = aws-cloudtrail
index = aws
interval = 300
sourcetype = aws:cloudtrail

# ELK Stack for Azure Activity Logs
# Logstash configuration
input {
  azure_event_hubs {
    event_hub_connections => ["Endpoint=sb://namespace.servicebus.windows.net/;SharedAccessKeyName=policy;SharedAccessKey=key;EntityPath=insights-activity-logs"]
    threads => 8
    decorate_events => true
  }
}

filter {
  json {
    source => "message"
  }
  
  if [category] == "Administrative" and [operationName] =~ /Microsoft.Authorization/ {
    mutate {
      add_tag => ["security_event"]
    }
  }
}

output {
  if "security_event" in [tags] {
    elasticsearch {
      hosts => ["elasticsearch:9200"]
      index => "azure-security-events-%{+YYYY.MM.dd}"
    }
  }
}
```

## Incident Response Automation

### Automated Response Scripts
```python
# Automated incident response for AWS
import boto3
import json

class SecurityIncidentResponse:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.iam = boto3.client('iam')
        self.sns = boto3.client('sns')
    
    def isolate_compromised_instance(self, instance_id):
        """Isolate a compromised EC2 instance"""
        # Create isolation security group
        isolation_sg = self.ec2.create_security_group(
            GroupName=f'isolation-{instance_id}',
            Description='Isolation security group for compromised instance'
        )
        
        # Remove all existing security groups and apply isolation SG
        instance = self.ec2.describe_instances(InstanceIds=[instance_id])
        for reservation in instance['Reservations']:
            for inst in reservation['Instances']:
                self.ec2.modify_instance_attribute(
                    InstanceId=instance_id,
                    Groups=[isolation_sg['GroupId']]
                )
        
        # Create snapshot for forensics
        volumes = [v['Ebs']['VolumeId'] for v in inst['BlockDeviceMappings']]
        for volume_id in volumes:
            self.ec2.create_snapshot(
                VolumeId=volume_id,
                Description=f'Forensic snapshot for incident {instance_id}'
            )
        
        return isolation_sg['GroupId']
    
    def disable_compromised_user(self, username):
        """Disable a compromised IAM user"""
        # Disable access keys
        access_keys = self.iam.list_access_keys(UserName=username)
        for key in access_keys['AccessKeyMetadata']:
            self.iam.update_access_key(
                UserName=username,
                AccessKeyId=key['AccessKeyId'],
                Status='Inactive'
            )
        
        # Attach deny-all policy
        deny_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Deny",
                    "Action": "*",
                    "Resource": "*"
                }
            ]
        }
        
        self.iam.put_user_policy(
            UserName=username,
            PolicyName='EmergencyDenyAll',
            PolicyDocument=json.dumps(deny_policy)
        )
    
    def send_alert(self, message, topic_arn):
        """Send security alert"""
        self.sns.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject='Security Incident Alert'
        )

# Lambda function for automated response
def lambda_handler(event, context):
    incident_response = SecurityIncidentResponse()
    
    # Parse CloudWatch alarm or GuardDuty finding
    if 'source' in event and event['source'] == 'aws.guardduty':
        finding = event['detail']
        
        if finding['severity'] >= 7.0:  # High severity
            if 'instanceId' in finding['service']['resourceRole']:
                instance_id = finding['service']['resourceRole']['instanceId']
                isolation_sg = incident_response.isolate_compromised_instance(instance_id)
                
                incident_response.send_alert(
                    f"High severity GuardDuty finding. Instance {instance_id} isolated with SG {isolation_sg}",
                    'arn:aws:sns:us-east-1:123456789012:security-alerts'
                )
    
    return {'statusCode': 200, 'body': 'Incident response completed'}
```

## Best Practices

### Infrastructure Security Hardening
```bash
# 1. Defense in Depth
- Network segmentation
- Multi-factor authentication
- Principle of least privilege
- Regular security assessments
- Continuous monitoring

# 2. Automation and Orchestration
- Infrastructure as Code security scanning
- Automated compliance checking
- Security event correlation
- Incident response automation
- Continuous security testing

# 3. Governance and Compliance
- Policy as Code implementation
- Regular compliance audits
- Security training programs
- Vendor risk management
- Data classification and protection

# 4. Monitoring and Visibility
- Centralized logging and SIEM
- Real-time threat detection
- Security metrics and KPIs
- Threat intelligence integration
- Regular penetration testing
```