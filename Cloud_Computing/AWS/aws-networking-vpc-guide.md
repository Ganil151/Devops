# AWS Networking and VPC Guide for DevOps Engineers

## VPC Overview

Amazon Virtual Private Cloud (VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment.

## VPC Core Components

### VPC Creation and Configuration

```bash
# Create VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --amazon-provided-ipv6-cidr-block \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=DevOps-VPC},{Key=Environment,Value=Production}]'

# Modify VPC attributes
aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-support

# Describe VPCs
aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=DevOps-VPC" \
    --output table

# Delete VPC (must delete all resources first)
aws ec2 delete-vpc --vpc-id vpc-12345678
```

### Subnets

```bash
# Create public subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-Public-Subnet-1a},{Key=Type,Value=Public}]'

# Create private subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-Private-Subnet-1a},{Key=Type,Value=Private}]'

# Create database subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.3.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DevOps-DB-Subnet-1a},{Key=Type,Value=Database}]'

# Enable auto-assign public IP for public subnet
aws ec2 modify-subnet-attribute \
    --subnet-id subnet-12345678 \
    --map-public-ip-on-launch

# List subnets
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=vpc-12345678" \
    --query 'Subnets[].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
    --output table
```

### Internet Gateway and NAT Gateway

```bash
# Create Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=DevOps-IGW}]'

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Create Elastic IP for NAT Gateway
aws ec2 allocate-address \
    --domain vpc \
    --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=DevOps-NAT-EIP}]'

# Create NAT Gateway
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678 \
    --tag-specifications 'ResourceType=nat-gateway,Tags=[{Key=Name,Value=DevOps-NAT-GW}]'

# Check NAT Gateway status
aws ec2 describe-nat-gateways \
    --nat-gateway-ids nat-12345678 \
    --output table
```

### Route Tables

```bash
# Create route table for public subnets
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=DevOps-Public-RT}]'

# Create route table for private subnets
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=DevOps-Private-RT}]'

# Add route to Internet Gateway (public route table)
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Add route to NAT Gateway (private route table)
aws ec2 create-route \
    --route-table-id rtb-87654321 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-12345678

# Associate route table with subnet
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678

# List route tables
aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=vpc-12345678" \
    --output table
```

## Security Groups and NACLs

### Security Groups

```bash
# Create security group for web servers
aws ec2 create-security-group \
    --group-name DevOps-WebServer-SG \
    --description "Security group for DevOps web servers" \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=DevOps-WebServer-SG}]'

# Add HTTP and HTTPS rules
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Add SSH rule for management
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --source-group sg-management123

# Add rule for load balancer health checks
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 8080 \
    --source-group sg-loadbalancer123

# Create security group for database
aws ec2 create-security-group \
    --group-name DevOps-Database-SG \
    --description "Security group for DevOps databases" \
    --vpc-id vpc-12345678

# Add MySQL/Aurora rule from web servers only
aws ec2 authorize-security-group-ingress \
    --group-id sg-database123 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-12345678

# List security group rules
aws ec2 describe-security-groups \
    --group-ids sg-12345678 \
    --output table
```

### Network ACLs

```bash
# Create custom Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=DevOps-Custom-NACL}]'

# Add inbound rules
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0

aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0

aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 120 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=22,To=22 \
    --cidr-block 10.0.0.0/16

# Add outbound rules
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=0,To=65535 \
    --cidr-block 0.0.0.0/0 \
    --egress

# Associate NACL with subnet
aws ec2 associate-network-acl \
    --network-acl-id acl-12345678 \
    --subnet-id subnet-12345678
```

## VPC Peering and Transit Gateway

### VPC Peering

```bash
# Create VPC peering connection
aws ec2 create-vpc-peering-connection \
    --vpc-id vpc-12345678 \
    --peer-vpc-id vpc-87654321 \
    --peer-region us-west-2 \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=DevOps-Peering}]'

# Accept VPC peering connection (from peer account/region)
aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id pcx-12345678 \
    --region us-west-2

# Add routes for peering connection
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 10.1.0.0/16 \
    --vpc-peering-connection-id pcx-12345678

# List peering connections
aws ec2 describe-vpc-peering-connections \
    --filters "Name=status-code,Values=active" \
    --output table
```

### Transit Gateway

```bash
# Create Transit Gateway
aws ec2 create-transit-gateway \
    --description "DevOps Transit Gateway" \
    --options AmazonSideAsn=64512,AutoAcceptSharedAttachments=enable,DefaultRouteTableAssociation=enable \
    --tag-specifications 'ResourceType=transit-gateway,Tags=[{Key=Name,Value=DevOps-TGW}]'

# Attach VPC to Transit Gateway
aws ec2 create-transit-gateway-vpc-attachment \
    --transit-gateway-id tgw-12345678 \
    --vpc-id vpc-12345678 \
    --subnet-ids subnet-12345678 subnet-87654321 \
    --tag-specifications 'ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=DevOps-VPC-Attachment}]'

# Create Transit Gateway route table
aws ec2 create-transit-gateway-route-table \
    --transit-gateway-id tgw-12345678 \
    --tag-specifications 'ResourceType=transit-gateway-route-table,Tags=[{Key=Name,Value=DevOps-TGW-RT}]'

# Add route to Transit Gateway route table
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 10.1.0.0/16 \
    --transit-gateway-id tgw-12345678

# List Transit Gateway attachments
aws ec2 describe-transit-gateway-attachments \
    --filters "Name=transit-gateway-id,Values=tgw-12345678" \
    --output table
```

## Load Balancing

### Application Load Balancer (ALB)

```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
    --name DevOps-ALB \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --tags Key=Name,Value=DevOps-ALB Key=Environment,Value=Production

# Create target group
aws elbv2 create-target-group \
    --name DevOps-WebServers-TG \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-protocol HTTP \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --tags Key=Name,Value=DevOps-WebServers-TG

# Register targets
aws elbv2 register-targets \
    --target-group-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/DevOps-WebServers-TG/1234567890123456 \
    --targets Id=i-12345678,Port=80 Id=i-87654321,Port=80

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/DevOps-ALB/1234567890123456 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/DevOps-WebServers-TG/1234567890123456

# Create HTTPS listener with SSL certificate
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/DevOps-ALB/1234567890123456 \
    --protocol HTTPS \
    --port 443 \
    --certificates CertificateArn=arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012 \
    --ssl-policy ELBSecurityPolicy-TLS-1-2-2017-01 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/DevOps-WebServers-TG/1234567890123456
```

### Network Load Balancer (NLB)

```bash
# Create Network Load Balancer
aws elbv2 create-load-balancer \
    --name DevOps-NLB \
    --subnets subnet-12345678 subnet-87654321 \
    --scheme internet-facing \
    --type network \
    --ip-address-type ipv4 \
    --tags Key=Name,Value=DevOps-NLB Key=Environment,Value=Production

# Create target group for NLB
aws elbv2 create-target-group \
    --name DevOps-TCP-Services-TG \
    --protocol TCP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-protocol TCP \
    --health-check-interval-seconds 30 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Create TCP listener
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/DevOps-NLB/1234567890123456 \
    --protocol TCP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/DevOps-TCP-Services-TG/1234567890123456
```

## DNS and Route 53

### Route 53 Configuration

```bash
# Create hosted zone
aws route53 create-hosted-zone \
    --name devops.example.com \
    --caller-reference $(date +%s) \
    --hosted-zone-config Comment="DevOps domain",PrivateZone=false

# Create A record for load balancer
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "api.devops.example.com",
                "Type": "A",
                "AliasTarget": {
                    "DNSName": "DevOps-ALB-1234567890.us-east-1.elb.amazonaws.com",
                    "EvaluateTargetHealth": true,
                    "HostedZoneId": "Z35SXDOTRQ7X7K"
                }
            }
        }]
    }'

# Create CNAME record
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.devops.example.com",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "api.devops.example.com"}]
            }
        }]
    }'

# Create health check
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config Type=HTTPS,ResourcePath=/health,FullyQualifiedDomainName=api.devops.example.com,Port=443,RequestInterval=30,FailureThreshold=3

# List hosted zones
aws route53 list-hosted-zones --output table
```

### Private DNS with Route 53 Resolver

```bash
# Create Route 53 Resolver rule
aws route53resolver create-resolver-rule \
    --creator-request-id $(date +%s) \
    --rule-type FORWARD \
    --domain-name internal.devops.com \
    --target-ips Ip=10.0.0.100,Port=53 Ip=10.0.0.101,Port=53 \
    --name DevOps-Internal-DNS

# Associate resolver rule with VPC
aws route53resolver associate-resolver-rule \
    --resolver-rule-id rslvr-rr-12345678 \
    --vpc-id vpc-12345678 \
    --name DevOps-VPC-Association
```

## VPC Endpoints

### Gateway Endpoints

```bash
# Create S3 Gateway Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678 rtb-87654321 \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": [
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                "Resource": [
                    "arn:aws:s3:::devops-*",
                    "arn:aws:s3:::devops-*/*"
                ]
            }
        ]
    }'

# Create DynamoDB Gateway Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.dynamodb \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678
```

### Interface Endpoints

```bash
# Create EC2 Interface Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.ec2 \
    --vpc-endpoint-type Interface \
    --subnet-ids subnet-12345678 subnet-87654321 \
    --security-group-ids sg-12345678 \
    --private-dns-enabled \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "*",
                "Resource": "*"
            }
        ]
    }'

# Create SSM Interface Endpoints (for Session Manager)
for service in ssm ssmmessages ec2messages; do
    aws ec2 create-vpc-endpoint \
        --vpc-id vpc-12345678 \
        --service-name com.amazonaws.us-east-1.$service \
        --vpc-endpoint-type Interface \
        --subnet-ids subnet-12345678 \
        --security-group-ids sg-12345678 \
        --private-dns-enabled
done

# List VPC endpoints
aws ec2 describe-vpc-endpoints \
    --filters "Name=vpc-id,Values=vpc-12345678" \
    --output table
```

## Network Monitoring and Troubleshooting

### VPC Flow Logs

```bash
# Enable VPC Flow Logs to CloudWatch
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/flowlogs \
    --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flowlogsRole

# Enable VPC Flow Logs to S3
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type s3 \
    --log-destination arn:aws:s3:::devops-vpc-flow-logs/vpc-logs/

# Enable Flow Logs for specific subnet
aws ec2 create-flow-logs \
    --resource-type Subnet \
    --resource-ids subnet-12345678 \
    --traffic-type REJECT \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/subnet-flowlogs

# Query Flow Logs with CloudWatch Insights
aws logs start-query \
    --log-group-name /aws/vpc/flowlogs \
    --start-time 1642694400 \
    --end-time 1642780800 \
    --query-string 'fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol, action
    | filter action = "REJECT"
    | stats count() by srcaddr
    | sort count desc
    | limit 20'
```

### Network Troubleshooting Tools

```bash
# VPC Reachability Analyzer
aws ec2 create-network-insights-path \
    --source i-12345678 \
    --destination i-87654321 \
    --protocol tcp \
    --destination-port 80 \
    --tag-specifications 'ResourceType=network-insights-path,Tags=[{Key=Name,Value=WebServer-Connectivity-Test}]'

# Start network analysis
aws ec2 start-network-insights-analysis \
    --network-insights-path-id nip-12345678

# Get analysis results
aws ec2 describe-network-insights-analyses \
    --network-insights-analysis-ids nia-12345678

# Test network connectivity from EC2 instance
# (Run these commands on EC2 instance)
# Test DNS resolution
nslookup api.devops.example.com

# Test connectivity to specific port
telnet api.devops.example.com 80
nc -zv api.devops.example.com 80

# Test HTTP connectivity
curl -I http://api.devops.example.com/health

# Check routing
ip route show
traceroute api.devops.example.com

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678
```

## Network Security Best Practices

### Security Group Best Practices

```bash
# Create layered security groups
# Web tier security group
aws ec2 create-security-group \
    --group-name DevOps-Web-Tier-SG \
    --description "Web tier security group" \
    --vpc-id vpc-12345678

# Application tier security group
aws ec2 create-security-group \
    --group-name DevOps-App-Tier-SG \
    --description "Application tier security group" \
    --vpc-id vpc-12345678

# Database tier security group
aws ec2 create-security-group \
    --group-name DevOps-DB-Tier-SG \
    --description "Database tier security group" \
    --vpc-id vpc-12345678

# Web tier rules (internet-facing)
aws ec2 authorize-security-group-ingress \
    --group-id sg-web123 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-web123 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# App tier rules (from web tier only)
aws ec2 authorize-security-group-ingress \
    --group-id sg-app123 \
    --protocol tcp \
    --port 8080 \
    --source-group sg-web123

# DB tier rules (from app tier only)
aws ec2 authorize-security-group-ingress \
    --group-id sg-db123 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-app123
```

### Network Segmentation

```bash
# Create separate subnets for different tiers
# Public subnet for load balancers
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-LB-Subnet-1a},{Key=Tier,Value=Public}]'

# Private subnet for web servers
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.10.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Web-Subnet-1a},{Key=Tier,Value=Web}]'

# Private subnet for application servers
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.20.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-App-Subnet-1a},{Key=Tier,Value=Application}]'

# Private subnet for databases
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.30.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-DB-Subnet-1a},{Key=Tier,Value=Database}]'
```

This comprehensive VPC networking guide provides DevOps engineers with the knowledge and tools needed to design, implement, and manage secure and scalable network architectures in AWS.