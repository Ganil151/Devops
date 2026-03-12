# Hands-on Route 53 Guide: Console & CLI

This guide provides practical instructions for creating hosted zones, managing DNS records, and setting up health checks.

## 1. Creating a Public Hosted Zone

### Using the Management Console
1. Navigate to the **Route 53 Console**.
2. Click **Hosted zones** -> **Create hosted zone**.
3. **Domain name**: `myapp.example.com` (use a subdomain for testing).
4. **Type**: **Public hosted zone**.
5. Click **Create hosted zone**.
6. **Note the Name Servers (NS)**: You must update your registrar with these values if you want the domain to resolve.

### Using the AWS CLI
```bash
# Create a public hosted zone
# --caller-reference should be a unique string for each request
aws route53 create-hosted-zone \
    --name myapp.example.com \
    --caller-reference "my-app-v1-$(date +%s)"

# Get the Hosted Zone ID
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name myapp.example.com --query 'HostedZones[0].Id' --output text)
echo "Hosted Zone ID: $ZONE_ID"
```

## 2. Managing DNS Records

### CLI: Creating an A Record
Create a file named `create-record.json`:
```json
{
  "Comment": "Update A record for myapp",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "myapp.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "192.0.2.44" }]
      }
    }
  ]
}
```

```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch file://create-record.json
```

### CLI: Creating an Alias Record (pointing to ELB)
Unlike standard records, Alias records don't have a TTL because they point directly to the underlying AWS resource.

```json
{
  "Comment": "Creating Alias record for Load Balancer",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "myapp.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K", 
          "DNSName": "dualstack.my-load-balancer-123.us-east-1.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
```
> [!NOTE]
> The `HostedZoneId` in `AliasTarget` is the ID of the **Load Balancer's region**, not your own Hosted Zone ID.

## 3. Configuring Health Checks

Route 53 can monitor the health of your application's endpoints.

### CLI: Create a Health Check
```bash
aws route53 create-health-check \
    --caller-reference "web-health-v1" \
    --health-check-config '{
        "IPAddress": "192.0.2.44",
        "Port": 80,
        "Type": "HTTP",
        "ResourcePath": "/health",
        "RequestInterval": 30,
        "FailureThreshold": 3
    }'
```

## 4. Testing Resolution

You can test how Route 53 will respond to a query using the CLI:
```bash
aws route53 test-dns-answer \
    --hosted-zone-id $ZONE_ID \
    --record-name myapp.example.com \
    --record-type A
```

## 5. Cleaning Up
```bash
# Delete all non-NS/SOA records first, then delete the zone
aws route53 delete-hosted-zone --id $ZONE_ID
```

---
**Next Step**: Master [Advanced Route 53 Patterns & Troubleshooting](../../../../../../../03-advanced/02-phase-2/01-part-1-the-blueprint/01-cloud-architecture/01-enterprise-multi-cloud/14-networking-route53/route53-advanced-patterns.md)
