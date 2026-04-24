# ⚖️ Elasticity and Scaling: The High-Availability Standard

Elasticity is the ability of a system to grow or shrink its infrastructure resources dynamically to match the current demand. Scaling is the mechanism used to achieve this elasticity.

## 🏗️ Load Balancing Architecture
Load Balancers (LBs) are the entry point of your scalable infrastructure. They distribute incoming traffic across multiple targets to ensure no single resource is overwhelmed.

![Load Balancing Architecture](/home/gsmash/.gemini/antigravity/brain/7def5311-fe37-4d3f-9c26-76fa450f1d0a/load-balancing-architecture-1769828105050.png)

### Deep-Dive: L4 vs L7 Balancing

| Feature | Layer 4 (Network) | Layer 7 (Application) |
| :--- | :--- | :--- |
| **Protocol** | TCP / UDP | HTTP / HTTPS / gRPC |
| **Logic** | Based on IP and Port | Based on Headers, Path, Cookies |
| **Speed** | Extremely High (Lower latency) | High (Slightly slower due to inspection) |
| **Use Case** | DB clusters, VoIP, Low-level TCP | Web Applications, Microservices routing |
| **AWS Service** | Network Load Balancer (NLB) | Application Load Balancer (ALB) |

### Health Check Propagation
A Load Balancer is only as good as its health checks.
1. **Passive Checks**: Monitoring actual traffic for failures.
2. **Active Checks**: Sending periodic requests (heartbeats) to a specific endpoint (e.g., `/health`).
3. **Graceful Termination**: When an instance is marked unhealthy, the LB stops sending *new* requests but allows existing ones to finish (Draining).

---

## 📈 Scaling Mechanics
Scaling ensures your application can handle load while maintaining performance and cost-efficiency.

![Auto Scaling Mechanics](/home/gsmash/.gemini/antigravity/brain/7def5311-fe37-4d3f-9c26-76fa450f1d0a/auto-scaling-mechanics-1769828067760.png)

### Vertical vs Horizontal Scaling
- **Vertical Scaling (Scaling Up/Down)**: Increasing the "size" of a single resource (e.g., upgrading from a 2vCPU to a 16vCPU instance). 
    - *Limitation*: Finite ceiling and usually requires downtime.
- **Horizontal Scaling (Scaling Out/In)**: Adding more "instances" of a resource (e.g., adding 5 more web servers).
    - *Advantage*: Virtually infinite scale and zero downtime.

### Scaling Strategies
1. **Reactive Auto-scaling**: Responds to current metrics.
    - *Example*: "Add 1 instance if average CPU usage > 70% for 3 minutes."
2. **Predictive Auto-scaling**: Uses machine learning to anticipate traffic spikes based on historical patterns.
    - *Example*: Pre-scaling on Friday nights before a weekend rush.
3. **Scheduled Scaling**: Scaling based on known time intervals.
    - *Example*: Scaling down to 1 instance at 6:00 PM and up to 10 at 8:00 AM.

---

## 🛠️ Infrastructure as Code (IaC)
In professional DevOps, scaling and balancing are **never** configured manually.

```hcl
# Example Terraform: AWS Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity   = 2
  max_size           = 5
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.web_tg.arn]
  
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}
```

## 📂 Section Navigation
- [Auto-Scaling-Groups](./auto-scaling-groups): Implementation guides for ASG/VMSS.
- [Load-Balancers](./load-balancers): L4/L7 configuration and algorithms.
- [Scaling-Policies](./scaling-policies): Designing effective triggers.
