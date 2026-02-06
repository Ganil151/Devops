# 🧠 Knowledge Check: Cloud Performance & Elasticity

Take this 10-question quiz to test your understanding of multi-cloud compute and scaling architectures.

---

### 1. Which load balancer type is most suitable for handling millions of requests per second with ultra-low latency specifically for TCP/UDP traffic?
- A) Application Load Balancer (ALB)
- B) Network Load Balancer (NLB)
- C) Classic Load Balancer (CLB)
- D) Gateway Load Balancer

### 2. In an Auto Scaling Group, what does a "Cool-down Period" prevent?
- A) The instances from overheating physically.
- B) The ASG from launching or terminating additional instances before the previous scaling activity takes effect.
- C) The Load Balancer from sending traffic to new instances.
- D) The instances from being terminated during off-peak hours.

### 3. Which scaling strategy uses Machine Learning to predict future traffic based on historical patterns?
- A) Target Tracking Scaling
- B) Simple Scaling
- C) Predictive Scaling
- D) Step Scaling

### 4. What is the primary difference between horizontal and vertical scaling?
- A) Horizontal adds more instances; Vertical increases the size of an existing instance.
- B) Horizontal is for RAM; Vertical is for CPU.
- C) Horizontal requires a reboot; Vertical does not.
- D) Horizontal is only for databases; Vertical is for web servers.

### 5. In a "Blue/Green" deployment, what does "Green" represent?
- A) The old, stable version of the application.
- B) The new version of the application currently being deployed/tested.
- C) An environment that has been deleted.
- D) An environment restricted to internal developers only.

### 6. Which service would you use to decouple a producer and consumer to handle traffic spikes in AWS?
- A) Lambda
- B) SQS (Simple Queue Service)
- C) EC2
- D) Route 53

### 7. What is "Sticky Sessions" (Session Affinity) used for?
- A) To encrypt session data between the user and the server.
- B) To ensure a user is always routed to the same backend instance for the duration of their session.
- C) To prevent users from staying on the site for too long.
- D) To share session data between different cloud providers.

### 8. Which "DevOps Why" best justifies using ECS Fargate over EC2 for a microservice?
- A) To have full control over the underlying Linux kernel.
- B) To minimize operational overhead by not managing the host cluster or patching the OS.
- C) Fargate is always cheaper than EC2.
- D) Fargate supports more programming languages than EC2.

### 9. What happens during "Draining" (or Deregistration Delay) on a Load Balancer?
- A) All traffic is instantly cut off to the instance.
- B) The instance is deleted immediatey.
- C) The LB stops sending new requests but allows existing "in-flight" requests to complete.
- D) The instance's memory is cleared for security.

### 10. When would you use a Layer 7 (L7) Load Balancer instead of Layer 4 (L4)?
- A) When you only care about IP addresses and ports.
- B) When you need to route traffic based on URL paths (e.g., /api vs /static).
- C) When you need the absolute maximum throughput possible.
- D) When you are load balancing a simple database cluster.

---

## 🔑 Answer Key
1. **B** (NLB works at Layer 4 and is optimized for speed/scale).
2. **B** (Prevents "flapping" or over-scaling before metrics stabilize).
3. **C** (Predicting spikes before they happen).
4. **A** (Scale-out vs Scale-up).
5. **B** (Green is the new version).
6. **B** (SQS acts as a buffer).
7. **B** (Useful for stateful apps that haven't moved to external session stores).
8. **B** (Reduced management overhead).
9. **C** (Ensures zero-downtime during scaling or deployments).
10. **B** (L7 understands application-level protocols like HTTP path/headers).
