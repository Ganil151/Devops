# Monitoring and Troubleshooting

Visibility is the foundation of a reliable cloud network. This module covers the tools and strategies for monitoring traffic, analyzing connectivity, and diagnosing complex networking issues in AWS.

## 📚 Learning Path

| # | Topic | Description | Key Tools |
| :--- | :--- | :--- | :--- |
| **01** | [**Flow Logs**](./01-VPC-Flow-Logs-Network-Visibility/README.md) | Network Metadata | CloudWatch, Athena, REJECT/ACCEPT |
| **02** | [**Reachability Analyzer**](./02-Reachability-Analyzer-Network-Insights/README.md) | Path Analysis | Static Analysis, Hop-by-hop |
| **03** | [**Traffic Mirroring**](./03-Traffic-Mirroring-Deep-Packet-Inspection/README.md) | Packet Capture | IDS/IPS, VXLAN, ENI Mirroring |
| **04** | [**Common Scenarios**](./04-Common-Troubleshooting-Scenarios/README.md) | The "Gotchas" | Asymmetric Routing, NACL statelessness |
| **05** | [**Advanced Tools**](./05-Advanced-Monitoring-Tools/README.md) | Enterprise Visibility | Network Manager, Access Analyzer |

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Quiet Deny" Security Incident
**Problem**: A sensitive database was supposed to be isolated, but the security team suspected an unauthorized internal service was trying to scan its ports.
**Crisis**: There were no logs on the database server itself for "connection attempts," making it look like everything was fine.
**Outcome**: High risk of undetected reconnaissance.
**Solution**: Enable **VPC Flow Logs** for the database subnet. By querying the logs in **Amazon Athena**, they identified thousands of `REJECT` records coming from a compromised instance in a different VPC.
**Result**: The compromised instance was isolated, and the attacker was stopped before they could find a vulnerability.

### Scenario 2: The "Routing Loop" Mystery
**Problem**: An engineer added a new Transit Gateway attachment. Suddenly, all traffic to the secondary data center stopped working.
**Crisis**: Looking at the route tables, everything *seemed* correct. The team spent 4 hours arguing over whether it was a firewall issue or a routing issue.
**Outcome**: The customer had a complete outage of their hybrid link.
**Solution**: Used **AWS Reachability Analyzer**. Instead of guessing, they ran a path analysis from the Source EC2 to the Customer Gateway. The tool identified a **Circular Route** in the Transit Gateway route table where the packet was being sent back to its source.
**Result**: The route was fixed in 5 minutes, and the total RTO was minimized.

### Scenario 3: The "Ghost In The Shell" App Bug
**Problem**: A proprietary application was intermittently dropping connections, and the application logs only showed "Connection Reset by Peer."
**Crisis**: Metadata logs (Flow Logs) weren't enough because they only showed that the connection was closed, not *why* or which packet caused it.
**Outcome**: Developers blamed the network, and the network team blamed the code.
**Solution**: Implemented **VPC Traffic Mirroring**. They mirrored the traffic from the production ENI to a dedicated analysis instance running Wireshark.
**Result**: They discovered that a specific Malformed HTTP header was causing the application's internal TCP stack to crash and reset the connection. The code was fixed, and the "Network" was exonerated.

---

## ❓ Interview Questions

1.  **What is the difference between VPC Flow Logs and Traffic Mirroring?**
    - *Answer*: **VPC Flow Logs** capture metadata (Source/Dest IP, Ports, Protocol, Packets, Bytes, and Accept/Reject status). **Traffic Mirroring** captures the actual payload (the full packet) and sends it to a destination for deep packet inspection (DPI). Flow Logs are for "Who talked to whom," while Mirroring is for "What exactly did they say."
2.  **How does 'Reachability Analyzer' work without sending real traffic?**
    - *Answer*: It uses **automated reasoning** and static analysis to examine the configuration of your VPC (Route Tables, NACLs, SGs, Gateways). It builds a model of the network logic and determines if a path is theoretically possible.
3.  **A flow log entry shows 'REJECT'. What are the two most likely causes?**
    - *Answer*: 1. A **Security Group** is blocking the traffic. 2. A **Network ACL** is blocking the traffic. (NACLs are usually the culprit for strange rejects because they are stateless).
4.  **How do you monitor the 'Health' of your entire global network in AWS?**
    - *Answer*: Use **AWS Network Manager**. It provides a centralized dashboard to visualize your global network (managed through Transit Gateway), monitor performance metrics across regions, and identify topology issues across both AWS and On-Premises.
5.  **Explain the use of 'VPC Flow Logs' for cost optimization.**
    - *Answer*: You can use Flow Logs to identify "Inter-AZ" traffic. By analyzing which instances are talking across Availability Zones, you can identify high-cost data transfers and move those resources into the same AZ to eliminate the inter-zone transfer fee.
6.  **What tool would you use to verify that your AWS environment follows 'Least Privilege' networking?**
    - *Answer*: **VPC Network Access Analyzer**. It allows you to specify "Intent-based" requirements (e.g., "Public subnets should only reach the DB on port 3306") and it will identify any security configurations that violate those requirements.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. Which tool captures IP traffic metadata (Src, Dest, Port)?**
- A) CloudTrail
- B) VPC Flow Logs
- C) Inspector
- D) Config

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: VPC Flow Logs capture the full packet payload.**
- A) True
- B) False (Metadata only)

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**3. 'Reachability Analyzer' is a _____ analysis tool.**
- A) Dynamic (Sends real packets)
- B) Static/Automated Reasoning (Analyzes config)
- C) Manual
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. To see the actual content of an HTTP request, you must use:**
- A) Flow Logs
- B) Traffic Mirroring
- C) Route Table
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. Flow Log status 'NODATA' means:**
- A) The network is broken
- B) No traffic happened during the interval
- C) You are out of money
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. Which tool helps find 'Circular Routes' or 'Blackholes' quickly?**
- A) IAM
- B) Reachability Analyzer
- C) S3
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: You can publish Flow Logs to an S3 bucket.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. Traffic Mirroring uses which protocol to encapsulate traffic?**
- A) HTTP
- B) VXLAN (Port 4789)
- C) SSH
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. 'SKIPDATA' in a flow log indicates:**
- A) Success
- B) Traffic was not recorded due to an internal error or limit
- C) The user skipped the log
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. Which AWS service is best for querying Flow Logs using SQL?**
- A) Lambda
- B) Amazon Athena
- C) DynamoDB
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. 'Mirror Filter' in Traffic Mirroring determines:**
- A) The color of the packets
- B) Which traffic should be captured (Inbound/Outbound/Ports)
- C) The price
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. True/False: Reachability analyzer tells you IF an SG is blocking traffic.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**13. Which component stores the captured packets in Traffic Mirroring?**
- A) The Internet
- B) A Mirror Target (ENI or NLB)
- C) A piece of paper
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. Flow Log field 'action' contains which two values?**
- A) GOOD / BAD
- B) ACCEPT / REJECT
- C) START / STOP
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. 'Network Access Analyzer' helps identify:**
- A) Slow servers
- B) Unintended network access paths (e.g., Internet to DB)
- C) Employee passwords
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: You can enable Flow Logs for a specific ENI.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. VPC Flow Logs are _____ available to the client.**
- A) Instantly (Real-time)
- B) After a 1-minute or 10-minute aggregation window
- C) Next week
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Which tool provides a 'Global Topology' view?**
- A) Reachability Analyzer
- B) Network Manager
- C) VPC Lattice
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. Traffic Mirroring is often used for:**
- A) Watching movies
- B) Intrusion Detection Systems (IDS)
- C) Backups
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: CloudWatch Logs Insights can be used to visualize Flow Log trends.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Asymmetric Routing' means:**
- A) Traffic is fast
- B) The return path is different from the request path (and often blocked)
- C) The network is balanced
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. How many 'Hops' does Reachability Analyzer show?**
- A) 1
- B) All components in the path (IGW, NACL, SG, etc.)
- C) 0
- D) 100

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. 'Log Format' in Flow Logs can be:**
- A) Plain text only
- B) Default or Custom (Adding fields like VPC-ID, Subnet-ID)
- C) An image
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. Monitoring is the _____ of the network team.**
- A) Eyes
- B) Hands
- C) Feet
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**25. A well-monitored VPC reduces _____ (Mean Time To Repair).**
- A) Costs
- B) MTTR
- C) Staff
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
