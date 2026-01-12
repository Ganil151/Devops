# Traffic Mirroring: Deep Packet Inspection

VPC Traffic Mirroring is a feature that you can use to copy network traffic from an elastic network interface (ENI) of type `interface`. You can then send the traffic to out-of-band security and monitoring appliances for deep packet inspection.

## 🏗️ Core Components

1.  **Mirror Source**: The ENI from which traffic is copied.
2.  **Mirror Target**: The destination for mirrored traffic. Can be another ENI (Internal ELB) or a Network Load Balancer (NLB).
3.  **Mirror Filter**: A set of rules that defines which inbound/outbound traffic is mirrored (based on protocol, port, and IP range).
4.  **Mirror Session**: A connection between a source, target, and filter.

```mermaid
graph LR
    subgraph "Production VPC"
        Source["Source ENI (App Instance)"]
    end

subgraph "Security VPC"
        Target["Target (NLB / Monitoring ENI)"]
        Scanner["Security Appliance (IDS/IPS)"]
    end

Source -.-> |Mirrored Packets (VXLAN)| Target
    Target --> Scanner
```

## 🎯 Use Cases

-   **Intrusion Detection (IDS)**: Monitor for known attack signatures without slowing down production traffic.
-   **Troubleshooting**: Capture full packets (PCAP) to diagnose complex application-level connectivity issues (e.g., SSL/TLS handshake failures).
-   **Security Forensics**: Archive packet data for post-incident analysis.

## ⚠️ Performance and Constraints

-   **VXLAN Encapsulation**: Mirrored traffic is encapsulated in VXLAN (UDP port 4789). Your target appliance must support VXLAN.
-   **Throughput**: Traffic Mirroring is out-of-band but contributes to the instance's overall network bandwidth limit.
-   **MTU Considerations**: The VXLAN header adds overhead. To avoid fragmentation, ensure the MTU of the mirrored traffic is handled appropriately (often by using Jumbo Frames if supported).

---

## 📖 Stories from the Field: The Hidden Malware

**Scenario**: A company's SIEM detected an unusual amount of outbound traffic to a known malicious IP, but VPC Flow Logs only showed `ACCEPT` to port 443.
**Discovery**: The security team enabled **Traffic Mirroring** for that ENI and sent the traffic to a Suricata (IDS) instance. By inspecting the actual packet payloads, they discovered encrypted C2 (Command and Control) traffic hiding within legitimate HTTPS sessions.
**Resolution**: The infected instance was isolated and terminated.
**Prevention**: Use Traffic Mirroring for high-value targets where flow logs (metadata only) are insufficient for threat detection.

---

## ❓ Interview Questions

1.  **What is the main difference between VPC Flow Logs and Traffic Mirroring?**
    *   *Answer*: Flow logs capture metadata (headers only), while Traffic Mirroring captures the entire packet payload.
2.  **What encapsulation protocol does AWS use for Traffic Mirroring?**
    *   *Answer*: VXLAN (Virtual Extensible LAN).
3.  **Can you mirror traffic from multiple sources to a single target?**
    *   *Answer*: Yes, you can consolidate traffic from multiple ENIs into one monitoring appliance or NLB.
4.  **How is mirrored traffic prioritized compared to production traffic?**
    *   *Answer*: Production traffic (regular traffic) has higher priority. If the instance hits its network bandwidth capacity, mirrored traffic is dropped first.
5.  **Which type of Load Balancer can be a Traffic Mirror target?**
    *   *Answer*: Network Load Balancer (NLB) or Gateway Load Balancer (GWLB) endpoints.

---

## 🧠 Quiz

1.  **What port does VXLAN use for Traffic Mirroring?** `(UDP 4789)`
2.  **To capture full packet data for Wireshark analysis, which tool do you use?** `(Traffic Mirroring)`
3.  **True/False: Traffic Mirroring increases the latency of the source instance.** `(False - it is out-of-band)`
4.  **Which component defines *what* traffic to capture (e.g., port 80 only)?** `(Mirror Filter)`
5.  **Can an Application Load Balancer (ALB) be a Traffic Mirror target?** `(No, only ENIs or NLBs)`