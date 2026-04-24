# 🎓 Kubernetes Interview Preparation & Technical Quiz

## 📋 Overview

Kubernetes is one of the most assessed skills in modern DevOps interviews. It is not enough to know the commands; you must understand the **Architecture**, **Consistency Models**, and **Failure Modes**. This module prepares you for everything from Junior screenings to Senior CKA-level architectural discussions.

### 🎯 Learning Objectives

By the end of this module, you will:
- Confidently answer the **Top 20 Technical Questions**.
- Solve **CKA-style Lab Challenges** in simulated environments.
- Explain the **Internal Lifecycle** of Pods, Services, and Deployments.
- Understand **High Availability** and **Consensus** (etcd/Raft).
- Pass the 30-Question master quiz.

---

## 👔 Senior Deep-Dives

### 1. The Pod Lifecycle (Internal)
When you run `kubectl delete`, what actually happens?
- **Step 1**: Pod marked for deletion in etcd.
- **Step 2**: Endpoint controller removes pod from Services.
- **Step 3**: Kubelet sends `SIGTERM` to containers.
- **Step 4**: App shuts down gracefully.
- **Step 5**: Kubelet sends `SIGKILL` (if timeout reached).

### 2. High Availability Topologies
- **Stacked Control Plane**: etcd runs on the same nodes as control plane.
- **External etcd**: etcd runs on a separate dedicated cluster (More secure/stable).

---

## 🛠️ CKA Mini-Labs

**Challenge 1: Troubleshooting Scheduling**
*   *Task*: A pod is stuck in `Pending`. The node says `1 node(s) had untolerated taint {key: value}`. 
*   *Solution*: Add a `toleration` to the pod spec or remove the `taint` from the node.

**Challenge 2: Resource Quotas**
*   *Task*: Limit the 'dev' namespace to only 2 CPU cores.
*   *Solution*: Create a `ResourceQuota` object in the 'dev' namespace.

---

## 🎤 Top 5 Senior Questions

1. **How do you handle secrets without using Kubernetes Secret objects?**
   *   *Using External Secrets Operator (ESO) to sync from AWS Secrets Manager or HashiCorp Vault.*
2. **What is the difference between IPVS and iptables in kube-proxy?**
   *   *IPVS is more performant for clusters with thousands of services because it uses hash tables instead of linear rule scanning.*
3. **How does a Deployment controller know it needs to scale up?**
   *   *It continuously compares the **Desired State** (etcd) vs. the **Actual State** (running pods) and issues commands to the ReplicaSet.*

---

## 📖 Real-World DevOps Story: "The explanation that won the job"

**The Scenario:** A candidate was asked: "What happens if etcd goes down?"
**The Winning Answer:** "The existing pods keep running because Kubelet and Kube-proxy already have their rules. However, you cannot change anything. You can't deploy new apps, you can't scale, and if a pod crashes, Kubernetes won't know it needs to restart it. The cluster is effectively 'frozen' until etcd is restored."

---

## 🧠 Knowledge Check

1. Which algorithm does etcd use for consistency? (Raft)
2. What is the command to see if you have permission to perform an action? (`kubectl auth can-i`)
3. Where does the API server store its data? (etcd)

---

## 🔗 Internal Navigation
- [Next: Real-Life Scenarios](../13-real-life-scenarios/readme.md)
- [Back: Part 6 Overview](../readme.md)
- [Mastery: Deep Dives](../deep-dives/readme.md)