# Advanced Cloud Networking Architecture

This guide covers advanced networking scenarios, including complex Transit Gateway architectures, hybrid connectivity, and advanced DNS configurations.

## Advanced Transit Gateway

### Multi-Region Peering
Connect Transit Gateways in different regions to establish a global network.

```bash
# Create Transit Gateway Peering Attachment
aws ec2 create-transit-gateway-peering-attachment \
    --transit-gateway-id tgw-12345678 \
    --peer-transit-gateway-id tgw-87654321 \
    --peer-region us-west-2 \
    --peer-account-id 123456789012
```

### Route Table Association & Propagation
Control traffic flow between attachments using separate route tables (e.g., creating isolated "Prod" and "Dev" domains that share a "Shared Services" domain).

## Hybrid Connectivity

### Direct Connect
Specifics on setting up Direct Connect Gateways and associating them with Transit Gateways for high-bandwidth, low-latency hybrid clouds.

### VPN Acceleration
Using Global Accelerator with Site-to-Site VPN for improved performance across public internet.

## Advanced Route 53

### Route 53 Resolver
Forward DNS queries from on-premises to AWS and vice versa.

```bash
# Create Resolver Rule (Forwarding)
aws route53resolver create-resolver-rule \
    --rule-type FORWARD \
    --domain-name internal.corp \
    --target-ips Ip=192.168.1.50
```

### Traffic Flow & Geolocation
Routing policies based on user location or endpoint health.

## Network Troubleshooting & Analysis

### Reachability Analyzer
Statically analyze connectivity between two points in your network without sending packets.

```bash
aws ec2 create-network-insights-path \
    --source i-12345678 \
    --destination i-87654321 \
    --protocol tcp \
    --destination-port 80
```

### Traffic Mirroring
Copy network traffic from an ENI to a target (like an IDS/IPS appliance) for deep packet inspection.

## Cost Optimization
- Data transfer costs (Inter-AZ vs Inter-Region)
- VPC Endpoint usage vs NAT Gateway costs
- Right-sizing NAT Gateways
