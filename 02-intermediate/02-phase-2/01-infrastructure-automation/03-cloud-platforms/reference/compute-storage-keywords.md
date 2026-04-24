# 🛠️ Reference: Compute & Storage Keywords

Compute and Storage are the "Muscle" and "Memory" of the cloud. Understanding these keywords is essential for building performance-optimized and cost-effective platforms.

---

## 🏗️ Compute & Elasticity

### `Instance Types`
*   **Definition**: The specific hardware configuration (CPU, RAM, GPU) of a virtual machine.
*   **DevOps Why**: Choosing the right family (`t3` for bursty, `c6g` for compute, `r6i` for memory) determines both performance and cost.

### `Auto-Scaling Group (ASG)`
*   **Definition**: A collection of EC2 instances that expands or shrinks based on demand (CPU, Traffic, or Schedule).
*   **Goal**: To match capacity to demand, ensuring availability while minimizing cost.

### `Elastic Load Balancer (ELB)`
*   **Definition**: A service that automatically distributes incoming application traffic across multiple targets (instances, containers, IP addresses).
*   **Standard**: Use **Application Load Balancers (ALB)** for HTTP/HTTPS (Layer 7) and **Network Load Balancers (NLB)** for low-latency TCP/UDP traffic (Layer 4).

---

## 🗄️ Storage Paradigms

### `EBS (Elastic Block Store)`
*   **Definition**: Network-attached block storage for use with individual instances. Think of it as a virtual hard drive.
*   **Standard**: Use `gp3` for a balance of price and performance. Always enable **Encryption by Default**.

### `S3 (Simple Storage Service)`
*   **Definition**: Object storage built to store and retrieve any amount of data from anywhere.
*   **Durability**: Designed for 99.999999999% (11 9s) of durability. Essential for backups, data lakes, and static website hosting.

### `EFS (Elastic File System)`
*   **Definition**: A scalable, fully managed NFS (Network File System) for use with AWS Cloud services and on-premises resources.
*   **DevOps Why**: Allows multiple instances to mount the same storage volume simultaneously (Read-Write-Many).

---

## 🎙️ Staff Interview Context

*   **"What is the difference between 'Vertical' and 'Horizontal' scaling?"**
    *   *Answer*: **Vertical Scaling** (Scaling Up) means increasing the size of a single server (e.g., `t3.micro` to `t3.large`). **Horizontal Scaling** (Scaling Out) means adding more identical servers to the fleet. Staff engineers prefer Horizontal scaling because it provides redundancy (fault tolerance).
*   **"Explain 'Object' vs 'Block' storage."**
    *   *Answer*: **Block Storage** (`EBS`) is used for operating systems and databases where high throughput and low latency are needed for individual drives. **Object Storage** (`S3`) is used for unstructured data (images, logs, backups) where global accessibility and high durability are more important than disk-level latency.
*   **"When should you use 'Reserved Instances' vs 'Spot Instances'?"**
    *   *Answer*: Use **Reserved Instances** for baseline, steady-state workloads (at least 1 year). Use **Spot Instances** for stateless, fault-tolerant workloads (e.g., CI/CD runners, Batch processing) that can handle interruptions, saving up to 90% in cost.
