# Missing Sections for Interview Prep and Quizzes

This file contains the high-fidelity enhancements for the Interview module.

---

## 👔 Senior DevOps Interview Questions (Architect Level)

1. **Q: How does Kubernetes handle the "Split Brain" problem in etcd?**
   *   *A: It uses the **Raft Consensus Algorithm**. It requires a **Quorum** (majority) of nodes to agree on any state change. This is why we always run etcd in odd numbers (3, 5, 7).*

2. **Q: Explain the flow of a request from your browser to a Pod inside the cluster.**
   *   *A: Browser -> DNS -> Cloud Load Balancer -> Ingress Controller (L7) -> Service (ClusterIP) -> Kube-Proxy (iptables) -> Target Pod IP.*

3. **Q: What are the risks of using `HostPath` volumes in production?**
   *   *A: Security risks (containers can access host system files) and Portability risks (if the pod moves to another node, the data isn't there).*

---

## 🛠️ CKA Technical Lab Challenges

Can you solve these in 5 minutes?

1.  **The Broken Scheduler**: A node is healthy but No Pods are being scheduled. The Scheduler pod is crashing. How do you fix it?
2.  **The Secret Leak**: You need to rotate a secret used by a deployment. How do you do it with zero downtime?
3.  **The Noisy Neighbor**: One namespace is consuming 90% of the cluster's RAM. How do you implement a quota to stop it?

---

## 📖 Real-World DevOps Story: "The Interviewee who knew too much"

**The Scenario:** During an interview, a candidate was asked about `kubectl delete pod`. Instead of just saying it deletes the pod, they explained the **Graceful Termination Lifecycle**.

**The explanation:** "When you delete a pod, it enters `Terminating` state. The API informs the Kubelet. The Kubelet sends a `SIGTERM`. Simultaneously, the Service controller removes the pod IP from its Endpoints. This ensures that *while* the pod is cleaning up, no *new* traffic is sent to it."

**The Result:** The candidate was hired as a Senior Architect because they proved they understood the **Internal Synchronization** of Kubernetes, not just the commands.

---

## 🧠 Knowledge Check

1. What is the name of the log file for the Kubelet on a Linux node? (`/var/log/syslog` or `journalctl -u kubelet`)
2. In which file do you define the connection details for `kubectl`? (`~/.kube/config`)
3. What is the default grace period for a pod deletion? (30 seconds)
