# Monitoring Strategies Reference

**Doc Version:** 1.0.0
**Role:** SRE
**Scope:** RED vs USE Methodologies

---

## 1. The USE Method (For Infrastructure)
*Created by Brendan Gregg.*

Designed for **Resources** (CPU, Memory, Disk, Network). For every resource, check:

1.  **Utilization**: How much time was the resource busy? (e.g., CPU at 90%).
2.  **Saturation**: How much work was queued/waiting? (e.g., Load Average > CPU Count).
3.  **Errors**: Were there any hardware/device errors? (e.g., Dropped packets).

> **Rule**: If Utilization is high but Saturation is 0, the system is performing fine. If Saturation > 0, you have latency.

---

## 2. The RED Method (For Services)
*Created by Tom Wilkie.*

Designed for **Microservices** and Request-driven apps. For every endpoint, measure:

1.  **Rate**: The number of requests per second.
2.  **Errors**: The number of those requests that are failing.
3.  **Duration**: The amount of time those requests take (Distribution/Percentiles).

> **Why Metrics?**: Rate and Errors are counters. Duration is a Histogram.
> **Dashboarding**: Almost every Grafana service dashboard should be built around RED signals.

---

## 3. The Four Golden Signals (Google SRE)

A superset often used in Kubernetes:
1.  **Latency**: Time to serve a request.
2.  **Traffic**: Demand on the system.
3.  **Errors**: Rate of request failures.
4.  **Saturation**: How "full" is the service? (Memory limit vs Usage).

---

## 4. Alerting Policy Philosophy

**Symptoms vs Causes.**
*   **Good Alert**: "Homepage Latency > 2s". (Symptom: The user is suffering).
*   **Bad Alert**: "CPU > 80%". (Cause: Maybe it's just compressing logs? Who cares if the user is happy?).

**Governance Rule**: Page a human ONLY if a user is impacted. For everything else, log a ticket.
