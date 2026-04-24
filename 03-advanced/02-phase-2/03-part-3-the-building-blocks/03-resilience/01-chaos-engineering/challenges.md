# 🏆 Chaos Engineering Challenges

Master the art of breaking production (safely) to build ultimate system confidence.

---

## 🏗️ Challenge 01: The "Kill Pod" Experiment
**Objective**: Verify Kubernetes self-healing and HPA responses.

1.  **Scenario**: A random pod in your application cluster is terminated.
2.  **Task**: Use a tool like **LitmusChaos** or a simple `sh` loop to kill a random pod in the namespace every 60 seconds.
3.  **Action**: Observe the "Ready" state of the Service. Does it drop traffic?
4.  **Requirement**: Achieve zero downtime using **PodDisruptionBudgets (PDB)** and **Readiness Probes**.

---

## 🛡️ Challenge 02: The "Network Latency" Injector
**Objective**: Prove your circuit breakers work as designed.

1.  **Goal**: Inject 500ms of latency to all traffic going to the "Checkout" service.
2.  **Task**: Create an Istio **Fault Injection** rule or use a Chaos Tool to add latency.
3.  **Discovery**: Does your application UI show a "Broken Pipe" or a friendly "Loading..." message? (Research: Graceful Degradation).
4.  **Metric**: Track the "P99 Response Time" on your Grafana dashboard during the experiment.

---

## 📉 Challenge 03: The "Memory Hog" Test
**Objective**: Test node-level stability and OOM killer behavior.

1.  **Task**: Deploy a pod that continuously consumes RAM until it reaches 90% of the node's capacity.
2.  **Observation**: Are other pods on the same node "evicted"?
3.  **Verification**: Confirm that your cluster has **Resource Quotas** and **PriorityClasses** to protect critical components (like the API Server or Database).

---

## 📁 Solutions
Chaos manifest examples and experiment templates are located in the `Boilerplates/` directory.
