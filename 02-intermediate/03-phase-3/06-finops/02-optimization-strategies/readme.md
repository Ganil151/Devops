# 🔄 02: Optimization Strategies

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Reserved Capacity ➡️](../03-reserved-instances/readme.md)**

---

# ✂️ Cutting the Cloud Fat

Optimization is not just about "Spending Less." It's about **Efficiency**. A high-performance architecture that wastes 40% of its resources is a failure of engineering. This module covers the framework for eliminating waste and right-sizing your fleet.

## 🏗️ The Cloud Optimization Pyramid

1.  **Waste Elimination (Immediate)**: Delete what isn't being used.
2.  **Right-Sizing (Strategic)**: Match instance sizes to actual CPU/RAM usage.
3.  **Spot Integration (Advanced)**: Use surplus capacity for stateless workloads.
4.  **Architectural Shift (Expert)**: Move from VMs to Serverless or Containers.

---

## 🦠 The 3 Main Pests: "Zombie" Resources

These are resources that are running, costing money, but providing **Zero Value**.

| Pest | Description | Cost |
| :--- | :--- | :--- |
| **Orphaned EBS** | Disks left behind after an EC2 is deleted. | $0.10 per GB/month |
| **Idle EIPs** | Public IPs not attached to anything. | ~$3.60 / month each |
| **Zombie Snapshots** | Backups of disks that no longer exist. | Variable |

> **Pro Tip**: See the `src/find_waste.py` script to automate the hunt for these resources.

---

## 📏 Right-Sizing: The Goldilocks Rule

Most developers pick a `t3.large` just to "be safe." 
*   **The Problem**: If your CPU usage never peaks above 5%, you are paying 4x more than you should.
*   **The Target**: Aim for **40-70% average CPU utilization**.

### Right-Sizing Metric Check
Check your CloudWatch metrics over 14 days. If `CPUUtilization` (Max) is < 10%, you are a candidate for a **Downsize**.

---

## ⚡ Spot Instances: The 90% Discount

Spot instances are AWS's way of selling spare capacity.
*   **Caveat**: AWS can take them back with a **2-minute notice**.
*   **Use Cases**:
    *   ✅ Kubernetes worker nodes (Stateless).
    *   ✅ CI/CD Build Runners.
    *   ✅ Batch processing / Image rendering.
    *   ❌ Primary Databases.

---

## 📂 Project Structure

Check out the `src/` directory for optimization tools:
- `find_waste.py`: A Python script that uses Boto3 to identify unattached EBS volumes and idle Elastic IPs.
- `lifecycle_policy.json`: Example S3 policy to move data to Glacier after 90 days.

---

## 🧪 Experience the Challenges
Ready to hunt for waste? Try out the **[Optimization Challenges](./challenges.md)**.
