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

### Advanced Level
7. **Explain "User Defined Routes" (UDR).**
   - Custom routes in a route table to override default Azure system routes (e.g., force traffic through a virtual firewall appliance).
8. **What is Azure Firewall?**
   - Managed, cloud-native network security service that protects Azure VNet resources. Statefull firewall with high availability.
9. **How does "Private Link" differ from Service Endpoints?**
   - Private Link brings the service *into* your VNet via a private IP (NIC). Service Endpoints route *to* the service public endpoint via backbone.

---

## Quiz: Azure Networking

<details>
<summary><b>1. Which service allows connecting VNets in different regions?</b></summary>
A) Global VNet Peering<br>
B) VPN<br>
C) ExpressRoute<br>
D) All of the above<br>
<br>
<b>Answer: A) Global VNet Peering (Best answer for direct connection, though others work)</b>
</details>

<details>
<summary><b>2. NSGs evaluate rules by:</b></summary>
A) Priority (Lower number processed first)<br>
B) Alphabetical order<br>
C) Random<br>
D) Packet size<br>
<br>
<b>Answer: A) Priority (Lower number processed first)</b>
</details>

<details>
<summary><b>3. A Standard Load Balancer operates at which OSI layer?</b></summary>
A) Layer 4 (Transport)<br>
B) Layer 7 (Application)<br>
C) Layer 3 (Network)<br>
D) Layer 2 (Data Link)<br>
<br>
<b>Answer: A) Layer 4 (Transport)</b>
</details>

<details>
<summary><b>4. Which service provides a Web Application Firewall (WAF)?</b></summary>
A) Application Gateway (or Front Door)<br>
B) Load Balancer<br>
C) NSG<br>
D) NAT Gateway<br>
<br>
<b>Answer: A) Application Gateway (or Front Door)</b>
</details>

<details>
<summary><b>5. Can you have overlapping IP ranges in peered VNets?</b></summary>
A) No<br>
B) Yes<br>
<br>
<b>Answer: A) No</b>
</details>

<details>
<summary><b>6. Azure Bastion provides:</b></summary>
A) Secure RDP/SSH via browser<br>
B) VPN<br>
C) DNS<br>
D) Storage<br>
<br>
<b>Answer: A) Secure RDP/SSH via browser</b>
</details>

<details>
<summary><b>7. Traffic Manager uses what to route traffic?</b></summary>
A) DNS<br>
B) BGP<br>
C) IP Tables<br>
D) Magic<br>
<br>
<b>Answer: A) DNS</b>
</details>

<details>
<summary><b>8. What protects against DDoS attacks?</b></summary>
A) Azure DDoS Protection (Basic is free, Standard is paid)<br>
B) NSG<br>
C) WAF<br>
D) VPN<br>
<br>
<b>Answer: A) Azure DDoS Protection (Basic is free, Standard is paid)</b>
</details>

<details>
<summary><b>9. Which resource is required for a Site-to-Site VPN?</b></summary>
A) Virtual Network Gateway<br>
B) Application Gateway<br>
C) NAT Gateway<br>
D) Service Gateway<br>
<br>
<b>Answer: A) Virtual Network Gateway</b>
</details>

<details>
<summary><b>10. NAT Gateway allows:</b></summary>
A) Outbound internet connectivity for private subnets<br>
B) Inbound connectivity<br>
C) VPN<br>
D) DNS<br>
<br>
<b>Answer: A) Outbound internet connectivity for private subnets</b>
</details>

<details>
<summary><b>11. Can NSGs be applied to a specific VM network interface (NIC)?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>12. Default max subnets in a VNet?</b></summary>
A) 3000<br>
B) 1<br>
C) 10<br>
D) Unlimited<br>
<br>
<b>Answer: A) 3000</b>
</details>

<details>
<summary><b>13. Which provides private connectivity to Azure PaaS services?</b></summary>
A) Azure Private Link<br>
B) Public IP<br>
C) Internet Gateway<br>
D) NAT<br>
<br>
<b>Answer: A) Azure Private Link</b>
</details>

<details>
<summary><b>14. Is VNet Peering transitive?</b></summary>
A) No (A<->B and B<->C does not mean A<->C)<br>
B) Yes<br>
<br>
<b>Answer: A) No (Unless using Route Server or NVA)</b>
</details>

<details>
<summary><b>15. Application Security Groups (ASGs) allow you to:</b></summary>
A) Group VMs for NSG rules (e.g., Src: "WebServers", Dest: "DBServers")<br>
B) Group Users<br>
C) Group subscriptions<br>
D) Encrypt data<br>
<br>
<b>Answer: A) Group VMs for NSG rules (e.g., Src: "WebServers", Dest: "DBServers")</b>
</details>

<details>
<summary><b>16. Which Load Balancer SKU supports Availability Zones?</b></summary>
A) Standard<br>
B) Basic<br>
C) Free<br>
D) None<br>
<br>
<b>Answer: A) Standard</b>
</details>

<details>
<summary><b>17. Azure Front Door is:</b></summary>
A) A Global CDN + Load Balancer + WAF<br>
B) A regional LB<br>
C) A door<br>
D) A firewall<br>
<br>
<b>Answer: A) A Global CDN + Load Balancer + WAF</b>
</details>

<details>
<summary><b>18. Can you change the CIDR of a VNet after creation?</b></summary>
A) You can add address spaces, but removing/modifying existing used ranges is hard/impossible without recreating.<br>
B) Yes easily<br>
<br>
<b>Answer: A) You can add address spaces, but removing/modifying existing used ranges is hard/impossible without recreating.</b>
</details>

<details>
<summary><b>19. VPN Gateway SKU determines:</b></summary>
A) Bandwidth and Max Tunnels<br>
B) Color<br>
C) Region<br>
D) IP Address<br>
<br>
<b>Answer: A) Bandwidth and Max Tunnels</b>
</details>

<details>
<summary><b>20. What is unique about "GatewaySubnet"?</b></summary>
A) It must be named exactly "GatewaySubnet" for VPN/ExpressRoute Gateways to work<br>
B) It is free<br>
C) It is huge<br>
D) It is public<br>
<br>
<b>Answer: A) It must be named exactly "GatewaySubnet" for VPN/ExpressRoute Gateways to work</b>
</details>

<details>
<summary><b>21. Azure DNS zones host:</b></summary>
A) DNS records for a domain<br>
B) Websites<br>
C) VMs<br>
D) Files<br>
<br>
<b>Answer: A) DNS records for a domain</b>
</details>