# Networking Fundamentals Challenges 🕸️

Master the building blocks of cloud connectivity with these hands-on lab tasks.

---

## 🏆 Challenge 01: The CIDR Architect
**Objective**: Design a multi-tier Subnet layout for a production VPC.

1.  **Scenario**: You are given the VPC CIDR `10.0.0.0/16`.
2.  **Task**: Divide this space into the following subnets:
    *   **Public Subnet A** (For Load Balancers): 256 IPs.
    *   **Private Subnet A** (For App Servers): 1024 IPs.
    *   **Database Subnet A** (For RDS): 256 IPs.
3.  **Deliverable**: Provide the CIDR ranges for each (e.g., `10.0.1.0/24`) and explain why you chose those sizes.
4.  **Verification**: Use a [CIDR Calculator](https://cidr.xyz/) to ensure no ranges overlap.

---

## 🏆 Challenge 02: Route Table Troubleshooting
**Objective**: Understand the difference between Private and Public traffic flow.

1.  **Requirement**: Analyze the `routing_error_sim.txt` in the Boilerplates directory.
2.  **Scenario**: An EC2 instance in a "Public" subnet cannot reach the internet.
3.  **Task**: Identify the missing component (Internet Gateway vs NAT Gateway).
4.  **Goal**: Write the specific route entry needed to fix the connection (Destination -> Target).

---

## 🏆 Challenge 03: Security Group vs. NACL
**Objective**: Implement "Defense in Depth" (Security layering).

1.  **Task**: Design a firewall strategy for a Web Server.
2.  **Logic**:
    *   **Security Group**: Allow Port 80/443 from Everywhere. Allow Port 22 from your IP only.
    *   **NACL**: Deny a specific malicious IP `1.2.3.4` from accessing the entire subnet.
3.  **Question**: If the NACL allows Port 80 but the Security Group denies it, what happens to the traffic?

---

## 📁 Solutions
Reference network diagrams and CIDR templates are in the `Boilerplates/` directory.
