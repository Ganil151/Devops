# 🏗️ Phase 1: Advanced Foundations & Deep Roots

> **"You cannot build a skyscraper on a swamp. You need bedrock."**

Welcome to Phase 1 of the Advanced Curriculum. Before we build global multi-cloud fleets (Phase 2) or break them with Chaos Engineering (Phase 3), we must master the **First Principles** of the systems we operate.

In this phase, we move beyond "Using the Tool" to "Understanding the Engine."

---

## 🗺️ The Advanced Foundations Map

### 🌐 [01-Networking](./01-networking/)
**From "Connectivity" to "Traffic Engineering"**
- **The Protocol Stack**: Deep dives into TCP flow control, BGP routing, and MTU fragmentation.
- **The Cloud Network**: Transit Gateways, Direct Connect, and Global Accelerator.
- **The Future**: eBPF and Cilium for kernel-bypass networking.

### ⚙️ [02-Automation](./02-automation/)
**From "Scripts" to "Platforms"**
- **Advanced Terraform**: State manipulation, module composition, and provider development.
- **Ansible at Scale**: Writing custom modules and optimizing for thousands of hosts.
- **GitOps**: The shift from "Push" to "Pull" deployments.

### 🐧 [03-Linux-Internals](./03-linux/)
**From "User" to "Kernel Hacker"**
- **The Kernel**: Understanding the scheduler, memory management, and namespaces.
- **Performance Tuning**: Using `sysctl` to optimize TCP buffers and file descriptors.
- **eBPF Tracing**: Debugging systems without recompiling them.

### 🐳 [04-Container-Orchestration](./04-container-orchestration/)
**From "Docker Run" to "Kubernetes Internals"**
- **The Control Plane**: Etcd consensus, API Server logic, and Scheduler predicates.
- **CSI & CNI**: How storage and networking actually plug into the cluster.
- **Operator Pattern**: Extending Kubernetes with custom logic.

### 🛡️ [05-Security](./05-security/)
**From "Firewalls" to "Zero Trust"**
- **Identity**: OIDC, SAML, and SPIFFE/SPIRE.
- **Encryption**: Mutual TLS (mTLS) everywhere.
- **Supply Chain**: Signing artifacts and verifying provenance.

---

## 🎯 The "Senior Engineer" Standard

At this level, "It works" is not enough. You must be able to answer:
1.  **Why** did it work?
2.  **How** will it break at 10x scale?
3.  **What** is the cost of this abstraction?

---
**Status**: 🏗️ Foundations Established
**Next Step**: [Deep Dive into Networking](./01-networking/)
