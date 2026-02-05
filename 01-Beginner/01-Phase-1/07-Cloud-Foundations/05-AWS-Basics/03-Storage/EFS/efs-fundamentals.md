# EFS Fundamentals & Concepts

Amazon Elastic File System (EFS) provides a simple, serverless, set-and-forget, elastic file system for use with AWS Cloud services and on-premises resources.

## 1. What is AWS EFS?

AWS EFS is a fully managed NFS (Network File System) that automatically scales from gigabytes to petabytes without needing to provision storage. It allows thousands of EC2 instances, Lambda functions, and containers to connect concurrently to a single shared file system.

### Core Benefits
- **Serverless & Elastic**: No need to manage infrastructure or provision capacity.
- **Shared Storage**: Highly concurrent access for distributed workloads.
- **Durable & Available**: Data is stored across multiple Availability Zones (AZs) by default.
- **Support for POSIX**: Works like a standard Linux file system.

## 2. AWS EFS vs. Windows EFS (The Key Difference)

> [!CAUTION]
> Do not confuse **AWS EFS** with **Windows EFS (Encrypting File System)**. They are entirely different technologies.

| Feature | AWS Elastic File System (EFS) | Windows Encrypting File System (EFS) |
| :--- | :--- | :--- |
| **Primary Goal** | Shared Cloud Network Storage | Local File-level Encryption |
| **Platform** | Linux-based (via NFSv4) | Windows (via NTFS) |
| **Scale** | Multi-server (Thousands of nodes) | Single Machine |
| **Storage Type** | Network File System | Local Disk / Storage |

## 3. EFS vs. EBS vs. S3: Which one to use?

| Feature | Elastic Block Store (EBS) | Elastic File System (EFS) | Amazon S3 |
| :--- | :--- | :--- | :--- |
| **Access Pattern** | Single Instance (mostly) | Multi-Instance (Shared) | Web/API (Object storage) |
| **Performance** | Lowest latency (ms) | Moderate latency (ms) | Highest latency |
| **Scalability** | Manual resize required | Automatic scaling | Infinite / Automatic |
| **Protocol** | Block (NVMe/SSD) | File (NFSv4.1) | Object (REST/HTTP) |
| **Use Case** | Boot volumes, Databases | CMS, Big Data, Home dirs | Media storage, Data lakes |

## 4. Performance & Throughput Modes

### Performance Modes
- **General Purpose**: Best for latency-sensitive use cases (Web servers, dev environments).
- **Max I/O**: Scales to higher levels of aggregate throughput and operations per second (Big Data, Large-scale analytics).

### Throughput Modes
- **Bursting Throughput**: Scales with the size of the file system.
- **Provisioned Throughput**: Set a specific throughput regardless of file system size.
- **Elastic Throughput**: (Recommended) Pay for only what you use; automatically scales to meet demand.

## 5. Storage Classes
- **Standard**: For frequently accessed data.
- **One Zone**: Lower cost for non-critical data (stored in a single AZ).
- **Infrequent Access (IA)**: Significantly cheaper for data not accessed daily, managed by Lifecycle Policies.

---
**Next Step**: Learn how to create and mount your first file system in the [Hands-on EFS Guide](../../../../../../02-Intermediate/02-Phase-2/01-Infrastructure-Automation/03-Cloud-Platforms/03-Networking-and-Security/03-Identity-and-Access-Control/AWS-IAM-Cognito/cognito-hands-on.md)
