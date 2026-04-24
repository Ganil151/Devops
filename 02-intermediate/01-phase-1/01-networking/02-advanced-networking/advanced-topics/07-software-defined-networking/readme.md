# 🤖 Module 09: Software-Defined Networking (SDN)

## 📖 Overview
In traditional networking, the "brains" (Control Plane) and the "brawn" (Data Plane) are locked inside the same physical switch. **SDN** decouples them, allowing for centralized, programmatic control of the entire network. This is the technology that makes AWS VPCs and Kubernetes networking possible.

## 🎓 Learning Objectives
- ✅ Understand the difference between the **Control Plane** and **Data Plane**.
- ✅ Master the concept of **Overlay Networks** (VXLAN, Geneve).
- ✅ Learn about **SDN Controllers** (OpenDaylight, Cisco ACI).
- ✅ Understand how SDN enables **Infrastructure as Code (IaC)**.

## 🔑 Key Concepts
### 1. The Decoupled Stack
- **Control Plane**: The intelligence that decides where traffic *should* go (The Map).
- **Data Plane**: The hardware/software that actually moves the packets (The Road).

### 2. Network Virtualization
Just as a Hypervisor creates virtual VMs on physical servers, SDN creates virtual networks on physical switches.

### 3. VXLAN (Virtual Extensible LAN)
The protocol used to create "Encapsulated" Layer 2 networks on top of a Layer 3 infrastructure. This overcomes the 4096 VLAN limit.

---
Check the main Part 2 README for next steps.
