# Monitoring and Troubleshooting

Visibility is key to maintaining a healthy network. AWS provides powerful tools to inspect traffic and diagnose connectivity issues.

## 🕵️ VPC Flow Logs

VPC Flow Logs capture information about the IP traffic going to and from network interfaces in your VPC.

### Use Cases
-   **Security Analysis**: See rejected traffic on specific ports (Potential scans/attacks).
-   **Troubleshooting**: Verify if traffic is reaching an instance or being blocked by NACLs/SGs.
-   **Compliance**: Audit network access.

### Format
Flow logs data is stored in CloudWatch Logs or S3.
`version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status`
-   **Example**: `2 123456789010 eni-abc123de 172.31.16.139 172.31.16.21 20641 22 6 20 4249 1418530010 1418530070 ACCEPT OK`

---

## 🔍 VPC Reachability Analyzer

A configuration analysis tool that enables you to perform connectivity testing between resources in your VPC.

-   **Intent-based**: You ask "Can Instance A talk to Instance B?"
-   **No Packets Sent**: It analyzes your configuration (Routes, SGs, NACLs, GWs) mathematically to determine reachability.
-   **Benefit**: Identifies *exactly* which component is blocking traffic (e.g., "Blocked by Security Group sg-123 inbound rule").

---

## 🪞 Traffic Mirroring

Traffic Mirroring copies inbound and outbound traffic from an interface (Source) and sends it to a monitoring appliance (Target) for deep packet inspection.

-   **Use Case**: Intrusion Detection Systems (IDS), packet capture analysis (Wireshark-style).
-   **Target**: Can be another network interface or a Network Load Balancer.

---

## ❓ Interview Questions

1.  **Everything looks correct (SG, Route Table), but I can't ping my instance. What could it be?**
    *   *Answer*: 1. NACLs (Stateless check). 2. OS-level firewall (iptables/Windows Firewall). 3. No Public IP/IGW (if trying from internet).
2.  **Do VPC Flow Logs impact network performance?**
    *   *Answer*: No. They are collected out-of-band by the AWS infrastructure and do not add latency or load to your instances.
3.  **Does Reachability Analyzer send test packets?**
    *   *Answer*: No. It performs a static configuration analysis. This means it doesn't account for OS-level firewalls, only AWS networking config.

---

## 🧠 Quiz Snippet

1.  **Which tool identifies if a Security Group is blocking traffic without sending packets?** `(Reachability Analyzer)`
2.  **Where are VPC Flow Logs stored?** `(CloudWatch Logs or S3)`
3.  **To perform deep packet inspection, which feature do you use?** `(Traffic Mirroring)`
4.  **Can Flow Logs capture the content of the packets?** `(No, only metadata like src, dst, port, action)`
5.  **If a Flow Log shows "REJECT", what likely blocked it?** `(Security Group or NACL)`
