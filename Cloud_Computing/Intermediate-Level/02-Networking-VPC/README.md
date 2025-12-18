# Intermediate Cloud Networking: VPC & Connectivity

This guide covers intermediate networking concepts including VPC Peering, Transit Gateways, Load Balancing, and VPC Endpoints.

## VPC Peering

VPC peering is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses.

### Creating a Peering Connection
```bash
# Create VPC peering connection
aws ec2 create-vpc-peering-connection \
    --vpc-id vpc-12345678 \
    --peer-vpc-id vpc-87654321 \
    --peer-region us-west-2 \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=DevOps-Peering}]'

# Accept VPC peering connection (must be done in the peer account/region)
aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id pcx-12345678 \
    --region us-west-2
```

### Routing for Peering
To enable communication, you must add a route to your route table pointing to the peering connection.
```bash
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 10.1.0.0/16 \
    --vpc-peering-connection-id pcx-12345678
```

## Transit Gateway (Fundamentals)

AWS Transit Gateway acts as a cloud router that connects your VPCs and on-premises networks.

```bash
# Create Transit Gateway
aws ec2 create-transit-gateway \
    --description "DevOps Transit Gateway" \
    --tag-specifications 'ResourceType=transit-gateway,Tags=[{Key=Name,Value=DevOps-TGW}]'

# Attach VPC to Transit Gateway
aws ec2 create-transit-gateway-vpc-attachment \
    --transit-gateway-id tgw-12345678 \
    --vpc-id vpc-12345678 \
    --subnet-ids subnet-12345678 subnet-87654321
```

## Load Balancing

### Application Load Balancer (ALB)
Layer 7 load balancing for HTTP/HTTPS traffic.

```bash
# Create ALB
aws elbv2 create-load-balancer \
    --name DevOps-ALB \
    --subnets subnet-12345678 subnet-87654321 \
    --scheme internet-facing \
    --type application
```

### Network Load Balancer (NLB)
Layer 4 load balancing for TCP/UDP traffic, capable of handling millions of requests per second.

## VPC Endpoints

VPC endpoints allow you to privately connect your VPC to supported AWS services and VPC endpoint services powered by PrivateLink without requiring an internet gateway.

### Gateway Endpoints (S3 & DynamoDB)
```bash
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678
```

### Interface Endpoints (PrivateLink)
Uses ENIs in your subnets to connect to services like EC2, SSM, etc.

## VPC Flow Logs

Capture information about the IP traffic going to and from network interfaces in your VPC.

```bash
# Enable VPC Flow Logs to CloudWatch
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/flowlogs
```
