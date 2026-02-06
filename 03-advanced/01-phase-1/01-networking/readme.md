---

## 🎯 Junior's Mission: The Silent Timeout
**Scenario**: Your web application is trying to connect to a new database in a separate VPC. The database is up, the credentials are correct, but the connection hangs forever (timeout) instead of saying "Connection Refused."
**Your Goal**: Use **Tcpdump** or **Wireshark** to determine if the packets are being dropped by a **Security Group** (stateless) or a **Network ACL** (stateless), and fix the routing path.

---

## 🏗️ Operational Reality: Production Hazards
Networking is the most common cause of "Phantom Outages" in the cloud.
1.  **UDP Packet Loss**: You switch from HTTP to UDP for a high-speed streaming app. You realize that your Firewall or NAT Gateway is dropping 5% of packets because the "State Table" is full, causing stuttering performance.
2.  **DNS Cache Poisoning/Lag**: You update your database IP. Half your app servers update instantly; the other half are still trying to talk to the old IP because of a hidden "DNS Cache" in the Linux systemd-resolved service.
3.  **MTU Mismatch (Jumbo Frames)**: You connect your data center to AWS. Everything works until you try to send a large file. The connection drops because your internal network uses "Large Packets" (MTU 9000) but the internet only supports "Normal Packets" (MTU 1500).
4.  **CIDR Overlap**: You try to peer two VPCs, but they both use `10.0.0.0/16`. You realize you can't connect them without a complete, destructive rebuild of one of the networks.

---

## 🛠️ The NRE Toolbelt (Network Reliability Engineering)
| Tool/Command | Why it matters |
| :--- | :--- |
| `mtr -rw google.com` | A "Live" traceroute. See exactly which hop in the global internet is causing lag right now. |
| `tcpdump -i eth0 port 80` | "Tapping the wire." Seeing the raw bytes flowing into your server. |
| `nc -zv <ip> 443` | The "Quick Check." Is the port even open for business? |
| `dig +short <domain>` | The "No-Nonsense" DNS check. What is the actual IP the world sees? |
| `ip route get 8.8.8.8` | "Pathfinding." Which interface and gateway will the server use to reach this address? |

---

---

## 📂 Module Structure

### 🔰 Beginner Level
- **[01-Network-Fundamentals](../../../01-beginner/01-phase-1/01-networking/01-network-fundamentals)**: Basics of networking.
- **[02-Network-Models](../../../01-beginner/01-phase-1/01-networking/02-network-models)**: OSI and TCP/IP models.
- **[03-IP-Addressing](../../../01-beginner/01-phase-1/01-networking/03-ip-addressing)**: IPv4, IPv6, Subnetting.
- **[04-Basic-Protocols](../../../01-beginner/01-phase-1/01-networking/04-basic-protocols)**: TCP, UDP, HTTP, DNS.
- **[05-Network-Devices](../../../01-beginner/01-phase-1/01-networking/05-network-devices)**: Routers, Switches, Firewalls.
- **[06-Basic-Troubleshooting](../../../01-beginner/01-phase-1/01-networking/06-basic-troubleshooting)**: Diagnosing connectivity issues.

### 🚀 Intermediate Level
- **[01-VPC-Fundamentals](readme.md)**: Core network services.
- **[02-Subnetting-and-CIDR](readme.md)**: Layer 2 segmentation.
- **[03-Internet-and-NAT-Gateways](readme.md)**: OSPF, BGP, Static routing.
- **[04-Routing-and-Route-Tables](readme.md)**: Firewalls, VPNs, Security Groups.
- **[05-Network-Security-NACLs-SGs](readme.md)**: Remote access and Site-to-Site.
- **[06-VPC-Peering-and-Transit-Gateway](readme.md)**: Distributing traffic.

### 🛡️ Advanced Level
- **[01-Cloud-Networking](./01-cloud-networking/)**: VPCs, Cloud Load Balancers.
- **[02-Container-Networking](./02-container-networking/)**: Docker and CNI.
- **[03-Service-Mesh](./03-service-mesh/)**: Istio, Linkerd.
- **[04-SDN-NFV](./04-sdn-nfv/)**: Software Defined Networking.
- **[05-Network-Automation](./05-network-automation/)**: NetDevOps.
- **[06-Performance-Optimization](./06-performance-optimization/)**: Tuning and latency reduction.

---

## 1. The OSI Model (Simplified)

While there are 7 layers, DevOps engineers focus on these core areas:
- **Layer 3 (Network)**: Routing and IP addresses.
- **Layer 4 (Transport)**: TCP vs. UDP and Port numbers.
- **Layer 7 (Application)**: HTTP, DNS, and TLS.

---

## 2. Core Concepts
- **IP Addressing**: Public vs. Private IPs.
- **Subnetting**: Dividing a network into smaller, manageable segments.
- **DNS**: The phonebook of the internet. Converting `example.com` to an IP.
- **Load Balancing**: Distributing traffic across multiple servers.

---

## 3. Tooling Reference
- **Check Connectivity**: `ping`, `telnet`, `nc` (Netcat).
- **Trace Route**: `traceroute` to see where a packet is dropping.
- **DNS Lookup**: `dig`, `nslookup`.
- **Interface Info**: `ip addr`, `ifconfig`.

---

## 4. Linux Networking Diagnostic Methodology
When a connection fails, follow this "inside-out" approach common in Linux administration:

<b>1. Check Local Interface**: Is the NIC up?</b>
<details>
<summary>Show Answer</summary>
Answer: `ip link`
</details>

<b>2. Check Local IP**: Does the machine have the expected IP?</b>
<details>
<summary>Show Answer</summary>
Answer: `ip addr`
</details>

<b>3. Check Local Routing**: Is there a default gateway?</b>
<details>
<summary>Show Answer</summary>
Answer: `ip route`
</details>

4.  **Check Remote Reachability**: Can you ping the gateway? Can you ping `8.8.8.8`?
<b>5. Check DNS**: Can you resolve a hostname?</b>
<details>
<summary>Show Answer</summary>
Answer: `dig google.com`
</details>

<b>6. Check Application Port**: Is the service actually listening on the target port?</b>
<details>
<summary>Show Answer</summary>
Answer: `ss -tuln`
</details>


## 5. Security & Stability Best Practices
Based on industry standards and the *Linux Command Line* guide:
- **Minimize the Attack Surface**: Disable any network service you aren't using. Use `ss -tuln` to find "ghost" services.
- **Prefer Static IPs for Servers**: Use DHCP reservations or static configurations for critical infrastructure to avoid IP changes.
- **Monitor Bandwidth**: Use `iftop` or `nload` to identify processes hogging the connection.
- **Immutable Configurations**: In DevOps, define your network (VPCs, Security Groups) as code (e.g., Terraform) rather than manual clicks.

---

## 🛠️ The DevOps Toolbelt
Mastering theory is only half the battle. You must master the diagnostic and scanning tools used in the field:
- **[Networking Tools Deep Dive](../../../readme.md)**: Master **Wireshark**, **Nmap**, and **Tcpdump**.

-----

## 🏆 Related Certifications

### CompTIA Network+
*The Foundation of Networking Analysis*
- **Focus**: Vendor-neutral networking fundamentals.
- **Key DevOps Relevance**: 
    - **Ports & Protocols**: Knowing valid vs. ephemeral ports for Security Groups.
    - **OSI Model**: Troubleshooting "Is it the app (Layer 7) or the firewall (Layer 4)?"
    - **Subnetting**: Calculating CIDR blocks for VPC design.
- **Exam Code**: N10-008 / N10-009

### Cisco Certified Network Associate (CCNA)
*The Industry Standard for Network Engineering*
- **Focus**: Routing, Switching, IP services, and Security fundamentals.
- **Key DevOps Relevance**: 
    - **Routing Logic**: Essential for debugging complex VPC Peering and Transit Gateways.
    - **CLI Mastery**: Comfort with command-line configuration (Cisco IOS mirrors many Linux network concepts).
    - **Automation**: New CCNA exams include JSON, REST APIs, and SDN controller concepts relevant to IaC.
- **Exam Code**: 200-301

---

 **Next Step**: Learn how to securely log into these networked systems in the [Linux Basics Module](../../../readme.md).