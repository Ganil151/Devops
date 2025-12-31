# 01. Route Table Fundamentals

A **Route Table** is a set of rules (routes) that controls where network traffic is directed within your VPC. Think of it as the traffic controller for your subnets.

## Core Concepts

Every VPC comes with a **Main Route Table**, but for professional architectures, we almost always use **Custom Route Tables**.

```mermaid
graph TD
    VPC[VPC (10.0.0.0/16)] --> MainRT[Main Route Table]
    VPC --> CustomRT[Custom Route Table]
    
    subgraph "Implicit Association"
    MainRT -.-> S1[Subnet 1]
    MainRT -.-> S3[Subnet 3]
    end
    
    subgraph "Explicit Association"
    CustomRT --> S2[Subnet 2]
    end
    
    style CustomRT fill:#3399ff,color:#fff
```

### 1. The Main Route Table
*   **Automatic**: Created when you create your VPC.
*   **Default**: Any subnet not explicitly associated with another table is automatically (implicitly) linked to this one.
*   **Risk**: If you add an Internet Gateway route to the Main table, every new subnet you create will be public by default, which is a security risk.

### 2. Custom Route Tables
*   **User-Defined**: You create these manually for specific needs (e.g., a "Public RT" or a "Private RT").
*   **Explicit Association**: You manually link a subnet to a custom table. This is the **Best Practice**.

### 3. The "Local" Route
Every route table, regardless of type, contains a default `local` route.
*   **Destination**: The VPC CIDR (e.g., `10.0.0.0/16`).
*   **Target**: `local`.
*   **Status**: Permanent. It cannot be deleted or modified. It allows all resources in the VPC to talk to each other by default.

---

## Real-Life Scenarios

### Scenario 1: "The Accidental Exposure"
**Problem**: A startup was using the Main Route Table for their public web servers. They added a route to an Internet Gateway (`0.0.0.0/0 -> igw-xxx`). Later, they created a new subnet for their database.
**Consequence**: The database subnet was implicitly associated with the Main table, making the database publicly accessible from the internet.
**Solution**: Created a dedicated "Private Route Table" and explicitly associated the database subnet with it.

### Scenario 2: "The Isolation Requirement"
**Problem**: A compliance audit required that the "Compliance Subnet" must never be able to talk to the rest of the VPC, even though they share the same network.
**Discovery**: The `local` route is un-deleteable.
**Solution**: Used **Network ACLs (NACLs)** at the subnet boundary to block all internal VPC traffic, acknowledging that the Route Table will always allow it at the routing layer.

### Scenario 3: "Template for Success"
**Problem**: An infrastructure team found themselves manually associating 50 subnets with the same "Private RT" every time they scaled.
**Solution**: Updated the **Main Route Table** to be the "Private Standard" (no IGW route). 
*   Result: New subnets became private by default. They only created custom tables for the few subnets that actually needed to be public.

---

## ❓ Interview Questions

1. **What is the difference between an implicit and explicit subnet association?**
    - Implicit means the subnet uses the Main Route Table because no other table is specified. Explicit means the user manually linked the subnet to a specific custom route table.
2. **Can you delete the 'local' route in a VPC route table?**
    - No.
3. **How many route tables can a single subnet be associated with?**
    - Exactly one.
4. **What is the Main Route Table?**
    - The default route table that comes with every VPC.
5. **Why is it a bad idea to make the Main Route Table 'Public'?**
    - Because any new subnet created in the future will automatically become public, potentially exposing sensitive resources like databases.
6. **Can a single Route Table be associated with multiple subnets?**
    - Yes.
7. **Does a route table belong to a Subnet or a VPC?**
    - It belongs to the **VPC**, but it is **associated** with Subnets.
8. **What happens to a subnet if its custom route table is deleted?**
    - It reverts to being implicitly associated with the Main Route Table.
9. **Is there a cost for creating multiple route tables?**
    - No, route tables are free.
10. **Do route tables control traffic between instances in the same subnet?**
    - No. Traffic within the same subnet is handled at Layer 2 (switching) and does not consult the route table.

---

## 🧠 Quiz

1. **Which route table is created automatically?**
    - [x] Main Route Table
    - [ ] Custom Route Table
2. **Standard target for VPC-internal traffic:**
    - [x] local
    - [ ] internet
3. **Max route tables per subnet:**
    - [x] 1
    - [ ] Unlimited
4. **Best practice for production subnets:**
    - [x] Use Custom Route Tables
    - [ ] Use the Main Route Table
5. **If no association is made, a subnet uses:**
    - [x] Main Route Table
    - [ ] No routing
6. **Can you modify the local route?**
    - [x] No
    - [ ] Yes
7. **Route tables function at which OSI layer?**
    - [x] Layer 3 (Network)
    - [ ] Layer 7 (Application)
8. **Destination `0.0.0.0/0` represents:**
    - [x] All IPv4 traffic (The Internet)
    - [ ] Only internal traffic
9. **To see all routes in a table, look at the:**
    - [x] Routes tab in AWS Console
    - [ ] NAT Gateway
10. **Does a Main Route Table exist for every VPC?**
    - [x] Yes
    - [ ] No
11. **Can you have multiple main route tables?**
    - [x] No
    - [ ] Yes (one per AZ)
12. **Subnet associations are found in:**
    - [x] VPC Dashboard
    - [ ] EC2 Dashboard
13. **Local route ensures:**
    - [x] Intra-VPC communication
    - [ ] Internet access
14. **Deleting a custom RT used by a subnet causes:**
    - [x] Implicit rollback to Main RT
    - [ ] Complete network failure
15. **Target for Internet Gateway starts with:**
    - [x] igw-
    - [ ] vpc-
16. **Are route tables regional or AZ-specific?**
    - [x] Regional (can span AZs)
    - [ ] AZ-specific
17. **Can a route table have an IPv6 route?**
    - [x] Yes (`::/0`)
    - [ ] No
18. **Implicit associations are:**
    - [x] Automatic
    - [ ] Manual
19. **Explicit associations are:**
    - [x] Manual
    - [ ] Automatic
20. **Is the local route destination always the VPC CIDR?**
    - [x] Yes
    - [ ] No
