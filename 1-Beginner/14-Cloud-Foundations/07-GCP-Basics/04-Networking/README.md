# Google Cloud Networking

Comprehensive guide to GCP networking services including VPC, Load Balancing, and Cloud CDN.

## Virtual Private Cloud (VPC)
```bash
# Create VPC network
gcloud compute networks create my-vpc --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create my-subnet \
  --network=my-vpc \
  --range=10.0.1.0/24 \
  --region=us-central1

# Create firewall rule
gcloud compute firewall-rules create allow-ssh \
  --network=my-vpc \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=ssh-server

# Create firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
  --network=my-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-server
```

## Load Balancing
```bash
# Create instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=web-server \
  --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx'

# Create managed instance group
gcloud compute instance-groups managed create web-group \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a

# Create health check
gcloud compute health-checks create http web-health-check \
  --port=80 \
  --request-path=/

# Create backend service
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --health-checks=web-health-check \
  --global

# Add instance group to backend service
gcloud compute backend-services add-backend web-backend \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --global

# Create URL map
gcloud compute url-maps create web-map \
  --default-service=web-backend

# Create HTTP proxy
gcloud compute target-http-proxies create web-proxy \
  --url-map=web-map

# Create global forwarding rule
gcloud compute forwarding-rules create web-rule \
  --global \
  --target-http-proxy=web-proxy \
  --ports=80
```

## Cloud CDN
```bash
# Enable Cloud CDN on backend service
gcloud compute backend-services update web-backend \
  --enable-cdn \
  --global

# Set cache mode
gcloud compute backend-services update web-backend \
  --cache-mode=CACHE_ALL_STATIC \
  --global
```

## VPN and Interconnect
```bash
# Create VPN gateway
gcloud compute vpn-gateways create my-vpn-gateway \
  --network=my-vpc \
  --region=us-central1

# Create VPN tunnel
gcloud compute vpn-tunnels create my-tunnel \
  --peer-address=203.0.113.12 \
  --shared-secret=mysharedsecret \
  --target-vpn-gateway=my-vpn-gateway \
  --region=us-central1

# Create route for VPN
gcloud compute routes create my-route \
  --network=my-vpc \
  --next-hop-vpn-tunnel=my-tunnel \
  --next-hop-vpn-tunnel-region=us-central1 \
  --destination-range=192.168.1.0/24
```

This guide covers GCP networking for secure and scalable cloud connectivity.

## Real World Scenarios

### Scenario 1: Global Load Balancing
**Context:** App needs to serve users in US, EU, and Asia with single Anycast IP.
**Solution:**
- **Global HTTP(S) Load Balancer:** Single frontend IP (`34.x.x.x`) announced globally.
- **Backends:** Instance Groups in `us-central1`, `europe-west1`, `asia-east1`.
**Benefit:** Traffic routed to closest region automatically. Ultra-low latency.

### Scenario 2: Connecting to On-Prem
**Context:** Securely connect Corp data center to GCP VPC.
**Solution:**
- **Cloud VPN:** For lower throughput (up to 3Gbps per tunnel), encrypted over internet.
- **Cloud Interconnect:** For high throughput (10Gbps+), dedicated physical link (SLA).
**Benefit:** Hybrid cloud connectivity.

---

## Interview Questions

### Basic Level
1. **What is a VPC in GCP vs AWS?**
   - **GCP VPC:** Global resource. Subnets are Regional.
   - **AWS VPC:** Regional resource.
2. **What are firewall rules in GCP?**
   - Stateful filtering of traffic to/from VM instances. Can target by tag, service account, or IP ranges.
3. **What is "Shared VPC"?**
   - Allows sharing a network from a host project to service projects. Keeps network centralized (Admin) while teams manage their own resources.

### Intermediate Level
4. **Explain Cloud Load Balancing types.**
   - **Global HTTP(S):** Layer 7, global anycast.
   - **Network TCP/UDP:** Layer 4, regional or global.
   - **Internal:** Private load balancing within VPC.
5. **What is VPC Peering?**
   - Connecting two VPCs privately (internal IP communication). Routes are exchanged automatically.
6. **What is Cloud NAT?**
   - Managed service for "Network Address Translation". Allows private instances to access the internet (outbound) without public IPs.

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Global</b>
</details>


<b>2. Subnets in GCP are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Regional</b>
</details>


<b>3. Which LB uses a single Anycast IP worldwide?</b>
<details>
<summary>Show Answer</summary>
Answer: A) HTTP(S) Load Balancer</b>
</details>


<b>4. Firewall rules are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Stateful</b>
</details>


<b>5. To allow VMs without public IPs to reach the internet:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Cloud NAT</b>
</details>


<b>6. Shared VPC allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Centralized network control across multiple projects</b>
</details>


<b>7. Cloud DNS is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A scalable, reliable, managed DNS service (Authoritative)</b>
</details>


<b>8. Cloud Armor provides:</b>
<details>
<summary>Show Answer</summary>
Answer: A) WAF (Web App Firewall) and DDoS protection</b>
</details>


<b>9. VPC Peering is transitive:</b>
<details>
<summary>Show Answer</summary>
Answer: A) False (If A-B and B-C, A cannot talk to C)</b>
</details>


<b>10. Default Network creates:</b>
<details>
<summary>Show Answer</summary>
Answer: A) One subnet in every region automatically</b>
</details>


<b>11. Target Tags in firewalls allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Applying rules to specific instances</b>
</details>


<b>12. Cloud Router is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Dynamic routing (BGP) with VPN/Interconnect</b>
</details>


<b>13. Premium Tier Network:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Uses Google's global backbone (Current default)</b>
</details>


<b>14. Private Google Access allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Accessing Google APIs from private IPs</b>
</details>


<b>15. Legacy Networks (Non-VPC) are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Deprecated</b>
</details>


<b>16. Can overlapping subnets exist in the SAME VPC?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No</b>
</details>


<b>17. Packet Mirroring is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Inspecting traffic (IDS/IPS), troubleshooting</b>
</details>


<b>18. Backend Services group:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Backends (Instance groups, NEGs) for Load Balancing</b>
</details>


<b>19. Serverless VPC Access allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Cloud Functions/App Engine to access VPC resources</b>
</details>


<b>20. Which protocol does Ping use?</b>
<details>
<summary>Show Answer</summary>
Answer: A) ICMP (Must be allowed in Firewall, usually 'deny' by default)</b>
</details>


<b>21. Max throughput of Cloud VPN tunnel?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 3 Gbps (HA VPN supports pairing tunnels for more)</b>
</details>
