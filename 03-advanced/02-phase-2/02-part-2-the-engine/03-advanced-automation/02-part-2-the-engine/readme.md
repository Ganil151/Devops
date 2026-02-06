# ⚙️ Infra Automation Engine

> **"From the Metal to the Manager. We automate the physical servers in the rack, and we automate all the teams using the cloud."**

This module covers the "Extremes" of automation: Physical Hardware and Enterprise Governance.

## 🛣️ The Curriculum

### [01-Terraform-Enterprise](./01-terraform-enterprise/)
**Focus**: Managing Terraform at Scale.
*   **Concepts**:
    *   **Private Module Registry**: Sharing blessed modules across the org.
    *   **Sentinel Policy Sets**: "Hard" vs "Soft" mandatory policies.
    *   **Workspaces & State**: Managing 5,000 state files without losing your mind.

### [02-Bare-Metal-Infrastructure](./02-bare-metal-infrastructure/)
**Focus**: Automating the Data Center.
*   **Concepts**:
    *   **PXE Boot**: Booting over the network.
    *   **MaaS (Metal as a Service)**: Treating physical Dell servers like EC2 instances.
    *   **Cloud-Init**: Configuring OS on first boot without SSH.

---

## 🚀 The Difference

*   **TFE** solves: "How do I stop 500 developers from deleting production?"
*   **Bare Metal** solves: "How do I install the OS on 500 servers without a USB drive?"

---
**Status**: ✅ Organized (2026-02-02)
