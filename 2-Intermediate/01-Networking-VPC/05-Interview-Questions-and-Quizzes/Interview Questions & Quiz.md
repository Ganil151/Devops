## Networking & VPC
Prepare for technical interviews and validate your understanding of cloud networking.

---

## 🎤 Top 15 Networking & VPC Interview Questions

### 🔰 Basic Questions
1. **What is a VPC?**
   - *Answer:* A Virtual Private Cloud (VPC) is a logically isolated section of a cloud provider's network where you can launch resources.
2. **What is the difference between a Public Subnet and a Private Subnet?**
   - *Answer:* A public subnet has a direct route to an Internet Gateway (IGW) in its route table, whereas a private subnet does not.
3. **What is a CIDR block?**
   - *Answer:* Classless Inter-Domain Routing. It's a method for allocating IP addresses and IP routing (e.g., `10.0.0.0/16`).
4. **How many IP addresses are available in a /24 subnet?**
   - *Answer:* 256 total addresses (2^8), but cloud providers like AWS reserve 5, leaving 251 usable.
5. **What is an Internet Gateway (IGW)?**
   - *Answer:* A horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet.

### ⚙️ Intermediate Questions
6. **Explain the difference between a NAT Gateway and a NAT Instance.**
   - *Answer:* A NAT Gateway is a managed service that scales automatically and is highly available. A NAT Instance is a single EC2 instance that you manage manually (now largely deprecated in favor of Gateways).
7. **What is VPC Peering?**
   - *Answer:* A networking connection between two VPCs that enables you to route traffic between them using private IP addresses.
8. **Is VPC Peering transitive?**
   - *Answer:* No. If VPC A is peered with VPC B, and VPC B is peered with VPC C, VPC A cannot communicate with VPC C through VPC B.
9. **Compare Security Groups and Network ACLs.**
   - *Answer:* Security Groups are stateful (if you allow inbound, outbound is automatically allowed) and applied at the instance level. NACLs are stateless and applied at the subnet level.
10. **Explain Application Load Balancer (ALB) vs. Network Load Balancer (NLB).**
    - *Answer:* ALB operates at Layer 7 (HTTP/HTTPS) and can do path-based routing. NLB operates at Layer 4 (TCP/UDP) and is designed for extreme performance and static IPs.

### 🚀 Advanced-ish Questions
11. **What is a Bastion Host?**
    - *Answer:* A special-purpose server in a public subnet used to provide access to instances in a private subnet (usually via SSH or RDP).
12. **How do you handle overlapping CIDR blocks when you need to connect two VPCs?**
    - *Answer:* Standard VPC Peering won't work. You need to use PrivateLink, a Transit Gateway with mapping, or a VPN/Proxy solution.
13. **What are Flow Logs?**
    - *Answer:* A feature that enables you to capture information about the IP traffic going to and from network interfaces in your VPC.
14. **What is an Egress-Only Internet Gateway?**
    - *Answer:* A stateful gateway that provides egress-only access for IPv6 traffic from your VPC to the internet.
15. **What is the purpose of a VPC Endpoint?**
    - *Answer:* It enables you to privately connect your VPC to supported cloud services (like S3 or DynamoDB) without requiring an internet gateway, NAT device, or VPN connection.

---

## 🧠 Networking & VPC Knowledge Quiz

**1. Which CIDR block provides the MOST IP addresses?**
- A) `10.0.0.0/16`
- B) `10.0.0.0/24`
- C) `10.0.0.0/28`
- D) `10.0.0.0/8`
*Answer: D*

**2. Where should a NAT Gateway be placed?**
- A) Private Subnet
- B) Public Subnet
- C) It doesn't matter
- D) On-premises
*Answer: B*

**3. Which component is required for a subnet to be "Public"?**
- A) NAT Gateway
- B) S3 Endpoint
- C) Internet Gateway (and a route to it)
- D) VPC Peering
*Answer: C*

**4. Security Groups are:**
- A) Stateless
- B) Stateful
- C) Only for Windows
- D) Applied to Subnets
*Answer: B*

**5. You need to perform path-based routing (`/api` vs `/blog`). Which LB do you use?**
- A) NLB
- B) Gateway Load Balancer
- C) ALB
- D) Classic Load Balancer
*Answer: C*

**6. What is the limit for VPC Peering connections?**
- A) 1
- B) 50
- C) 125 (active by default, can be increased)
- D) Unlimited
*Answer: C*

**7. Which IP addresses are reserved by AWS in every subnet?**
- A) The first 5
- B) The first 4 and the last 1
- C) Only the first 1
- D) None
*Answer: B*

**8. To allow a private instance to download software updates, you need:**
- A) An IGW in the private subnet
- B) A NAT Gateway in a public subnet
- C) A Public IP on the private instance
- D) A VPC Peering connection
*Answer: B*

**9. NACLs are processed:**
- A) Before Security Groups (for inbound traffic)
- B) After Security Groups
- C) At the same time
- D) Only on Tuesdays
*Answer: A*

**10. VPC Peering across regions is called:**
- A) Local Peering
- B) Global Peering
- C) Inter-Region Peering
- D) Shadow Peering
*Answer: C*

**11. Which service allows you to connect multiple VPCs and on-premises networks through a central hub?**
- A) VPC Peering
- B) Transit Gateway
- C) Direct Connect
- D) API Gateway
*Answer: B*

**12. What happens to traffic for a stateful Security Group?**
- A) You must allow both inbound and outbound explicitly
- B) If you allow inbound, outbound is automatically allowed
- C) Outbound is always blocked
- D) It depends on the NACL
*Answer: B*

**13. Which protocol does an ALB NOT support?**
- A) HTTP
- B) HTTPS
- C) gRPC
- D) UDP
*Answer: D (NLB supports UDP)*

**14. What is the standard private IP range for Class C?**
- A) `10.0.0.0 - 10.255.255.255`
- B) `172.16.0.0 - 172.31.255.255`
- C) `192.168.0.0 - 192.168.255.255`
- D) `8.8.8.8`
*Answer: C*

**15. A Route Table entry `0.0.0.0/0` represents:**
- A) Local traffic
- B) Traffic to a specific server
- C) All traffic (the "Default Route")
- D) No traffic
*Answer: C*

**16. Which Load Balancer is best for handling millions of requests with ultra-low latency?**
- A) ALB
- B) NLB
- C) CLB
- D) ProxyLB
*Answer: B*

**17. VPC Peering supports:**
- A) IPv4 only
- B) IPv6 only
- C) Both IPv4 and IPv6
- D) IPX/SPX
*Answer: C*

**18. Can you change the CIDR block of a VPC after it is created?**
- A) Yes, anytime
- B) No (you can add secondary blocks, but not change the primary)
- C) Only if it's empty
- D) Yes, via the API only
*Answer: B*

**19. What is "Overlapping CIDR"?**
- A) When two VPCs have different IP ranges
- B) When two subnets share the same AZ
- C) When two networks use the same IP address range
- D) A type of security breach
*Answer: C*

**20. A "Bastion Host" should have:**
- A) No Public IP
- B) A Public IP and reside in a public subnet
- C) Be in a private subnet
- D) Have access to the whole internet
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 15 Interview Questions
- [x] Understand the difference between Layer 4 and Layer 7 routing
