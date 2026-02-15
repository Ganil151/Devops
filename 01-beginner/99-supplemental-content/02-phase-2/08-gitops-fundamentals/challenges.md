# 🎯 Challenges: GitOps Fundamentals

## 🟢 Challenge 1: Declarative vs Imperative
**Objective**: Identify which of the following is a "Declarative" command and which is "Imperative":
1. `kubectl apply -f deployment.yaml`
2. `kubectl run nginx --image=nginx`
**Answer**: 1 is Declarative, 2 is Imperative.

## 🟡 Challenge 2: The Drift Simulation
**Objective**: 
1. Manually edit a running deployment's replica count using `kubectl edit`.
2. Observe how a GitOps agent (like ArgoCD) would react if the replica count in Git remained at 1.
**Task**: Explain in 2 sentences how "Self-Healing" works in this scenario.

## 🔴 Challenge 3: Push-to-Pull Conversion
**Objective**: Diagram a Jenkins pipeline that currently uses `ssh` to deploy code and describe 3 security risks this "Push" model poses compared to a "Pull" model.
