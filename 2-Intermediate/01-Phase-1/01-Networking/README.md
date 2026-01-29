# 🌐 Intermediate Networking Track

Welcome to the **Intermediate Networking** module of the DevOps curriculum. This track is designed to take you from basic connectivity concepts to complex cloud architectures and advanced security patterns.

## Core Concept: The OSI Model as Mental Framework
**[REFERENCE: TCP/IP Stack Deep Dive](./REFERENCE/TCP-IP-Stack-Deep-Dive-Ref.md)**

Networking is not about memorizing commands; it's about understanding **layers of abstraction**:
- **Layer 1-2 (Physical/Data Link)**: Bits and MAC addresses. Switches operate here.
- **Layer 3 (Network)**: IP addresses and routing. Routers operate here.
- **Layer 4 (Transport)**: TCP (reliable) vs UDP (fast). Load balancers operate here.
- **Layer 7 (Application)**: HTTP, DNS, SSH. Application firewalls operate here.

> See **[TCP-IP-Stack-Deep-Dive-Ref.md](./REFERENCE/TCP-IP-Stack-Deep-Dive-Ref.md)** for the TCP 3-way handshake, subnetting calculations, and protocol internals.

## Enterprise Governance & Security
**[REFERENCE: Enterprise Network Architecture](./REFERENCE/Enterprise-Network-Architecture-Ref.md)**

At scale, networking is about **defense in depth**:
- **Segmentation**: Use VLANs to isolate traffic. Never run a flat network.
- **Stateful Firewalls**: Track connection state. Auto-allow return traffic for established connections.
- **DMZ Architecture**: Isolate public-facing services from internal network with dual firewalls.
- **Zero Trust**: Never trust, always verify. Implement micro-segmentation and identity-based access.

> See **[Enterprise-Network-Architecture-Ref.md](./REFERENCE/Enterprise-Network-Architecture-Ref.md)** for firewall architectures, load balancing strategies (L4 vs L7), and Zero Trust implementation patterns.

---

## 📋 Table of Contents

### 1. [Part 1: Fundamentals](./Part-1-Fundamentals/README.md)
*The building blocks of networking.*
- **Overview**: Basic networking concepts (IP, Subnetting, DNS, DHCP, Routing).
- **Key Topics**: OSI & TCP/IP Models, IPv4 vs IPv6, Common Protocols.
- **Examples**: Troubleshooting commands.
- **Diagrams**: Network topologies.

### 2. [Part 2: Advanced Networking](./Part-2-Advanced-Networking/README.md)
*Securing and scaling traffic.*
- **Overview**: VLANs, Switching, Advanced Security, and Load Balancing.
- **Key Topics**: Segmentation, Firewalls, ACLs, Layer 4/7 Balancing.
- **Configuration Files**: Real-world templates.
- **Scripts**: Automation of networking tasks.

### 3. [Part 3: Tools and Utilities](./Part-3-Tools-and-Utilities/README.md)
*Managing and monitoring the stack.*
- **Overview**: Essential tools for observability and cloud-native networking.
- **Key Tools**: Wireshark, Nmap, TCPDump, AWS VPC, Azure VNet.
- **Documentation**: Usage guides and best practices.
- **Examples**: Real-world use cases.

---

## 🚀 Learning Path

Networking is not just a prerequisite; it's a continuous practice. As you move through these parts, focus on:

1. **Understanding the Theory**: Don't skip the OSI model; it's the "grammar" of networking.
2. **Hands-on Labs**: Use the tools in Part 3 to verify the concepts in Parts 1 and 2.
3. **Cloud Context**: Connect traditional networking knowledge to how it's implemented in AWS/Azure/GCP.

---

## 🛠️ Log of Actions
- ✅ **Consolidation**: Fully migrated all contents from `01-Networking-BACKUP-20260119_021128`.
- ✅ **Reorganization**: Structured the directory into `Part-1-Fundamentals`, `Part-2-Advanced-Networking`, and `Part-3-Tools-and-Utilities`.
- ✅ **Audit & Merge**: Identified and resolved duplicate folders (Network Security, Load Balancing).
- ✅ **Verification**: Confirmed accessibility of all 16 modules.
- ✅ **Cleanup**: Deleted the now-redundant backup directory.
