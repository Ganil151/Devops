# AWS Containers (ECS & EKS)

Running Docker containers on AWS.

## Architecture: ECS vs EKS
```mermaid
graph TD
    Docker[Docker Image]
    ECR[ECR Registry]
    Docker --> ECR

ECR --> ECS[ECS - Simplified]
    ECR --> EKS[EKS - Kubernetes]

ECS --> Fargate[Fargate Serverless]
    EKS --> EC2[EC2 Nodes]

classDef con fill:#e3f2fd,stroke:#0d47a1
    class ECS,EKS con
```

## Real World Scenarios
### Scenario: Microservices Migration
**Context:** Monolithic app is being broken into 20 services. Team knows Docker but not Kubernetes.
**Solution:**
- **ECS (Elastic Container Service):** Use ECS with Fargate.
**Benefit:** Lower learning curve than K8s. No server management (Fargate).

<b>1. ECR stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Elastic Container Registry</b>
</details>


<b>2. ECS vs EKS: Which uses standard Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: A) EKS</b>
</details>


<b>3. Fargate is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Serverless compute engine for containers</b>
</details>


<b>4. To run a container, you need a Task Definition in ECS. This is similar to a:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Docker Compose file</b>
</details>


<b>5. Can EKS run on Fargate?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>6. Which costs more to manage (Control Plane fees)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) EKS (Cost per hour for cluster)</b>
</details>


<b>7. "Pod" is a concept in:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Kubernetes (EKS)</b>
</details>


<b>8. "Task" is a concept in:</b>
<details>
<summary>Show Answer</summary>
Answer: A) ECS</b>
</details>


<b>9. App Mesh is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Service Mesh (networking between microservices)</b>
</details>


<b>10. To authenticate Docker CLI to ECR, you run:</b>
<details>
<summary>Show Answer</summary>
Answer: A) aws ecr get-login-password | docker login...</b>
</details>


<b>11. Can ECS run Windows Containers?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>12. What is the "Sidecar" pattern?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Running a helper container alongside the main application container in the same task/pod</b>
</details>


<b>13. EKS Nodes are managed via:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Managed Node Groups or Self-Managed EC2</b>
</details>


<b>14. Copilot CLI is a tool for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Simplifying ECS deployment</b>
</details>


<b>15. Why use a Private Registry (ECR) instead of Docker Hub?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Security, speed (in VPC), and unlimited pulls</b>
</details>


<b>16. IAM Roles for Tasks (ECS) allows:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Granular permissions per container</b>
</details>


<b>17. In EKS, "kubectl" is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) The command line tool for Kubernetes</b>
</details>


<b>18. Can you run stateful workloads (with EBS) on EKS?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using CSI drivers</b>
</details>


<b>19. Which load balancer is best for containerized HTTP apps?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Application Load Balancer (ALB)</b>
</details>


<b>20. ECS "Service" ensures:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A specified number of tasks are always running (auto-restart)</b>
</details>


<b>21. Does EKS support Helm charts?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


---
## 🧭 Additional Modules
- [ECR Registry](ecr-registry/readme.md)
