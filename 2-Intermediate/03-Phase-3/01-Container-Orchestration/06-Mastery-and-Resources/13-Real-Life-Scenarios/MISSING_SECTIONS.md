# Missing Sections for Real-Life Scenarios

This file contains the high-fidelity enhancements for the Troubleshooting and Scenarios module.

---

## 🔍 Scenario 6: The "Silent Timeout" (Network Policy)

**The Problem:** Your microservices look healthy (Green in `kubectl get pods`), but they can't talk to each other. Every request results in a `Connection Timeout`.

**The Root Cause:** Someone applied a strict **Network Policy** that blocks all ingress/egress by default. 

**The Investigation:**
1.  Check for existing policies: `kubectl get netpol -A`.
2.  Test connectivity from inside a pod: `kubectl exec -it <pod> -- curl -v http://backend-service`.

**The Fix:** Create a Network Policy that explicitly allows traffic from the `frontend` label to the `backend` label on the correct port.

---

## 🏗️ Scenario 7: The "Zombie Volume Attachment"

**The Problem:** You deleted a pod, but the new pod is stuck in `ContainerCreating` for 10 minutes. The error message is `Multi-Attach error for volume: volume is already exclusively attached to one node`.

**The Root Cause:** The cloud provider (AWS/Azure) still thinks the old disk is attached to the old node, even though the pod is gone.

**The Fix:** 
1.  Find the `VolumeAttachment` object: `kubectl get volumeattachment`.
2.  Verify if the old node still holds the lock.
3.  If it persists, you may need to force-delete the VolumeAttachment (CAUTION: Ensure data isn't being written!).

---

## 📖 Real-World DevOps Story: "The Night the HPA went Crazy"

**The Scenario:** A retail site configured a **Horizontal Pod Autoscaler (HPA)** based on CPU usage. During a flash sale, a bug caused the application to use 100% CPU on startup while loading cache.

**The Result:** 
1.  CPU spike triggered HPA to scale to 50 pods.
2.  The massive launch caused the cluster to hit the AWS instance limit.
3.  New nodes couldn't start, but existing nodes were overloaded with starting pods.
4.  The cluster entered a "Death Spiral."

**The Lesson:** 
- Use **Readiness Probes** carefully. If an app uses 100% CPU just to start, don't use CPU as the *only* metric for HPA. 
- Set reasonable **Max Replicas** that your infrastructure can actually handle.

---

## 👨‍💻 Interview Preparation (Troubleshooting Expert)

1. **Q: How do you debug a pod that has no logs but is crashing?**
   *   *A: Use `kubectl describe pod` to check Events. If that doesn't work, try `kubectl debug` to attach an ephemeral container with better tools (like `strace` or `tcpdump`) to the running process.*

2. **Q: What is the first thing you check when a Service is returning 404?**
   *   *A: Check the **Endpoints**. If `kubectl get endpoints <service-name>` is empty, the selector in the Service doesn't match the labels in the Pods.*

3. **Q: Explain the 'OOMKilled' error.**
   *   *A: It means the container tried to use more memory than its `limits` allowed. The Linux kernel stepped in and killed the process to protect the node's stability.*

---

## 🧠 Knowledge Check

1. Which command shows you the "human-readable" history of a pod? (`kubectl describe pod`)
2. What does an Exit Code of `137` usually mean? (Out of Memory - OOM)
3. How do you see the logs of a container that just crashed 1 minute ago? (`kubectl logs <pod> --previous`)
