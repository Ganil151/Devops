# ☁️ Azure Automation: Azure SDK for Python

> **"In the Azure world, automation is built on the foundation of Azure Resource Manager (ARM). The Azure SDK for Python provides a fluent, object-oriented way to manage everything from Virtual Machines to Azure Kubernetes Service (AKS), ensuring consistency across your hybrid cloud fleet."**

Welcome to the **Azure Python Automation** module. Azure's SDK is highly organized around the concept of **Management Clients** and **Credential Classes**. This module will teach you how to use the `azure-mgmt-*` libraries to orchestrate Azure resources, handle identity via `azure-identity`, and implement enterprise-grade automation patterns.

---

## 📚 Table of Contents

1. [The Junior's Mission](#-the-juniors-mission)
2. [Operational Reality: The ARM Governance](#-operational-reality-the-arm-governance)
3. [Architecture: The Azure Automation Lifecycle](#-architecture-the-azure-automation-lifecycle)
4. [The Development Lifecycle Breakdown](#-the-development-lifecycle-breakdown)
5. [🔐 Identity & Authentication (DefaultAzureCredential)](#-identity--authentication-defaultazurecredential)
6. [🚀 Key Management Libraries (Compute, Resource, Network)](#-key-management-libraries-compute-resource-network)
7. [Staff Patterns: LRO Polling & Subscription Scoping](#-staff-patterns-lro-polling--subscription-scoping)
8. [Senior SRE Pro-Tips](#-senior-sre-pro-tips)
9. [Hands-On Challenge: The "Orphaned Resource Reaper"](#-hands-on-challenge-the-orphaned-resource-reaper)
10. [Interview Preparation](#-interview-preparation)

---

## 🎯 The Junior's Mission
Your mission is to transition from a "Portal User" to an **"ARM Architect."** You will learn to move beyond clicking in the Azure Portal and build automation that manages thousands of resources across **Multiple Subscriptions** and **Resource Groups**, leveraging Managed Identity to eliminate the "Secret Management" burden forever.

---

## 🌩️ Operational Reality: The ARM Governance
Azure is built on a strict hierarchy: Tenant -> Management Group -> Subscription -> Resource Group.
*   **The Win**: Extremely consistent APIs and a universal "Zero-Trust" identity model across all services.
*   **The Hazard**: **Long-Running Operations (LRO).** Almost every Azure write operation is a "Request" that goes into a queue. If your script doesn't handle **Poller Objects** correctly, you'll end up with "Zombie" resources that were created but never verified.

---

## 🏗️ Architecture: The Azure Automation Lifecycle

Azure's SDK is highly modular, requiring explicit management of "Clients" for each resource type.

```mermaid
graph TD
    A[Trigger: Event / Script] --> B[Identity Phase: DefaultAzureCredential]
    B --> C{Subscription Discovery}
    C --> D[Compute Mgmt: VMs/ScaleSets]
    C --> E[Resource Mgmt: Groups/Deployments]
    C --> F[Network Mgmt: VNets/NSGs]
    D & E & F --> G[Result: LRO Poller]
    G --> H[Poll/Wait: .result()]
    H --> I[Action: Verify/Tag/Notify]
    
    style B fill:#e0f2fe,stroke:#0369a1
    style C fill:#fef3c7,stroke:#d97706
    style G fill:#f0fdf4,stroke:#15803d
```

---

## 🔄 The Development Lifecycle Breakdown

Enterprise Azure automation requires strict environmental discipline to handle multi-subscription scaling.

**Stage 1: Environment Isolation**
- **What**: Creating a dedicated `venv` for each management script.
- **Why**: Prevents "SDK Conflict." Azure releases new `mgmt` packages frequently. A script using an old version of `azure-mgmt-network` might be incompatible with a newer version of `azure-identity`.
- **How**: Standardizing on `pip-compile` or `poetry` to lock your entire dependency tree.

**Stage 2: Dependency Management**
- **What**: Pinning specific management libraries (e.g., `azure-mgmt-compute==30.0.0`).
- **Why**: Ensures **Consistency**. Azure SDKs follow Semantic Versioning; a major version jump can rename methods or change the shape of returned objects.
- **How**: Using a `requirements.txt` with strict pins for all `azure-mgmt-*` packages.

**Stage 3: Structured Code**
- **What**: Separating **Identity Plumbing** from **Resource Business Logic**.
- **Why**: Improves **Portability**. Your script should rely on the `DefaultAzureCredential` so it can run securely on a developer's laptop, an Azure DevOps agent, or an AKS Pod without code changes.
- **How**: Wrapping client creation in a factory function that takes a `subscription_id` as input.

**Stage 4: Verification**
- **What**: Implementing **Subscription Existence Checks** and **Quota Audits**.
- **Why**: Prevents "Out-of-Capacity" failures. Azure regions have strict vCPU quotas; your script should check if enough quota remains *before* attempting a create operation.
- **How**: Using the `azure-mgmt-compute` Quota API to verify limits at startup.

**Stage 5: Fail-Fast Pattern**
- **What**: Validating Managed Identity and Resource Group existence immediately.
- **Why**: Protects against **Permission Ghosting**. If the identity doesn't have "Contributor" access to the Resource Group, the script should exit in under 500ms.
- **How**: Attempting a simple "Get Resource Group" metadata call before starting any write-heavy LRO.

---

## 🔐 Identity & Authentication: DefaultAzureCredential

The staff-standard for Azure identity: **Zero hardcoded secrets.**

### The Staff Standard: DefaultAzureCredential
1. **Local**: `az login` (SDK uses your CLI session).
2. **Production**: Use **Managed Identity** (System or User assigned).
3. **Internal Code**: `credential = DefaultAzureCredential()`.

---

## 💡 Senior SRE Pro-Tips

*   **Long-Running Operations (LROs)**: Never use `time.sleep()` to wait for a resource. Use the poller object: `poller = client.virtual_machines.begin_create_or_update(...); result = poller.result()`.
*   **Resource Tagging**: Every resource your script creates MUST have an `Owner`, `Environment`, and `CreatedBy: Automation` tag. This is the only way FinOps can track your automation's spend.
*   **Asynchronous Processing**: For high-scale automation (e.g., starting 500 VMs), use the `azure-mgmt-*` **async** versions of the libraries to handle concurrent pollers efficiently.

---

## 🏗️ Hands-On Challenge: The "Orphaned Resource Reaper"

**Goal**: Build a Python script that audits all **Manage Disks** across a subscription. If a disk's `managed_by` property is `None`, it means it is "Orphaned" (not attached to a VM). The script must log these disks and tag them for deletion.

### 🛠️ The Challenge Requirements:
1.  **Identity**: Use `DefaultAzureCredential`.
2.  **Logic**: Iterate through all `disks` in the `ComputeManagementClient`.
3.  **Action**: Do NOT delete immediately. Update the disk's tags to include `Status: Orphaned` and `DeleteAfter: [Date]`.
4.  **Reporting**: Generate a JSON summary of the total "Wasted Storage" in GB across the subscription.

---

## 🎙️ Interview Preparation

1.  **"How does `DefaultAzureCredential` decide which method to use for authentication?"**
    *   *A*: It follows a specific chain: Environment Variables -> Managed Identity -> Shared Token Cache (Visual Studio/Azure CLI). It stops at the first successful match.
2.  **"What is the difference between a synchronous and asynchronous management client in Azure?"**
    *   *A*: Synchronous clients block the execution thread while waiting for the LRO poller (unless you handle the poller separately). Asynchronous clients (using `asyncio`) allow you to manage thousands of concurrent cloud operations without increasing thread count.

---

**Status**: ☁️ Staff-Enhanced (2026-02-04)
