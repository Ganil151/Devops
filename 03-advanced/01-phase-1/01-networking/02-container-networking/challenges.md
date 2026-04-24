# Advanced Container Networking Challenges ☸️

In-depth mastery of CNI plugins, Service Discovery, and Ingress Performance.

---

## 🏆 Challenge 01: CNI Performance Deep Dive
**Objective**: Choose the right CNI (Container Network Interface) for your workload.

1.  **Scenario**: A financial app requires sub-millisecond latency. 
2.  **Task**: Compare **Calico**, **Cilium (eBPF)**, and **AWS VPC CNI**.
3.  **Action**: Research "Native VPC Routing" vs "Overlay (VXLAN) Networks."
4.  **Goal**: Write a one-page recommendation explaining why Cilium's eBPF datapath is faster than standard Iptables.

---

## 🏆 Challenge 02: Ingress Controller Tuning (Nginx)
**Objective**: Optimize the entry point for 50,000 requests per second.

1.  **Requirement**: An Nginx Ingress Controller on K8s.
2.  **Task**: Modify the `ConfigMap` for the controller to include:
    *   `keep-alive`: 120s
    *   `proxy-body-size`: 10m
    *   `worker-processes`: Auto
3.  **Discovery**: How do you monitor the "Upstream Response Time" in Prometheus?
4.  **Verification**: Write a command to check the internal Nginx configuration LIVE from the ingress pod.

---

## 🏆 Challenge 03: The Multus Multi-Interface Pod
**Objective**: Create a pod with multiple network interfaces for specialized workloads.

1.  **Task**: Research the **Multus CNI**.
2.  **Scenario**: A 5G core function pod needs a management interface on VPC and a data-plane interface on a high-speed fiber backbone.
3.  **Action**: Draft an K8s Custom Resource definition for a `NetworkAttachmentDefinition`.
4.  **Discovery**: How does the Operating System inside the pod see these different interfaces? (`eth0`, `eth1`, etc?)

---

## 📁 Solutions
CNI configuration YAMLs and Nginx tuning templates are in the `Boilerplates/` directory.
