# Load Balancing (ELB)

Elastic Load Balancing (ELB) automatically distributes incoming application traffic across multiple targets, such as EC2 instances, containers, and IP addresses.

## ⚖️ Types of Load Balancers

### 1. Application Load Balancer (ALB)
-   **Layer**: Layer 7 (Application).
-   **Protocols**: HTTP, HTTPS, gRPC.
-   **Routing**: Content-based (Path: `/images`, Host: `api.example.com`).
-   **Use Case**: Microservices, Containerized apps, Web applications.

### 2. Network Load Balancer (NLB)
-   **Layer**: Layer 4 (Transport).
-   **Protocols**: TCP, UDP, TLS.
-   **Performance**: Ultra-high performance (millions of requests/sec). Low latency.
-   **Use Case**: Gaming, Real-time streaming, Static IP requirement.

### 3. Gateway Load Balancer (GWLB)
-   **Layer**: Layer 3 (Network).
-   **Use Case**: Deploying and scaling third-party virtual appliances (Firewalls, IDS/IPS).

---

## 🎯 Important Concepts

### Listeners
A process that checks for connection requests using the protocol and port that you configure.
-   *Example*: Listen on HTTPS:443 -> Forward to Target Group A.

### Target Groups
A logical group of targets (Instances, IPs, or Lambda functions) that route requests to one or more registered targets.
-   **Health Checks**: The ELB pings targets in the group. If a target fails, it stops sending traffic to it.

### Cross-Zone Load Balancing
-   **Enabled**: The LB distributes traffic evenly across all registered targets in all enabled Availability Zones.
-   **Disabled**: The LB distributes traffic evenly across the AZs, then to the targets within that AZ (can lead to imbalance if AZs have different target counts).

---

## 🏗️ Setup Workflow

1.  **Select Load Balancer Type** (ALB vs NLB).
2.  **Configure Listeners** (e.g., HTTP Port 80).
3.  **Availability Zones**: Select at least two public subnets for HA.
4.  **Security Group** (ALB only): Allow Inbound HTTP/HTTPS from `0.0.0.0/0`.
5.  **Target Group**: Define where to send traffic (Instances, Port 80).
6.  **Health Checks**: Define how to check if targets are healthy (e.g., `/health` path).

---

## ❓ Interview Questions

1.  **What is the difference between ALB and NLB?**
    *   *Answer*: ALB operates at Layer 7 (HTTP/HTTPS) and supports path/host-based routing. NLB operates at Layer 4 (TCP/UDP), is faster, handles volatile traffic spikes, and provides static IPs.
2.  **What is a "Sticky Session"?**
    *   *Answer*: A feature that binds a user's session to a specific instance via a cookie. Useful for stateful applications.
3.  **How do I direct traffic to different microservices based on URL?**
    *   *Answer*: Use an ALB with **Path-Based Routing** rules (e.g., `/api/*` -> API Target Group).

---

## 🧠 Quiz Snippet

1.  **Which Load Balancer allows for a static IP address?** `(Network Load Balancer)`
2.  **What layer does ALB operate at?** `(Layer 7)`
3.  **If an instance fails a health check, what does the ELB do?** `(Stops sending traffic to it)`
4.  **Can an ALB route to a Lambda function?** `(Yes)`
5.  **Which header does ALB add to preserve the client ID?** `(X-Forwarded-For)`
