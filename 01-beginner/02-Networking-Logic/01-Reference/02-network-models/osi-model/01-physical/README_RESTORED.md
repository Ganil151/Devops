# 🔌 OSI Layer 1: Physical - The Foundation of All Networks

> **"Before packets can flow, electrons must move. This is where networking becomes physics."**

## 🎯 Why This Matters for DevOps

When your Kubernetes cluster can't reach the database, and `ping` fails, you're debugging **Layer 1**. This layer is about:
- **Cables & Connectors**: The physical medium (copper, fiber, wireless)
- **Electrical Signals**: How bits (0s and 1s) are encoded as voltage changes
- **Hardware Devices**: NICs, hubs, repeaters, and physical ports

---

## 📚 Restored Technical Content

This directory contains the **granular technical specifications** that were part of the original curriculum:

### 🔗 Cables & Connectors
- **[10Base-T](./cables-and-connectors/10-base-t.md)**: 10 Mbps Ethernet over twisted pair
- **[100Base-T](./cables-and-connectors/100base-t.md)**: Fast Ethernet (100 Mbps)
- **[1000Base-T](./cables-and-connectors/1000base-t.md)**: Gigabit Ethernet
- **[Types](./cables-and-connectors/types.md)**: Comprehensive cable taxonomy
- **[Wiring](./cables-and-connectors/wiring.md)**: T568A vs T568B standards

### 🖥️ Physical Devices
- **[Network Interface Card (NIC)](./devices/nic.md)**: Your server's gateway to the network
- **[Hub](./devices/hub.md)**: The "dumb" broadcast device (legacy)
- **[Router Components](./devices/router/)**: Deep dive into Cisco 1841 architecture and routing protocols

---

## 🆘 Senior DevOps Perspective

**Real-World Scenario**: Your cloud VM can't reach the internet.
1. **Layer 1 Check**: Is the virtual NIC attached? (`ip link show`)
2. **Layer 1 Fix**: In AWS, check if the ENI (Elastic Network Interface) is properly attached to the instance.

**The "It's Always the Cable" Rule**: In on-prem datacenters, 40% of network issues are literally unplugged cables or bad crimps. In the cloud, it's misconfigured virtual NICs or security groups blocking at the hypervisor level.

---

*This content was restored from the 2026 Data Recovery Audit to preserve the original technical depth.*
