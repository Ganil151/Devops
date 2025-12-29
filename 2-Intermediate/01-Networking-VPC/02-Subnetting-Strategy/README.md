# Subnetting Strategy: Public vs. Private

Architecture is about isolation. A well-designed VPC separates "front-facing" resources from "internal" ones.

---

## 🛡️ The Public / Private Split

### 1. Public Subnets
- **Definition**: A subnet whose route table has a direct route to an Internet Gateway (`0.0.0.0/0 -> igw`).
- **Use Case**: Load Balancers, Bastion Hosts, Public-facing Web Servers.

### 2. Private Subnets
- **Definition**: A subnet whose route table DOES NOT have a route to an IGW.
- **Use Case**: Databases, Application Servers, Backend Logic.

---

## 🌩️ Accessing the Internet from Private Subnets

Resources in private subnets often need to download updates or talk to external APIs, but you don't want the internet talking back to them.

### The NAT Gateway (Network Address Translation)
- **Role**: Allows instances in a private subnet to connect to the internet while preventing the internet from initiating a connection with those instances.
- **Placement**: A NAT Gateway **MUST** be placed in a **Public Subnet**.
- **Routing**: `Private Subnet RT -> 0.0.0.0/0 -> nat-gateway-id`.

---

## 💡 Best Practices
- **Multi-AZ**: Always deploy subnets in at least two Availability Zones for high availability.
- **Size matters**: Don't make your subnets too small. A `/24` (256 IPs) is a safe standard for most workloads.
- **Reserve IPs**: Remember that cloud providers (like AWS) reserve the first 4 and the last 1 IP address in every subnet.
