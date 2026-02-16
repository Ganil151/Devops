# 🌐 Distributed Job Scheduling
*Version 1.0 | Moving Beyond the Single Server*

---

## 📖 Overview
In a cloud-native or high-scale environment, scheduling jobs on a single server is a "Single Point of Failure" (SPOF). Distributed job scheduling involves managing tasks across a cluster of servers to ensure high availability and scalability.

---

## 🏗️ Modern Orchestration Options

### 1. Kubernetes CronJobs
- **Design**: A wrapper around standard Kubernetes Jobs.
- **Workflow**: The K8s controller spawns a temporary Pod to run the task and deletes it upon completion.
- **Advantage**: Automatically handles failures; if a node dies, the job starts on another one.

### 2. AWS EventBridge + Lambda
- **Design**: Serverless scheduling.
- **Workflow**: EventBridge (Rule) triggers an asynchronous Lambda function.
- **Advantage**: Zero infrastructure to manage; pay only for execution time.

### 3. Dedicated Schedulers (Nomad, Rundeck, Airflow)
- **Nomad**: HashiCorp's orchestrator; excellent for simple binary jobs.
- **Airflow**: Workflow-based; best for complex data pipelines with dependencies.

---

## ⚙️ Technical Hurdles

### 1. Concurrency Control
In a distributed system, you must ensure only ONE instance of a job runs unless parallelism is desired.
- **Solution**: Use distributed locks (Redis, Etcd, DynamoDB).

### 2. Observability
Logs are scattered across nodes.
- **Solution**: Use centralized logging (ELK, Splunk, CloudWatch) with a unique **Task ID**.

### 3. Retries & Backoffs
If an API is down, the scheduler should not retry 100 times in 1 second.
- **Solution**: Implement **Exponential Backoff**.

---

## 🏛️ Comparison Matrix

| Solution | Manage Burden | Scale | Best For |
| :--- | :--- | :--- | :--- |
| **K8s CronJob** | Medium | Extreme | Microservices pods. |
| **EventBridge** | Low (Serverless)| High | Cloud-native functions. |
| **Rundeck** | High (Server) | Medium | Ops automation & RBAC. |
| **Airflow** | High | Extreme | Data engineering DAGs. |

---

## 🚀 SRE Pro-Tip: The "At-Most-Once" vs "At-Least-Once"
- **At-Least-Once**: Job will run, but might run twice in a failure scenario. **Requires Idempotency**.
- **At-Most-Once**: Job will never run twice, but might occasionally miss a run.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain how Kubernetes handles missed schedules in a CronJob.**
2. **What is a "Dead Letter Queue" (DLQ) in the context of serverless scheduling?**
3. **Describe the impact of "Clock Drift" on a distributed job scheduler.**
4. **How does Airflow's "DAG" (Directed Acyclic Graph) differ from a linear cron list?**
5. **What is "Work Stealing" in the context of high-performance task runners?**

---
**Back to foundations**: [Cron Syntax →](./cron-syntax-standard-ref.md)
