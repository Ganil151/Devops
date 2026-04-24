# 🦅 The SRE Final Exam: Scenario Injection

> **"Theory is cheap. Break it."**

This script simulates the chaos scenarios from the exam on your local cluster.

```bash
#!/bin/bash

# Scenario 1: The "Thundering Herd" (Frontend Overload)
echo "🚨 Scenario 1: Simulating Global failover..."
kubectl scale deployment frontend --replicas=1 -n online-boutique
echo "⚡ Starting Load Test (1000 RPS)..."
hey -z 30s -c 50 -q 20 http://localhost:80
echo "📊 Check observability: Did the HPA trigger in time?"

# Scenario 2: The "Split Brain" (Network Partition)
echo "🚨 Scenario 2: Simulating DB Partition..."
kubectl label node kind-worker failure-domain.beta.kubernetes.io/zone=us-east-1a --overwrite
kubectl taint nodes kind-worker network=partition:NoSchedule
echo "🔥 Killing Redis Master..."
kubectl delete pod -l app=redis-cart -n online-boutique --force --grace-period=0
echo "📊 Check consistency: Did user carts survive?"

# Scenario 3: The "Zombie" (Cost Leak)
echo "🚨 Scenario 3: Checking for orphaned Load Balancers..."
aws elbv2 describe-load-balancers --query "LoadBalancers[?State.Code=='active'].LoadBalancerArn"
echo "💰 Calculate cost impact of these unused LBs."
```

---
**Usage**: `chmod +x simulate_exam.sh && ./simulate_exam.sh`
