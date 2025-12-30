# Implementation Platforms

Choosing the right platform for auto-remediation depends on your infrastructure, team skills, and complexity requirements.

## Platform Categories

### 1. Serverless Functions
**Best For**: Simple, event-driven remediation.
- **AWS Lambda**: Triggered by CloudWatch Alarms or EventBridge.
- **Azure Functions**: Triggered by Azure Monitor.
- **Google Cloud Functions**: Triggered by Pub/Sub or Cloud Monitoring.

**Example**: Disk cleanup script triggered by storage alert.

**Pros**: No infrastructure to manage, pay-per-use, scales automatically.
**Cons**: Cold start latency, execution time limits (15 min for Lambda).

---

### 2. Kubernetes Controllers
**Best For**: Container-native remediation.
- **Custom Controllers**: Watch Kubernetes resources and take action.
- **Operators**: Encapsulate operational knowledge (e.g., Prometheus Operator).
- **KEDA**: Event-driven autoscaling.

**Example**: Auto-restart pods with high memory usage.

**Pros**: Native Kubernetes integration, declarative configuration.
**Cons**: Requires Kubernetes expertise, complex to debug.

---

### 3. Workflow Orchestration
**Best For**: Complex, multi-step remediation.
- **StackStorm**: Open-source automation platform with event routing.
- **Ansible Tower (AWX)**: Execute Ansible playbooks on events.
- **Apache Airflow**: DAG-based workflow orchestration.

**Example**: Multi-step database failover (promote replica, update DNS, notify team).

**Pros**: Visual workflow designer, error handling, retry logic.
**Cons**: Additional infrastructure to maintain, learning curve.

---

### 4. Cloud-Native Automation
**Best For**: Cloud-specific remediation.
- **AWS Systems Manager**: Run commands on EC2 instances.
- **Azure Automation**: Runbooks for Azure resources.
- **GCP Cloud Scheduler + Cloud Functions**: Scheduled or event-driven tasks.

**Example**: Patch EC2 instances, rotate secrets, backup databases.

---

## Comparison Matrix

| Platform | Complexity | Best Use Case | Learning Curve |
| :--- | :--- | :--- | :--- |
| **Lambda/Functions** | Low | Simple event-driven tasks | Low |
| **K8s Controllers** | High | Container orchestration | High |
| **StackStorm** | Medium | Multi-step workflows | Medium |
| **Cloud Automation** | Low | Cloud-specific tasks | Low |

---

## 🏗️ Real-Life Scenario: The "Over-Engineered" Solution
**Problem**: A team uses Apache Airflow to restart a single service when it crashes.
**Outcome**: The Airflow infrastructure (scheduler, webserver, database) is more complex than the service it's managing. Airflow itself crashes more often than the target service.
**Lesson**: **Choose the simplest tool for the job**. A Lambda function would have been sufficient.
**Fix**: Replace Airflow with a simple CloudWatch Alarm → Lambda → ECS Task Restart flow.

---

## ❓ Interview Questions
1.  **When would you choose StackStorm over AWS Lambda?**
    *   *Answer*: When you need complex, multi-step workflows with conditional logic, error handling, and human approval steps. Lambda is better for simple, single-action remediation.
2.  **What is a Kubernetes Operator and how does it relate to auto-remediation?**
    *   *Answer*: An Operator is a Kubernetes controller that encapsulates operational knowledge. It can watch for specific conditions (e.g., pod crashes) and automatically take remediation actions (e.g., restart, scale, reconfigure).

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which platform is best for simple event-driven tasks?** (Serverless Functions / Lambda)
2.  **True/False: Kubernetes Operators require Kubernetes.** (True)
3.  **What is StackStorm used for?** (Workflow orchestration and event-driven automation)
4.  **Which AWS service runs commands on EC2 instances?** (Systems Manager)
5.  **What is the main drawback of serverless functions?** (Cold start latency and execution time limits)
