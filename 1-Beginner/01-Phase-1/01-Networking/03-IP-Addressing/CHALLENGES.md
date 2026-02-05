# 🛠️ IP Addressing & Subnetting: Hands-On Challenges

> **"Theory is when you know how it works. Practice is when it works and you don't know why. For an SRE, we want both. Master the math, then master the cloud."**

---

## 🟢 Level 1: The Binary Basics (Junior)

### Objective
Understand the relationship between decimal numbers and binary bits.

### Tasks
1. **Decimal to Binary**: Convert the following IP address into its 32-bit binary equivalent:
   - `172.16.254.1`
2. **Binary to Decimal**: Convert this binary stream into a dotted-decimal IP:
   - `11000000.10101000.00001010.01100100`
3. **Class Identification**: Identify the Class (A, B, or C) for these IPs:
   - `10.50.1.1`
   - `192.168.100.254`
   - `172.17.0.1`

### Success Criteria
- [ ] Correct binary conversion for Task 1.
- [ ] Correct decimal conversion for Task 2.
- [ ] All classes correctly identified.

---

## 🟡 Level 2: The CIDR Architect (Intermediate)

### Objective
Design a subnetting plan for a small startup office using a single `/24` block.

### Scenario
You have the block `192.168.10.0/24`. You must divide it into **4 equal subnets** for different departments.

### Tasks
1. **Calculate the Prefix**: What is the new CIDR notation for the 4 subnets?
2. **Define the Ranges**: List the **Network Address**, **Usable IP Range**, and **Broadcast Address** for each of the 4 subnets.
3. **Host Count**: How many usable host IPs are available in each subnet?

### Success Criteria
- [ ] Correct CIDR notation (Hint: `/26`).
- [ ] 4 distinct, non-overlapping ranges listed.
- [ ] Correct host count per subnet (Hint: 256 / 4 - 2).

---

## 🔴 Level 3: The Cloud Network Engineer (Advanced)

### Objective
Design a multi-tier VPC architecture for a production environment.

### Scenario
You are building a new AWS VPC. You have been assigned the CIDR block `10.0.0.0/16`. You need to design the following:
1. **Public Tier**: For Load Balancers (Requires ~200 IPs).
2. **Application Tier**: For backend servers (Requires ~4000 IPs).
3. **Database Tier**: For RDS instances (Requires ~50 IPs, highly isolated).

### Tasks
1. **Allocate the Blocks**: Choose the most efficient CIDR block for each tier without wasting space.
2. **Security Rule**: Explain why you would use a private subnet for the Database Tier.
3. **NAT Logic**: Which tier needs a **NAT Gateway** to reach the internet, and which tier should the Gateway live in?

### Success Criteria
- [ ] Efficient CIDR allocation (e.g., `/24`, `/20`, `/26`).
- [ ] Correct security justification.
- [ ] Correct NAT placement logic.

---

## 🏆 Bonus: The "Slash 30" Mystery
**Question**: In many networking environments, we use a `/30` subnet for a connection between two routers. 
1. Why do we use exactly `/30`? 
2. How many usable IPs does it provide? 
3. Why wouldn't we use a `/31` or `/32`?

---

### 📖 Completion Checklist
- [ ] I can calculate a subnet ID and broadcast address in my head.
- [ ] I understand why we skip `.0` and `.255` for hosts.
- [ ] I can explain the difference between a Public and Private IP to a non-technical person.
