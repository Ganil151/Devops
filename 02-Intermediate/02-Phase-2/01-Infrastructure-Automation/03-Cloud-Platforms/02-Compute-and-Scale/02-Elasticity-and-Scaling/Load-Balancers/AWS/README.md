# AWS Load Balancing

AWS Elastic Load Balancing (ELB) services and implementation patterns.

## Load Balancer Types

### Application Load Balancer (ALB)
```yaml
# Layer 7 HTTP/HTTPS load balancer
Features:
  - Content-based routing
  - Host-based routing
  - Path-based routing
  - Query string/header routing
  - WebSocket support
  - HTTP/2 support
  - gRPC support
  - Lambda targets
  - IP targets
  - SSL termination
  - WAF integration

Pricing:
  - Hourly rate
  - Load Balancer Capacity Units (LCU)
  - Data processing charges
```

### Network Load Balancer (NLB)
```yaml
# Layer 4 TCP/UDP/TLS load balancer
Features:
  - Ultra-high performance (millions RPS)
  - Static IP addresses
  - Elastic IP support
  - Preserve source IP
  - Cross-zone load balancing
  - TLS termination
  - UDP load balancing
  - Connection-based routing

Use Cases:
  - Gaming applications
  - IoT workloads
  - Real-time communications
  - High-performance computing
```

### Gateway Load Balancer (GWLB)
```yaml
# Layer 3 Gateway + Layer 4 load balancing
Features:
  - Third-party virtual appliances
  - Transparent network gateway
  - GENEVE protocol (port 6081)
  - Centralized deployment model
  - Cross-AZ load balancing
  - Health checks for appliances

Use Cases:
  - Firewalls (Palo Alto, Fortinet)
  - Intrusion detection/prevention
  - Deep packet inspection
  - Network monitoring tools
```

## Configuration Examples

### ALB with Target Groups
```yaml
# CloudFormation template
Resources:
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: my-application-lb
      Type: application
      Scheme: internet-facing
      IpAddressType: ipv4
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      Tags:
        - Key: Environment
          Value: Production

  WebTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: web-targets
      Port: 80
      Protocol: HTTP
      VpcId: !Ref VPC
      TargetType: instance
      HealthCheckEnabled: true
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP
      HealthCheckPort: traffic-port
      HealthCheckIntervalSeconds: 30
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      Matcher:
        HttpCode: 200

  HTTPSListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 443
      Protocol: HTTPS
      Certificates:
        - CertificateArn: !Ref SSLCertificate
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref WebTargetGroup
```

### Advanced Routing Rules
```yaml
# Path-based routing
ListenerRule:
  Type: AWS::ElasticLoadBalancingV2::ListenerRule
  Properties:
    ListenerArn: !Ref HTTPSListener
    Priority: 100
    Conditions:
      - Field: path-pattern
        Values:
          - /api/*
    Actions:
      - Type: forward
        TargetGroupArn: !Ref APITargetGroup

# Host-based routing
HostBasedRule:
  Type: AWS::ElasticLoadBalancingV2::ListenerRule
  Properties:
    ListenerArn: !Ref HTTPSListener
    Priority: 200
    Conditions:
      - Field: host-header
        Values:
          - api.example.com
    Actions:
      - Type: forward
        TargetGroupArn: !Ref APITargetGroup
```

## Auto Scaling Integration

### Launch Template with ALB
```yaml
LaunchTemplate:
  Type: AWS::EC2::LaunchTemplate
  Properties:
    LaunchTemplateName: web-server-template
    LaunchTemplateData:
      ImageId: ami-0abcdef1234567890 # Placeholder: See [Global-Image-Inventory.md](../../../../../../../../../../../../09-Resources/05-Cloud-Metadata/Global-Image-Inventory.md)
      InstanceType: t3.medium
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Web Server $(hostname)</h1>" > /var/www/html/index.html

AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    LaunchTemplate:
      LaunchTemplateId: !Ref LaunchTemplate
      Version: !GetAtt LaunchTemplate.LatestVersionNumber
    MinSize: 2
    MaxSize: 10
    DesiredCapacity: 3
    VPCZoneIdentifier:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    TargetGroupARNs:
      - !Ref WebTargetGroup
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
```

This guide covers AWS load balancing services and implementation patterns.
## �� Junior-Friendly Tip: AMI Management
AMI IDs change per region and are frequently updated with security patches. **Never hardcode them in production.** 

To find the latest Amazon Linux 2023 ID programmatically via the CLI, run:
```bash
aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*-x86_64" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text
```
Check the centralized [Global Image Inventory](../../../../../../../../../../../../09-Resources/05-Cloud-Metadata/Global-Image-Inventory.md) for a curated list of IDs.
