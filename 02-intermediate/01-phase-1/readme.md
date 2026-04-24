# 🏗️ Phase 1: Intermediate Foundations (The Junior to Senior Transition)

> **"Listen up, Junior. In the Beginner phase, you learned how to use tools. In this phase, you are going to learn how to build the systems those tools live on. You are moving from 'Tool User' to 'System Designer'."**

---

## 🧠 The Mental Model: The Systems Skyscraper

**The Junior Struggle**: "I can spin up an EC2 instance and run a container. Isn't that enough? Why do I need to learn the deep internals of Networking and Linux kernel observability?"

**The Senior Solution**: You realize that while a skyscraper looks beautiful from the outside, it only stays standing because of the **foundations** and **structural engineering** you can't see.
- **Networking**: The elevators and plumbing that connect every floor.
- **Linux**: The structural steel that holds everything up.
- **Procedures**: The fire drills and safety protocols that prevent a catastrophe.

---

## 🆚 Junior Way vs. Senior Way

| Feature | The Junior Way (Problematic) | The Senior Way (Architected) |
|:---|:---|:---|
| **Networking** | "Just put it in a public subnet" | **Private VPCs** with Transit Gateways |
| **Linux** | Manual `systemctl restart` | **Auto-remediating** systemd units |
| **Changes** | "I'll just edit it on the server" | **Version Control** only (No SSH edits) |
| **Incidents** | Panicking on a Slack call | Following the **Immutable Runbook** |
| **Data** | "I have a monthly backup" | **Multi-AZ Replication** & PITR |

---

## 🗺️ Learning Path

### 🕸️ [01. Networking](./01-networking/readme.md)
*Junior, you can't just 'hope' data reaches the server.* 
Master advanced CIDR subnetting, VPC Peering, Transit Gateways, and the dark arts of BGP and Hybrid Cloud connectivity.

### 🐧 [02. Linux Observability](./02-linux/readme.md)
*Restarting a server isn't 'troubleshooting'.* 
Dive into intermediate system administration, deep process management, and using `eBPF` and `strace` to see what the kernel is actually doing.

### 📜 [03. Runbooks & Procedures](./03-runbooks-procedures/readme.md)
*If it isn't documented, it's a liability.* 
Learn to write professional SOPs, design auto-remediation patterns, and handle the "3 AM Incident" with calm, automated precision.

### 📁 [04. Repository Management](readme.md)
*Git is for collaboration, not just storage.* 
Enterprise Git strategies, multi-repo vs. monorepo architectures, and mastering branching models that survive 100+ developers.

### 💾 [05. Databases](readme.md)
*Data is the company's lifeblood.* 
Go beyond simple DBs to managed RDS scaling, NoSQL performance tuning, and high-availability disaster recovery strategies.

---

## 🎯 Phase Goal
Junior, by the end of this phase, you will understand the "under-the-hood" systems of the cloud so well that when you start automating them in Phase 2, you'll be building on bedrock, not sand.

---
*Next Step: Stop guessing and start designing. Head into [01. Networking](./01-networking/readme.md).*


---
## 🧭 Additional Modules
- [04 Databases](04-databases/readme.md)
