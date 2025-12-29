# Networking-VPC: Real-Life Scenarios

Put your knowledge to the test with these practical troubleshooting and architectural challenges.

---

## 🛠️ Scenario 1: The "No Internet" Mystery
**Setting:** You have a web application running on an EC2 instance in a private subnet. You can SSH into it via a Bastion host, but the instance cannot run `sudo yum update` to download security patches.

**Investigation:**
1. Check the Route Table of the private subnet. Is there a route for `0.0.0.0/0`?
2. If there is a route, where does it point? (It should point to a NAT Gateway).
3. Check the NAT Gateway status. Is it "Available"?
4. Check the Public Subnet where the NAT Gateway lives. Does THAT subnet have a route to an Internet Gateway?

**The Fix:**
Ensure the private subnet has a route: `0.0.0.0/0 -> nat-gateway-id`. Ensure the NAT Gateway is in a public subnet with a route: `0.0.0.0/0 -> igw-id`.

---

## 🏗️ Scenario 2: The Overlapping CIDR Nightmare
**Setting:** Company A (10.0.0.0/16) is acquiring Company B (10.0.0.0/16). They need to connect their VPCs to share a database.

**The Problem:** Standard VPC Peering is impossible because the CIDRs overlap exactly.

**The Solutions:**
1. **The Hard Way:** Re-build one of the VPCs with a new CIDR (very high effort).
2. **The Modern Way:** Use **PrivateLink**. Create an Interface VPC Endpoint for the specific service (database) so it can be accessed via a private IP in the other VPC without full peering.
3. **The Proxy Way:** Set up a Nginx or HAProxy in a middle-man network to translate requests.

---

## 🌩️ Scenario 3: Microservices Path-Based Routing
**Setting:** You have three microservices: `Users`, `Inventory`, and `Orders`. You want them all to be accessible under one domain: `api.myapp.com`.

**The Solution:**
1. Use an **Application Load Balancer (ALB)**.
2. Create three Target Groups: `tg-users`, `tg-inventory`, `tg-orders`.
3. Configure the ALB Listener Rules:
   - IF path is `/users*` THEN forward to `tg-users`.
   - IF path is `/inventory*` THEN forward to `tg-inventory`.
   - IF path is `/orders*` THEN forward to `tg-orders`.
4. Result: Single entry point, simplified DNS, and cost savings.

---

## 🔓 Scenario 4: Bastion Host vs. SSM
**Setting:** Your security team wants to close all SSH ports (22) to the internet to reduce the attack surface.

**The Options:**
1. **Bastion Host:** Keep port 22 open ONLY to your specific office IP. Users SSH to Bastion, then SSH to private instances.
2. **SSM Session Manager (The Recommended Way):** Remove the Bastion host. Install the SSM Agent on your instances. Use IAM roles to grant access. Users can "shell" into instances via the AWS CLI or Console without any ports (including 22) being open to the internet.

---

## 🤝 Scenario 5: Transitive Peering Confusion
**Setting:** You have a Shared Services VPC (Central). You peer VPC Alpha to Central and VPC Beta to Central. Instances in Alpha need to talk to instances in Beta.

**The Problem:** Alpha cannot talk to Beta. Peering is **Non-Transitive**.

**The Fixes:**
1. **Full Mesh:** Peer Alpha directly to Beta. (Okay for 3 VPCs, nightmare for 100).
2. **Transit Gateway:** Replace peering with a Transit Gateway. Connect all three VPCs to the TGW. It acts as a hub-and-spoke router, enabling all-to-all communication with simple routing.

---

## 💡 Key Takeaway
Architecture isn't just about making things work; it's about making them secure, scalable, and maintainable. These scenarios represent the real-world trade-offs you will make as a DevOps Engineer.
