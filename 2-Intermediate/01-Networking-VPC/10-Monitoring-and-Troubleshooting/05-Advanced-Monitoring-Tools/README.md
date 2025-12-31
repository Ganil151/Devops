# Advanced Monitoring Tools

Beyond basic flow logs and reachability tests, AWS offers advanced services for global network visibility, security auditing at scale, and modern application networking monitoring.

## 🌐 AWS Network Manager (Cloud WAN)

Network Manager provides a single dashboard to visualize and monitor your global network across AWS Regions and on-premises locations.

-   **Global View**: Map of your Transit Gateways and their attachments worldwide.
-   **Topology Diagrams**: Automatically generated diagrams of your VPCs, TGWs, and VPNs.
-   **Events & Metrics**: Centralized CloudWatch metrics for your entire global network layer.

## 🛡️ Network Access Analyzer

While Reachability Analyzer checks *can* A talk to B, Network Access Analyzer answers *who* can access my resources according to my security requirements.

-   **Logic**: It uses automated reasoning to identify network paths that lead to your resources.
-   **Use Case**: "Ensure that my database subnets are not reachable from the public internet."
-   **Outcome**: A report identifying any paths that violate your "Network Access Scopes".

## 📡 VPC Lattice Monitoring

VPC Lattice is a modern service-to-service networking layer. Its monitoring is unique because it focuses on **Services** rather than ENIs.

-   **Service Network Logs**: Insights into which services are calling each other.
-   **HTTP Metrics**: Success rates (2xx), client errors (4xx), and server errors (5xx) at the network layer.
-   **Integration**: Seamlessly blends with CloudWatch and X-Ray for distributed tracing.

## 📈 CloudWatch Network Monitor

This tool helps you monitor the performance (packet loss and latency) between your AWS resources and your on-premises network over the internet or Direct Connect.

-   **Probes**: It sends synthetic traffic to monitor real-time health.
-   **Dashboard**: Visualizes network health from the perspective of your hybrid connectivity.

---

## 📖 Stories from the Field: The Compliance Audit

**Scenario**: A financial firm needed to prove to an auditor that none of their S3 buckets containing sensitive data were accessible from an "untrusted" VPC.
**Problem**: They had over 50 VPCs and hundreds of route table entries. Manual verification was impossible.
**Discovery**: They used **Network Access Analyzer**. They defined a "Scope" where the source was any VPC except the "Trusted Admin VPC" and the destination was the S3 Interface Endpoints.
**Outcome**: The tool found 3 VPCs that were accidentally peered to the database network, creating a potential path.
**Resolution**: Removed the illegal peering connections.
**Prevention**: Run Network Access Analyzer periodically as part of a CI/CD pipeline or compliance check.

---

## ❓ Interview Questions

1.  **What is the difference between Network Manager and Reachability Analyzer?**
    *   *Answer*: Network Manager is for high-level global visibility and management. Reachability Analyzer is for granular, hop-by-hop troubleshooting of specific paths.
2.  **How can you identify unwanted internet exposure at scale in AWS?**
    *   *Answer*: Use **Network Access Analyzer** to define scopes and identify any paths from Internet Gateways to private resources.
3.  **Does VPC Lattice replace the need for VPC Flow Logs?**
    *   *Answer*: No. Lattice logs provide application-level (HTTP) visibility for services, while Flow Logs provide bottom-layer (L3/L4) visibility for all ENI traffic.
4.  **How would you monitor the latency of a Direct Connect connection?**
    *   *Answer*: Using **CloudWatch Network Monitor** with probes or by checking Direct Connect specific metrics in CloudWatch.
5.  **Which tool provides automatically generated topology diagrams of your AWS network?**
    *   *Answer*: **AWS Network Manager**.

---

## 🧠 Quiz

1.  **Which tool uses automated reasoning to identify compliance violations?** `(Network Access Analyzer)`
2.  **To visualize a map of your global Transit Gateway architecture, use...** `(Network Manager)`
3.  **True/False: VPC Lattice monitoring includes HTTP status codes.** `(True)`
4.  **Which service monitors the network path between AWS and your office?** `(CloudWatch Network Monitor)`
5.  **Can Network Access Analyzer check for paths through a Transit Gateway?** `(Yes, it analyzes the entire path configuration)`
