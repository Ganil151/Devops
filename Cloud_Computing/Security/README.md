# Cloud Security Fundamentals

Comprehensive guide to cloud security principles, best practices, and implementation strategies across all major cloud platforms.

## Cloud Security Overview

Cloud security encompasses the policies, technologies, applications, and controls utilized to protect virtualized IP, data, applications, services, and the associated infrastructure of cloud computing.

### Shared Responsibility Model

```
┌─────────────────────────────────────────────────────────────┐
│                 Shared Responsibility Model                  │
│                                                             │
│  Customer Responsibility (Security IN the Cloud)           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Customer Data                                     │   │
│  │ • Platform, Applications, Identity & Access Mgmt   │   │
│  │ • Operating System, Network & Firewall Config     │   │
│  │ • Client-Side Data Encryption & Integrity         │   │
│  │ • Server-Side Encryption (File System/Data)       │   │
│  │ • Network Traffic Protection (Encryption/Integrity)│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Provider Responsibility (Security OF the Cloud)           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Software (Compute, Storage, Database, Networking)│   │
│  │ • Hardware/AWS Global Infrastructure               │   │
│  │ • Regions, Availability Zones, Edge Locations     │   │
│  │ • Physical Security of Data Centers                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Identity and Access Management (IAM)

### AWS IAM Best Practices

```bash
# Create IAM user with minimal permissions
aws iam create-user --user-name devops-user

# Create IAM group
aws iam create-group --group-name DevOpsTeam

# Add user to group
aws iam add-user-to-group \
    --group-name DevOpsTeam \
    --user-name devops-user

# Attach managed policy to group
aws iam attach-group-policy \
    --group-name DevOpsTeam \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create custom policy with least privilege
aws iam create-policy \
    --policy-name DevOpsCustomPolicy \
    --policy-document file://devops-policy.json

# Enable MFA for user
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name devops-user-mfa \
    --outfile QRCode.png \
    --bootstrap-method QRCodePNG

# Create role for EC2 instances
aws iam create-role \
    --role-name EC2-DevOps-Role \
    --assume-role-policy-document file://trust-policy.json

# Attach policy to role
aws iam attach-role-policy \
    --role-name EC2-DevOps-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile
aws iam create-instance-profile \
    --instance-profile-name EC2-DevOps-Profile

# Add role to instance profile
aws iam add-role-to-instance-profile \
    --instance-profile-name EC2-DevOps-Profile \
    --role-name EC2-DevOps-Role
```

### Azure Active Directory Security

```bash
# Create user in Azure AD
az ad user create \
    --display-name "DevOps User" \
    --password TempPassword123! \
    --user-principal-name devopsuser@yourdomain.onmicrosoft.com \
    --force-change-password-next-login true

# Create security group
az ad group create \
    --display-name "DevOps Security Group" \
    --mail-nickname devopssecuritygroup

# Add user to group
az ad group member add \
    --group "DevOps Security Group" \
    --member-id $(az ad user show --id devopsuser@yourdomain.onmicrosoft.com --query objectId -o tsv)

# Create service principal
az ad sp create-for-rbac \
    --name "DevOps-Service-Principal" \
    --role "Contributor" \
    --scopes /subscriptions/{subscription-id}/resourceGroups/DevOpsRG

# Enable MFA for user (via Azure portal or PowerShell)
# Set conditional access policies
az ad policy create \
    --definition @conditional-access-policy.json \
    --display-name "DevOps MFA Policy"

# Create custom role
az role definition create --role-definition '{
    "Name": "DevOps Custom Role",
    "Description": "Custom role for DevOps operations",
    "Actions": [
        "Microsoft.Compute/*/read",
        "Microsoft.Storage/*/read",
        "Microsoft.Network/*/read",
        "Microsoft.Resources/*/read"
    ],
    "NotActions": [],
    "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'
```

### Google Cloud IAM Security

```bash
# Create service account
gcloud iam service-accounts create devops-sa \
    --description="DevOps Service Account" \
    --display-name="DevOps SA"

# Grant roles to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:devops-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.viewer"

# Create custom role
gcloud iam roles create devopsCustomRole \
    --project=PROJECT_ID \
    --title="DevOps Custom Role" \
    --description="Custom role for DevOps team" \
    --permissions="compute.instances.list,compute.instances.get,storage.objects.list"

# Grant role to user
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:devops@company.com" \
    --role="projects/PROJECT_ID/roles/devopsCustomRole"

# Create and download service account key
gcloud iam service-accounts keys create devops-sa-key.json \
    --iam-account=devops-sa@PROJECT_ID.iam.gserviceaccount.com

# Enable 2FA (via Google Cloud Console)
# Set up organization policies
gcloud resource-manager org-policies set-policy policy.yaml \
    --organization=ORGANIZATION_ID
```

## Data Encryption

### Encryption at Rest

#### AWS Encryption
```bash
# S3 Bucket Encryption
aws s3api put-bucket-encryption \
    --bucket devops-secure-bucket \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms",
                "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
            }
        }]
    }'

# EBS Volume Encryption
aws ec2 create-volume \
    --size 20 \
    --volume-type gp3 \
    --availability-zone us-east-1a \
    --encrypted \
    --kms-key-id arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012

# RDS Encryption
aws rds create-db-instance \
    --db-instance-identifier secure-database \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password SecurePassword123 \
    --allocated-storage 20 \
    --storage-encrypted \
    --kms-key-id arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012
```

#### Azure Encryption
```bash
# Storage Account Encryption
az storage account create \
    --name securestorage \
    --resource-group DevOpsRG \
    --location eastus \
    --sku Standard_LRS \
    --encryption-services blob file \
    --encryption-key-source Microsoft.Storage

# Disk Encryption
az disk create \
    --resource-group DevOpsRG \
    --name secure-disk \
    --size-gb 128 \
    --sku Premium_LRS \
    --encryption-type EncryptionAtRestWithCustomerKey \
    --disk-encryption-set /subscriptions/{subscription-id}/resourceGroups/DevOpsRG/providers/Microsoft.Compute/diskEncryptionSets/myDiskEncryptionSet

# SQL Database Transparent Data Encryption
az sql db tde set \
    --resource-group DevOpsRG \
    --server secure-sql-server \
    --database secure-database \
    --status Enabled
```

#### GCP Encryption
```bash
# Cloud Storage Encryption
gsutil kms encryption \
    -k projects/PROJECT_ID/locations/us-central1/keyRings/devops-keyring/cryptoKeys/storage-key \
    gs://secure-bucket

# Compute Engine Disk Encryption
gcloud compute disks create secure-disk \
    --size=100GB \
    --zone=us-central1-a \
    --kms-key=projects/PROJECT_ID/locations/us-central1/keyRings/devops-keyring/cryptoKeys/disk-key

# Cloud SQL Encryption
gcloud sql instances create secure-instance \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --disk-encryption-key=projects/PROJECT_ID/locations/us-central1/keyRings/devops-keyring/cryptoKeys/sql-key
```

### Encryption in Transit

#### TLS/SSL Configuration
```yaml
# Kubernetes TLS Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - secure-app.example.com
    secretName: secure-app-tls
  rules:
  - host: secure-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: secure-app-service
            port:
              number: 80
```

#### Application-Level Encryption
```python
# Python application with encryption
import cryptography.fernet
import os
import base64

class DataEncryption:
    def __init__(self):
        # Get encryption key from environment or key management service
        key = os.environ.get('ENCRYPTION_KEY')
        if not key:
            key = self.get_key_from_kms()
        self.cipher_suite = cryptography.fernet.Fernet(key.encode())
    
    def encrypt_data(self, data):
        """Encrypt sensitive data before storing"""
        return self.cipher_suite.encrypt(data.encode())
    
    def decrypt_data(self, encrypted_data):
        """Decrypt data when retrieving"""
        return self.cipher_suite.decrypt(encrypted_data).decode()
    
    def get_key_from_kms(self):
        """Retrieve encryption key from cloud KMS"""
        # AWS KMS example
        import boto3
        kms = boto3.client('kms')
        response = kms.decrypt(
            CiphertextBlob=base64.b64decode(os.environ['ENCRYPTED_KEY'])
        )
        return response['Plaintext'].decode()

# Usage example
encryptor = DataEncryption()
sensitive_data = "user_password_123"
encrypted = encryptor.encrypt_data(sensitive_data)
decrypted = encryptor.decrypt_data(encrypted)
```

## Network Security

### Virtual Private Clouds (VPC)

#### AWS VPC Security
```bash
# Create VPC with security groups
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Secure-VPC}]'

# Create private subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet}]'

# Create security group with restrictive rules
aws ec2 create-security-group \
    --group-name WebServer-SG \
    --description "Security group for web servers" \
    --vpc-id vpc-12345678

# Add inbound rules (principle of least privilege)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 443 \
    --source-group sg-903004f8  # Only allow HTTPS from same SG

aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr 10.0.0.0/16  # SSH only from VPC

# Create Network ACL for additional layer
aws ec2 create-network-acl \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=Secure-NACL}]'
```

#### Azure Network Security
```bash
# Create virtual network with security
az network vnet create \
    --resource-group DevOpsRG \
    --name SecureVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name PrivateSubnet \
    --subnet-prefix 10.0.1.0/24

# Create Network Security Group
az network nsg create \
    --resource-group DevOpsRG \
    --name WebServer-NSG

# Add security rules
az network nsg rule create \
    --resource-group DevOpsRG \
    --nsg-name WebServer-NSG \
    --name AllowHTTPS \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 443 \
    --access allow \
    --source-address-prefixes 10.0.0.0/16

# Associate NSG with subnet
az network vnet subnet update \
    --resource-group DevOpsRG \
    --vnet-name SecureVNet \
    --name PrivateSubnet \
    --network-security-group WebServer-NSG

# Create Application Security Group
az network asg create \
    --resource-group DevOpsRG \
    --name WebServers-ASG
```

#### GCP VPC Security
```bash
# Create VPC network
gcloud compute networks create secure-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create private subnet
gcloud compute networks subnets create private-subnet \
    --network=secure-vpc \
    --range=10.0.1.0/24 \
    --region=us-central1 \
    --enable-private-ip-google-access

# Create firewall rules (deny all by default, allow specific)
gcloud compute firewall-rules create deny-all-ingress \
    --network=secure-vpc \
    --action=deny \
    --rules=all \
    --source-ranges=0.0.0.0/0 \
    --priority=65534

gcloud compute firewall-rules create allow-internal \
    --network=secure-vpc \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/16 \
    --priority=1000

gcloud compute firewall-rules create allow-https \
    --network=secure-vpc \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=https-server \
    --priority=1000
```

### Web Application Firewall (WAF)

#### AWS WAF Configuration
```bash
# Create WAF Web ACL
aws wafv2 create-web-acl \
    --name DevOps-WAF \
    --scope CLOUDFRONT \
    --default-action Allow={} \
    --rules file://waf-rules.json

# WAF Rules JSON
cat > waf-rules.json << EOF
[
    {
        "Name": "AWSManagedRulesCommonRuleSet",
        "Priority": 1,
        "OverrideAction": {"None": {}},
        "Statement": {
            "ManagedRuleGroupStatement": {
                "VendorName": "AWS",
                "Name": "AWSManagedRulesCommonRuleSet"
            }
        },
        "VisibilityConfig": {
            "SampledRequestsEnabled": true,
            "CloudWatchMetricsEnabled": true,
            "MetricName": "CommonRuleSetMetric"
        }
    },
    {
        "Name": "RateLimitRule",
        "Priority": 2,
        "Action": {"Block": {}},
        "Statement": {
            "RateBasedStatement": {
                "Limit": 2000,
                "AggregateKeyType": "IP"
            }
        },
        "VisibilityConfig": {
            "SampledRequestsEnabled": true,
            "CloudWatchMetricsEnabled": true,
            "MetricName": "RateLimitMetric"
        }
    }
]
EOF
```

#### Azure Application Gateway WAF
```bash
# Create Application Gateway with WAF
az network application-gateway create \
    --name SecureAppGateway \
    --location eastus \
    --resource-group DevOpsRG \
    --vnet-name SecureVNet \
    --subnet AppGatewaySubnet \
    --capacity 2 \
    --sku WAF_v2 \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 443 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --public-ip-address AppGatewayPublicIP \
    --cert-file appgateway.pfx \
    --cert-password CertPassword123

# Configure WAF policy
az network application-gateway waf-policy create \
    --name SecureWAFPolicy \
    --resource-group DevOpsRG \
    --location eastus

# Add custom WAF rules
az network application-gateway waf-policy custom-rule create \
    --policy-name SecureWAFPolicy \
    --resource-group DevOpsRG \
    --name BlockSQLInjection \
    --priority 100 \
    --rule-type MatchRule \
    --action Block \
    --match-conditions '[{
        "matchVariables": [{"variableName": "RequestBody"}],
        "operator": "Contains",
        "matchValues": ["SELECT", "UNION", "DROP"],
        "transforms": ["Lowercase"]
    }]'
```

## Secrets Management

### AWS Secrets Manager
```bash
# Create secret
aws secretsmanager create-secret \
    --name "devops/database/credentials" \
    --description "Database credentials for DevOps application" \
    --secret-string '{"username":"admin","password":"MySecurePassword123"}'

# Retrieve secret
aws secretsmanager get-secret-value \
    --secret-id "devops/database/credentials" \
    --query SecretString --output text

# Update secret
aws secretsmanager update-secret \
    --secret-id "devops/database/credentials" \
    --secret-string '{"username":"admin","password":"NewSecurePassword456"}'

# Enable automatic rotation
aws secretsmanager rotate-secret \
    --secret-id "devops/database/credentials" \
    --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation \
    --rotation-rules AutomaticallyAfterDays=30
```

### Azure Key Vault
```bash
# Create Key Vault
az keyvault create \
    --name DevOpsKeyVault \
    --resource-group DevOpsRG \
    --location eastus \
    --enabled-for-disk-encryption true \
    --enabled-for-deployment true \
    --enabled-for-template-deployment true \
    --sku premium

# Set secret
az keyvault secret set \
    --vault-name DevOpsKeyVault \
    --name DatabasePassword \
    --value MySecurePassword123

# Get secret
az keyvault secret show \
    --vault-name DevOpsKeyVault \
    --name DatabasePassword \
    --query value -o tsv

# Set access policy
az keyvault set-policy \
    --name DevOpsKeyVault \
    --upn user@company.com \
    --secret-permissions get list set delete

# Create certificate
az keyvault certificate create \
    --vault-name DevOpsKeyVault \
    --name DevOpsCert \
    --policy "$(az keyvault certificate get-default-policy)"
```

### Google Secret Manager
```bash
# Create secret
gcloud secrets create database-password \
    --data-file=password.txt

# Access secret
gcloud secrets versions access latest --secret="database-password"

# Add secret version
echo "NewSecurePassword456" | gcloud secrets versions add database-password --data-file=-

# Grant access to secret
gcloud secrets add-iam-policy-binding database-password \
    --member="serviceAccount:devops-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

# List secrets
gcloud secrets list
```

### HashiCorp Vault Integration
```bash
# Install and configure Vault
vault server -config=vault-config.hcl

# Initialize Vault
vault operator init -key-shares=5 -key-threshold=3

# Unseal Vault
vault operator unseal <unseal_key_1>
vault operator unseal <unseal_key_2>
vault operator unseal <unseal_key_3>

# Enable secrets engine
vault secrets enable -path=devops kv-v2

# Store secret
vault kv put devops/database username=admin password=MySecurePassword123

# Retrieve secret
vault kv get devops/database

# Create policy
vault policy write devops-policy - <<EOF
path "devops/data/*" {
  capabilities = ["read", "list"]
}
EOF

# Enable auth method
vault auth enable kubernetes

# Configure Kubernetes auth
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

## Security Monitoring and Compliance

### AWS Security Services

#### AWS CloudTrail
```bash
# Create CloudTrail
aws cloudtrail create-trail \
    --name DevOps-Audit-Trail \
    --s3-bucket-name devops-cloudtrail-logs \
    --include-global-service-events \
    --is-multi-region-trail \
    --enable-log-file-validation

# Start logging
aws cloudtrail start-logging --name DevOps-Audit-Trail

# Create event rule for real-time monitoring
aws events put-rule \
    --name SecurityEventRule \
    --event-pattern '{
        "source": ["aws.iam"],
        "detail-type": ["AWS API Call via CloudTrail"],
        "detail": {
            "eventName": ["CreateUser", "DeleteUser", "AttachUserPolicy"]
        }
    }'

# Add SNS target for notifications
aws events put-targets \
    --rule SecurityEventRule \
    --targets "Id"="1","Arn"="arn:aws:sns:us-east-1:123456789012:security-alerts"
```

#### AWS Config
```bash
# Create configuration recorder
aws configservice put-configuration-recorder \
    --configuration-recorder name=default,roleARN=arn:aws:iam::123456789012:role/config-role \
    --recording-group allSupported=true,includeGlobalResourceTypes=true

# Create delivery channel
aws configservice put-delivery-channel \
    --delivery-channel name=default,s3BucketName=config-bucket-123456789012

# Start configuration recorder
aws configservice start-configuration-recorder --configuration-recorder-name default

# Create Config rules
aws configservice put-config-rule \
    --config-rule '{
        "ConfigRuleName": "s3-bucket-public-access-prohibited",
        "Source": {
            "Owner": "AWS",
            "SourceIdentifier": "S3_BUCKET_PUBLIC_ACCESS_PROHIBITED"
        }
    }'
```

#### AWS GuardDuty
```bash
# Enable GuardDuty
aws guardduty create-detector --enable

# Get detector ID
DETECTOR_ID=$(aws guardduty list-detectors --query DetectorIds[0] --output text)

# Create IP set for trusted IPs
aws guardduty create-ip-set \
    --detector-id $DETECTOR_ID \
    --name TrustedIPs \
    --format TXT \
    --location s3://guardduty-ipsets/trusted-ips.txt \
    --activate

# Create threat intel set
aws guardduty create-threat-intel-set \
    --detector-id $DETECTOR_ID \
    --name KnownThreats \
    --format TXT \
    --location s3://guardduty-threats/threat-list.txt \
    --activate
```

### Azure Security Services

#### Azure Security Center
```bash
# Enable Security Center
az security auto-provisioning-setting update \
    --name default \
    --auto-provision on

# Configure security contacts
az security contact create \
    --contact-name "Security Team" \
    --email security@company.com \
    --phone "+1234567890" \
    --alert-notifications on \
    --alerts-admins on

# Get security assessments
az security assessment list --output table

# Create custom security policy
az policy definition create \
    --name "Require-HTTPS-Storage" \
    --display-name "Storage accounts should use HTTPS" \
    --description "Ensure storage accounts use HTTPS" \
    --rules '{
        "if": {
            "allOf": [
                {"field": "type", "equals": "Microsoft.Storage/storageAccounts"},
                {"field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly", "equals": false}
            ]
        },
        "then": {"effect": "deny"}
    }'
```

#### Azure Sentinel
```bash
# Create Log Analytics workspace for Sentinel
az monitor log-analytics workspace create \
    --resource-group DevOpsRG \
    --workspace-name SentinelWorkspace \
    --location eastus

# Enable Sentinel (via Azure portal or ARM template)
# Create analytics rules
az sentinel alert-rule create \
    --resource-group DevOpsRG \
    --workspace-name SentinelWorkspace \
    --rule-name "Suspicious Login Activity" \
    --rule-template-name "Suspicious-Login-Template"
```

### GCP Security Services

#### Cloud Security Command Center
```bash
# List findings
gcloud scc findings list ORGANIZATION_ID \
    --filter="state=\"ACTIVE\"" \
    --format="table(name,category,resourceName,state)"

# Create notification config
gcloud scc notifications create security-notifications \
    --organization=ORGANIZATION_ID \
    --pubsub-topic=projects/PROJECT_ID/topics/security-alerts \
    --filter='state="ACTIVE" AND category="MALWARE"'

# List assets
gcloud scc assets list ORGANIZATION_ID \
    --filter="securityCenterProperties.resourceType=\"google.compute.Instance\""
```

#### Cloud Audit Logs
```bash
# Enable audit logs
gcloud logging sinks create security-audit-sink \
    storage.googleapis.com/security-audit-logs \
    --log-filter='protoPayload.serviceName="compute.googleapis.com" OR protoPayload.serviceName="iam.googleapis.com"'

# Create log-based metrics
gcloud logging metrics create failed_login_attempts \
    --description="Failed login attempts" \
    --log-filter='protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey" AND protoPayload.authenticationInfo.principalEmail!=""'

# Create alerting policy
gcloud alpha monitoring policies create \
    --policy-from-file=security-alert-policy.yaml
```

## Incident Response and Forensics

### Cloud Forensics Toolkit

```python
# cloud-forensics.py
import boto3
import json
from datetime import datetime, timedelta

class CloudForensics:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.cloudtrail = boto3.client('cloudtrail')
        self.logs = boto3.client('logs')
    
    def create_forensic_snapshot(self, instance_id):
        """Create forensic snapshot of compromised instance"""
        # Stop instance to preserve state
        self.ec2.stop_instances(InstanceIds=[instance_id])
        
        # Get instance details
        response = self.ec2.describe_instances(InstanceIds=[instance_id])
        instance = response['Reservations'][0]['Instances'][0]
        
        # Create snapshots of all volumes
        snapshots = []
        for device in instance['BlockDeviceMappings']:
            volume_id = device['Ebs']['VolumeId']
            snapshot = self.ec2.create_snapshot(
                VolumeId=volume_id,
                Description=f'Forensic snapshot of {volume_id} from incident {datetime.now().isoformat()}'
            )
            snapshots.append(snapshot['SnapshotId'])
        
        return snapshots
    
    def analyze_cloudtrail_events(self, start_time, end_time, username=None):
        """Analyze CloudTrail events for suspicious activity"""
        events = []
        
        lookup_attributes = []
        if username:
            lookup_attributes.append({
                'AttributeKey': 'Username',
                'AttributeValue': username
            })
        
        response = self.cloudtrail.lookup_events(
            LookupAttributes=lookup_attributes,
            StartTime=start_time,
            EndTime=end_time
        )
        
        for event in response['Events']:
            # Analyze for suspicious patterns
            if self.is_suspicious_event(event):
                events.append({
                    'EventTime': event['EventTime'],
                    'EventName': event['EventName'],
                    'Username': event.get('Username', 'Unknown'),
                    'SourceIPAddress': event.get('SourceIPAddress', 'Unknown'),
                    'UserAgent': event.get('UserAgent', 'Unknown')
                })
        
        return events
    
    def is_suspicious_event(self, event):
        """Identify suspicious CloudTrail events"""
        suspicious_events = [
            'CreateUser', 'DeleteUser', 'AttachUserPolicy',
            'CreateRole', 'DeleteRole', 'AttachRolePolicy',
            'CreateAccessKey', 'DeleteAccessKey',
            'ConsoleLogin', 'AssumeRole'
        ]
        
        # Check for events from unusual locations
        if event.get('SourceIPAddress'):
            # Implement IP geolocation check
            pass
        
        # Check for events outside business hours
        event_time = event['EventTime']
        if event_time.hour < 8 or event_time.hour > 18:
            return True
        
        return event['EventName'] in suspicious_events
    
    def collect_logs(self, log_group, start_time, end_time):
        """Collect relevant logs for analysis"""
        logs = []
        
        response = self.logs.filter_log_events(
            logGroupName=log_group,
            startTime=int(start_time.timestamp() * 1000),
            endTime=int(end_time.timestamp() * 1000)
        )
        
        for event in response['events']:
            logs.append({
                'timestamp': datetime.fromtimestamp(event['timestamp'] / 1000),
                'message': event['message']
            })
        
        return logs

# Usage example
forensics = CloudForensics()

# Create forensic snapshots
incident_instance = 'i-1234567890abcdef0'
snapshots = forensics.create_forensic_snapshot(incident_instance)

# Analyze recent events
start_time = datetime.now() - timedelta(hours=24)
end_time = datetime.now()
suspicious_events = forensics.analyze_cloudtrail_events(start_time, end_time)

# Generate incident report
incident_report = {
    'incident_id': 'INC-2024-001',
    'timestamp': datetime.now().isoformat(),
    'affected_instance': incident_instance,
    'forensic_snapshots': snapshots,
    'suspicious_events': suspicious_events,
    'recommendations': [
        'Rotate all access keys for affected accounts',
        'Review and update security groups',
        'Implement additional monitoring',
        'Conduct security awareness training'
    ]
}

print(json.dumps(incident_report, indent=2, default=str))
```

### Automated Incident Response

```yaml
# incident-response-playbook.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: incident-response-playbook
data:
  playbook.py: |
    #!/usr/bin/env python3
    import boto3
    import json
    import os
    
    def lambda_handler(event, context):
        """Automated incident response for security events"""
        
        # Parse CloudWatch alarm or GuardDuty finding
        if 'source' in event and event['source'] == 'aws.guardduty':
            handle_guardduty_finding(event)
        elif 'AlarmName' in event:
            handle_cloudwatch_alarm(event)
        
        return {'statusCode': 200, 'body': 'Incident response executed'}
    
    def handle_guardduty_finding(event):
        """Handle GuardDuty security findings"""
        finding = event['detail']
        severity = finding['severity']
        
        if severity >= 7.0:  # High severity
            # Isolate affected instance
            instance_id = finding['service']['resourceRole']
            isolate_instance(instance_id)
            
            # Create forensic snapshot
            create_forensic_snapshot(instance_id)
            
            # Send alert to security team
            send_security_alert(finding)
    
    def isolate_instance(instance_id):
        """Isolate compromised instance"""
        ec2 = boto3.client('ec2')
        
        # Create isolation security group
        isolation_sg = ec2.create_security_group(
            GroupName=f'isolation-{instance_id}',
            Description='Isolation security group for incident response'
        )
        
        # Modify instance security groups
        ec2.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[isolation_sg['GroupId']]
        )
    
    def create_forensic_snapshot(instance_id):
        """Create forensic snapshots"""
        ec2 = boto3.client('ec2')
        
        # Get instance volumes
        response = ec2.describe_instances(InstanceIds=[instance_id])
        instance = response['Reservations'][0]['Instances'][0]
        
        # Create snapshots
        for device in instance['BlockDeviceMappings']:
            volume_id = device['Ebs']['VolumeId']
            ec2.create_snapshot(
                VolumeId=volume_id,
                Description=f'Forensic snapshot - Incident response'
            )
    
    def send_security_alert(finding):
        """Send alert to security team"""
        sns = boto3.client('sns')
        
        message = {
            'incident_type': finding['type'],
            'severity': finding['severity'],
            'description': finding['description'],
            'affected_resource': finding['service']['resourceRole'],
            'timestamp': finding['updatedAt']
        }
        
        sns.publish(
            TopicArn=os.environ['SECURITY_ALERT_TOPIC'],
            Message=json.dumps(message),
            Subject='Security Incident Detected'
        )

---
apiVersion: batch/v1
kind: Job
metadata:
  name: incident-response-job
spec:
  template:
    spec:
      containers:
      - name: incident-response
        image: python:3.9-slim
        command: ["python3"]
        args: ["/scripts/playbook.py"]
        env:
        - name: AWS_DEFAULT_REGION
          value: "us-east-1"
        - name: SECURITY_ALERT_TOPIC
          value: "arn:aws:sns:us-east-1:123456789012:security-alerts"
        volumeMounts:
        - name: playbook-volume
          mountPath: /scripts
      volumes:
      - name: playbook-volume
        configMap:
          name: incident-response-playbook
      restartPolicy: Never
```

This comprehensive cloud security guide provides the foundation for implementing robust security practices across all major cloud platforms and ensuring compliance with industry standards and regulations.