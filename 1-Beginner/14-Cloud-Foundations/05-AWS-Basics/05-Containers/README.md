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

## Quiz
<details>
<summary><b>1. ECR stands for:</b></summary>
A) Elastic Container Registry<br>
B) Electronic Card Reader<br>
C) Easy Code Run<br>
D) Elastic Cloud Runner<br>
<br>
<b>Answer: A) Elastic Container Registry</b>
</details>

<details>
<summary><b>2. ECS vs EKS: Which uses standard Kubernetes?</b></summary>
A) EKS<br>
B) ECS<br>
<br>
<b>Answer: A) EKS</b>
</details>

<details>
<summary><b>3. Fargate is:</b></summary>
A) Serverless compute engine for containers<br>
B) A firewall<br>
C) A database<br>
D) A gate<br>
<br>
<b>Answer: A) Serverless compute engine for containers</b>
</details>

<details>
<summary><b>4. To run a container, you need a Task Definition in ECS. This is similar to a:</b></summary>
A) Docker Compose file<br>
B) Python script<br>
C) Variable<br>
D) User<br>
<br>
<b>Answer: A) Docker Compose file</b>
</details>

<details>
<summary><b>5. Can EKS run on Fargate?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>6. Which costs more to manage (Control Plane fees)?</b></summary>
A) EKS (Cost per hour for cluster)<br>
B) ECS (Free control plane)<br>
<br>
<b>Answer: A) EKS (Cost per hour for cluster)</b>
</details>

<details>
<summary><b>7. "Pod" is a concept in:</b></summary>
A) Kubernetes (EKS)<br>
B) ECS<br>
C) Docker<br>
D) S3<br>
<br>
<b>Answer: A) Kubernetes (EKS)</b>
</details>

<details>
<summary><b>8. "Task" is a concept in:</b></summary>
A) ECS<br>
B) EKS<br>
C) Lambda<br>
D) RDS<br>
<br>
<b>Answer: A) ECS</b>
</details>

<details>
<summary><b>9. App Mesh is used for:</b></summary>
A) Service Mesh (networking between microservices)<br>
B) Drawing shapes<br>
C) Login<br>
D) Storage<br>
<br>
<b>Answer: A) Service Mesh (networking between microservices)</b>
</details>

<details>
<summary><b>10. To authenticate Docker CLI to ECR, you run:</b></summary>
A) aws ecr get-login-password | docker login...<br>
B) docker login aws<br>
C) login<br>
D) sudo login<br>
<br>
<b>Answer: A) aws ecr get-login-password | docker login...</b>
</details>

<details>
<summary><b>11. Can ECS run Windows Containers?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>12. What is the "Sidecar" pattern?</b></summary>
A) Running a helper container alongside the main application container in the same task/pod<br>
B) Driving a motorcycle<br>
C) A backup server<br>
D) A database<br>
<br>
<b>Answer: A) Running a helper container alongside the main application container in the same task/pod</b>
</details>

<details>
<summary><b>13. EKS Nodes are managed via:</b></summary>
A) Managed Node Groups or Self-Managed EC2<br>
B) Magic<br>
C) Not managed<br>
D) Console only<br>
<br>
<b>Answer: A) Managed Node Groups or Self-Managed EC2</b>
</details>

<details>
<summary><b>14. Copilot CLI is a tool for:</b></summary>
A) Simplifying ECS deployment<br>
B) Flying planes<br>
C) EKS management<br>
D) S3 uploads<br>
<br>
<b>Answer: A) Simplifying ECS deployment</b>
</details>

<details>
<summary><b>15. Why use a Private Registry (ECR) instead of Docker Hub?</b></summary>
A) Security, speed (in VPC), and unlimited pulls<br>
B) It's cheaper<br>
C) It has more images<br>
D) Docker Hub is closed<br>
<br>
<b>Answer: A) Security, speed (in VPC), and unlimited pulls</b>
</details>

<details>
<summary><b>16. IAM Roles for Tasks (ECS) allows:</b></summary>
A) Granular permissions per container<br>
B) Granular permissions per node<br>
C) All containers share same permission<br>
D) Nothing<br>
<br>
<b>Answer: A) Granular permissions per container</b>
</details>

<details>
<summary><b>17. In EKS, "kubectl" is:</b></summary>
A) The command line tool for Kubernetes<br>
B) An AWS service<br>
C) A container<br>
D) A database<br>
<br>
<b>Answer: A) The command line tool for Kubernetes</b>
</details>

<details>
<summary><b>18. Can you run stateful workloads (with EBS) on EKS?</b></summary>
A) Yes, using CSI drivers<br>
B) No<br>
<br>
<b>Answer: A) Yes, using CSI drivers</b>
</details>

<details>
<summary><b>19. Which load balancer is best for containerized HTTP apps?</b></summary>
A) Application Load Balancer (ALB)<br>
B) Classic Load Balancer<br>
C) Network Load Balancer<br>
D) Gateway Load Balancer<br>
<br>
<b>Answer: A) Application Load Balancer (ALB)</b>
</details>

<details>
<summary><b>20. ECS "Service" ensures:</b></summary>
A) A specified number of tasks are always running (auto-restart)<br>
B) One task runs once<br>
C) Nothing<br>
D) Logging<br>
<br>
<b>Answer: A) A specified number of tasks are always running (auto-restart)</b>
</details>

<details>
<summary><b>21. Does EKS support Helm charts?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>
