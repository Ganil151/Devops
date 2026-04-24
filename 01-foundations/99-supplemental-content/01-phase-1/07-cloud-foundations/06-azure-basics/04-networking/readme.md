# Azure Networking

Comprehensive guide to Azure networking services including Virtual Networks, Load Balancers, and security.

## Virtual Networks
```bash
# Create virtual network
az network vnet create \
  --resource-group myResourceGroup \
  --name myVNet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name mySubnet \
  --subnet-prefix 10.0.1.0/24

# Create additional subnet
az network vnet subnet create \
  --resource-group myResourceGroup \
  --vnet-name myVNet \
  --name mySubnet2 \
  --address-prefix 10.0.2.0/24

# Create network security group
az network nsg create \
  --resource-group myResourceGroup \
  --name myNSG

# Add security rule
az network nsg rule create \
  --resource-group myResourceGroup \
  --nsg-name myNSG \
  --name allow-ssh \
  --protocol tcp \
  --priority 1000 \
  --destination-port-range 22 \
  --access allow
```

## Load Balancing
```bash
# Create public IP
az network public-ip create \
  --resource-group myResourceGroup \
  --name myPublicIP \
  --sku Standard

# Create load balancer
az network lb create \
  --resource-group myResourceGroup \
  --name myLoadBalancer \
  --public-ip-address myPublicIP \
  --frontend-ip-name myFrontEnd \
  --backend-pool-name myBackEndPool

# Create health probe
az network lb probe create \
  --resource-group myResourceGroup \
  --lb-name myLoadBalancer \
  --name myHealthProbe \
  --protocol tcp \
  --port 80

# Create load balancer rule
az network lb rule create \
  --resource-group myResourceGroup \
  --lb-name myLoadBalancer \
  --name myHTTPRule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name myFrontEnd \
  --backend-pool-name myBackEndPool \
  --probe-name myHealthProbe
```

## Application Gateway
```bash
# Create application gateway
az network application-gateway create \
  --name myAppGateway \
  --location eastus \
  --resource-group myResourceGroup \
  --vnet-name myVNet \
  --subnet mySubnet \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address myPublicIP
```

This guide covers Azure networking for secure and scalable cloud connectivity.

## Real World Scenarios

### Scenario 1: Hybrid Connectivity
**Context:** Connect on-prem Office to Azure VNet for secure internal access.
**Solution:**
- **VPN Gateway:** Site-to-Site (S2S) VPN.
- **Local Network Gateway:** Represents on-prem VPN device.
**Benefit:** Encrypted tunnel over public internet. Cheaper than ExpressRoute.

### Scenario 2: High Availability Web App
**Context:** Web app must survive region failure.
**Solution:**
- **Azure Front Door (Global LB):** Route traffic to two regions.
- **Application Gateway (Regional LB):** Load balance within each region.
**Benefit:** Global redundancy and WAF protection.

---

## Interview Questions

### Basic Level
1. **What is a VNet?**
   - A private network in Azure, logically isolated from others.
2. **What is an NSG (Network Security Group)?**
   - A firewall for subnets or NICs. Contains Allow/Deny rules based on 5-tuple (Source IP, Sport, Dest IP, Dport, Protocol).
3. **What is VNet Peering?**
   - Connecting two VNets (same or different region) so resources can talk privately using Microsoft backbone.

### Intermediate Level
4. **Difference between Azure Load Balancer and Application Gateway?**
   - **Load Balancer:** Layer 4 (TCP/UDP). Fast, simple.
   - **App Gateway:** Layer 7 (HTTP/HTTPS). WAF, SSL termination, URL routing.
5. **What is a "Service Endpoint"?**
   - Secure and direct connectivity to Azure services (like SQL/Storage) over the Azure backbone network, restricting public access.
6. **When would you use ExpressRoute?**
   - For dedicated, private, high-speed connection (SLA) from on-prem to Azure (bypassing public internet).

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Global VNet Peering (Best answer for direct connection, though others work)</b>
</details>


<b>2. NSGs evaluate rules by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Priority (Lower number processed first)</b>
</details>


<b>3. A Standard Load Balancer operates at which OSI layer?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Layer 4 (Transport)</b>
</details>


<b>4. Which service provides a Web Application Firewall (WAF)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Application Gateway (or Front Door)</b>
</details>


<b>5. Can you have overlapping IP ranges in peered VNets?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No</b>
</details>


<b>6. Azure Bastion provides:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Secure RDP/SSH via browser</b>
</details>


<b>7. Traffic Manager uses what to route traffic?</b>
<details>
<summary>Show Answer</summary>
Answer: A) DNS</b>
</details>


<b>8. What protects against DDoS attacks?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure DDoS Protection (Basic is free, Standard is paid)</b>
</details>


<b>9. Which resource is required for a Site-to-Site VPN?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Virtual Network Gateway</b>
</details>


<b>10. NAT Gateway allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Outbound internet connectivity for private subnets</b>
</details>


<b>11. Can NSGs be applied to a specific VM network interface (NIC)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>12. Default max subnets in a VNet?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 3000</b>
</details>


<b>13. Which provides private connectivity to Azure PaaS services?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Private Link</b>
</details>


<b>14. Is VNet Peering transitive?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No (Unless using Route Server or NVA)</b>
</details>


<b>15. Application Security Groups (ASGs) allow you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Group VMs for NSG rules (e.g., Src: "WebServers", Dest: "DBServers")</b>
</details>


<b>16. Which Load Balancer SKU supports Availability Zones?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Standard</b>
</details>


<b>17. Azure Front Door is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A Global CDN + Load Balancer + WAF</b>
</details>


<b>18. Can you change the CIDR of a VNet after creation?</b>
<details>
<summary>Show Answer</summary>
Answer: A) You can add address spaces, but removing/modifying existing used ranges is hard/impossible without recreating.</b>
</details>


<b>19. VPN Gateway SKU determines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Bandwidth and Max Tunnels</b>
</details>


<b>20. What is unique about "GatewaySubnet"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) It must be named exactly "GatewaySubnet" for VPN/ExpressRoute Gateways to work</b>
</details>


<b>21. Azure DNS zones host:</b>
<details>
<summary>Show Answer</summary>
Answer: A) DNS records for a domain</b>
</details>
