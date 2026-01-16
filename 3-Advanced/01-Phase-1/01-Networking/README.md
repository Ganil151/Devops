# Advanced Networking: Enterprise Hybrid Cloud & Performance

Networking is the plumbing of the internet. For a DevOps engineer, understanding how data moves through a network is critical for debugging connectivity and securing services.

---

## 📂 Module Structure

### 🔰 Beginner Level
- **[01-Network-Fundamentals](../../../1-Beginner/01-Phase-1/01-Networking/01-Network-Fundamentals)**: Basics of networking.
- **[02-Network-Models](../../../1-Beginner/01-Phase-1/01-Networking/02-Network-Models)**: OSI and TCP/IP models.
- **[03-IP-Addressing](../../../1-Beginner/01-Phase-1/01-Networking/03-IP-Addressing)**: IPv4, IPv6, Subnetting.
- **[04-Basic-Protocols](../../../1-Beginner/01-Phase-1/01-Networking/04-Basic-Protocols)**: TCP, UDP, HTTP, DNS.
- **[05-Network-Devices](../../../1-Beginner/01-Phase-1/01-Networking/05-Network-Devices)**: Routers, Switches, Firewalls.
- **[06-Basic-Troubleshooting](../../../1-Beginner/01-Phase-1/01-Networking/06-Basic-Troubleshooting)**: Diagnosing connectivity issues.

### 🚀 Intermediate Level
- **[01-VPC-Fundamentals](../../../2-Intermediate/01-Phase-1/01-Networking/01-VPC-Fundamentals)**: Core network services.
- **[02-Subnetting-and-CIDR](../../../2-Intermediate/01-Phase-1/01-Networking/02-Subnetting-and-CIDR)**: Layer 2 segmentation.
- **[03-Internet-and-NAT-Gateways](../../../2-Intermediate/01-Phase-1/01-Networking/03-Internet-and-NAT-Gateways)**: OSPF, BGP, Static routing.
- **[04-Routing-and-Route-Tables](../../../2-Intermediate/01-Phase-1/01-Networking/04-Routing-and-Route-Tables)**: Firewalls, VPNs, Security Groups.
- **[05-Network-Security-NACLs-SGs](../../../2-Intermediate/01-Phase-1/01-Networking/05-Network-Security-NACLs-SGs)**: Remote access and Site-to-Site.
- **[06-VPC-Peering-and-Transit-Gateway](../../../2-Intermediate/01-Phase-1/01-Networking/06-VPC-Peering-and-Transit-Gateway)**: Distributing traffic.

### 🛡️ Advanced Level
- **[01-Cloud-Networking](./01-Cloud-Networking/)**: VPCs, Cloud Load Balancers.
- **[02-Container-Networking](./02-Container-Networking/)**: Docker and CNI.
- **[03-Service-Mesh](./03-Service-Mesh/)**: Istio, Linkerd.
- **[04-SDN-NFV](./04-SDN-NFV/)**: Software Defined Networking.
- **[05-Network-Automation](./05-Network-Automation/)**: NetDevOps.
- **[06-Performance-Optimization](./06-Performance-Optimization/)**: Tuning and latency reduction.

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
- **[Networking Tools Deep Dive](../../../README.md)**: Master **Wireshark**, **Nmap**, and **Tcpdump**.

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

 **Next Step**: Learn how to securely log into these networked systems in the [Linux Basics Module](../../../README.md).