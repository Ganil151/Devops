# Routing and Route Tables

Route tables are the GPS of your VPC. They determine where network traffic from your subnet or gateway is directed.

## 🗺️ Route Table Basics

A route table contains a set of rules, called **routes**, that determine where network traffic uses to get to its destination.

-   **Main Route Table**: Automatically created with your VPC. Implicitly associated with all subnets unless a custom one is created.
-   **Custom Route Table**: Explicitly created by the user and associated with specific subnets. **Best Practice** is to use custom route tables for granular control.

### Anatomy of a Route

Each route consists of:
1.  **Destination**: The range of IP addresses where you want traffic to go (e.g., `0.0.0.0/0`, `10.0.0.0/16`).
2.  **Target**: The gateway, network interface, or connection to send traffic to (e.g., `igw-xxxx`, `nat-xxxx`, `pcx-xxxx`).

### The "Local" Route
Every route table contains a default `local` route for the VPC CIDR.
-   **Destination**: `10.0.0.0/16` (VPC CIDR)
-   **Target**: `local`
-   **Note**: This route cannot be deleted. It ensures all instances in the VPC can communicate with each other.

---

## 🚦 Route Priority

When multiple routes match a packet's destination, AWS uses the **most specific route** (longest prefix match) to determine priority.

**Example**:
-   Route A: `10.0.0.0/16` -> Local
-   Route B: `10.0.1.0/24` -> Peering-Connection
-   Packet Destination: `10.0.1.50`

**Winner**: Route B (more specific/longer prefix).

---

## 🏗️ Common Route Table Configurations

### 1. Public Route Table
Associated with Public Subnets.
-   `10.0.0.0/16` -> `local`
-   `0.0.0.0/0` -> `igw-xxxx` (Internet Gateway)

### 2. Private Route Table
Associated with Private Subnets.
-   `10.0.0.0/16` -> `local`
-   `0.0.0.0/0` -> `nat-xxxx` (NAT Gateway)

### 3. Gateway Route Table
Associated with an Internet Gateway or VGW (rare usage). Used for fine-grained control of ingress traffic, typically with middlebox appliances (firewalls).

---

## ⚠️ Blackhole Routes

A "Blackhole" status in a route table means the target resource (e.g., NAT Gateway, Peering Connection) no longer exists.
-   **Symptom**: Traffic is dropped silently.
-   **Fix**: Update the route to a valid target or delete the route.

---

## ❓ Interview Questions

1.  **Can a subnet be associated with multiple route tables?**
    *   *Answer*: No. A subnet can be associated with only one route table at a time. However, a single route table can be associated with multiple subnets.
2.  **What is the priority order for routes?**
    *   *Answer*: Longest Prefix Match (Most specific route wins). If there is a tie, static routes take precedence over propagated routes.
3.  **What happens if I don't associate a subnet with a route table?**
    *   *Answer*: It is implicitly associated with the VPC's Main Route Table.

---

## 🧠 Quiz Snippet

1.  **Which route is automatically added to every route table?** `(The local route)`
2.  **You want to route traffic to S3 without going over the internet. What target do you use?** `(VPC Endpoint / Gateway Endpoint)`
3.  **Can you delete the 'local' route?** `(No)`
4.  **Target for internet traffic in a public subnet?** `(igw-id)`
5.  **Target for internet traffic in a private subnet?** `(nat-id)`
