
> **Note**: This is an Intermediate-level topic.

## Elastic Load Balancing (ELB)
ELB automatically distributes incoming application traffic across multiple targets, such as EC2 instances, containers, and IP addresses.

## Types of Load Balancers

### 1. Application Load Balancer (ALB)
- **Layer 7**: HTTP/HTTPS traffic.
- **Path-Based Routing**: `/api` -> Target Group A, `/web` -> Target Group B.
- **Host-Based Routing**: `api.example.com` -> Target Group A.
- **Best For**: Web applications, Microservices.

### 2. Network Load Balancer (NLB)
- **Layer 4**: TCP/UDP traffic.
- **High Performance**: Millions of requests per second.
- **Static IP**: Can have a static elastic IP.
- **Best For**: Gaming, Real-time data, High throughput.

## Setup Workflow
1.  **Select Load Balancer Type**.
2.  **Configure Listeners**: (e.g., HTTP Port 80).
3.  **Availability Zones**: Select at least two public subnets.
4.  **Security Group**: Allow Inbound HTTP/HTTPS from `0.0.0.0/0`.
5.  **Target Group**: Define where to send traffic (Instances, Port 80).
6.  **Health Checks**: Define how to check if targets are healthy (e.g., `/health` path).
