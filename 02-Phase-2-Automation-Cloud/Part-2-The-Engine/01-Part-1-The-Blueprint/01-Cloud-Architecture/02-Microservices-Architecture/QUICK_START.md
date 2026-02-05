# 🚀 Quick Start Guide - Microservices Architecture

**5-Minute Navigation** | Get started immediately

---

## 📖 Where to Begin

### If you're new to microservices:
1. Start with [README.md](./README.md) - Section: "From Monolith to Microservices"
2. Read the patterns overview
3. Try [Challenge 1](./CHALLENGES.md#challenge-1-design-a-saga-pattern-🟡) (Design a Saga)

### If you want hands-on code:
1. Go to [`boilerplates/resilient-client-python/`](./boilerplates/resilient-client-python/)
2. Install: `pip install -r requirements.txt`
3. Run: `python examples.py`

### If you're preparing for interviews:
1. Jump to [README.md - Interview Preparation](./README.md#interview-preparation)
2. Review [Real-World Case Studies](./README.md#real-world-case-studies)
3. Answer the 5 senior architect questions

### If you need deployment examples:
1. Browse [`boilerplates/k8s-manifests/`](./boilerplates/k8s-manifests/)
2. Pick: Envoy, Dapr, or Istio
3. Deploy to your cluster

---

## 📚 Content Map

| What You Need | Where to Find It | Time |
|---------------|------------------|------|
| **Pattern Theory** | README.md → Patterns & Principles | 30 min |
| **Communication** | README.md → Communication Patterns | 20 min |
| **Data Management** | README.md → Saga Pattern, CQRS | 25 min |
| **Resiliency** | README.md → Circuit Breaker, Bulkhead | 20 min |
| **Code Examples** | boilerplates/ (Go or Python) | 15 min |
| **Kubernetes** | boilerplates/k8s-manifests/ | 20 min |
| **Challenges** | CHALLENGES.md | 2-8 hrs each |
| **Case Studies** | README.md → Netflix, Amazon, Uber | 15 min |

---

## 🎯 Learning Paths

### Path 1: Theory First (2-3 hours)
```
1. README.md (Patterns & Principles)        → 30 min
2. README.md (Communication Patterns)       → 20 min
3. README.md (Data Management)              → 25 min
4. README.md (Resiliency Patterns)          → 20 min
5. README.md (Service Mesh & API Gateway)   → 20 min
6. README.md (Real-World Case Studies)      → 15 min
7. Review Interview Questions               → 30 min
```

### Path 2: Code First (2-3 hours)
```
1. boilerplates/resilient-client-python/    → 30 min
2. Run examples.py and read code            → 20 min
3. boilerplates/resilient-client-go/        → 30 min
4. boilerplates/k8s-manifests/ (pick one)   → 30 min
5. CHALLENGES.md (Challenge 2)              → 60 min
```

### Path 3: Interview Prep (1 hour)
```
1. README.md (Interview Preparation)        → 30 min
2. README.md (Case Studies)                 → 15 min
3. Practice answering questions aloud       → 15 min
```

### Path 4: Hands-On Projects (10+ hours)
```
1. CHALLENGES.md (Challenge 1-3)            → 6 hrs
2. Deploy k8s-manifests locally             → 2 hrs
3. Build full microservices app (bonus)     → 40+ hrs
```

---

## 🔥 Top 5 Must-Read Sections

### 1. Saga Pattern (README.md)
**Why:** Core distributed transaction pattern  
**Key Takeaway:** Choreography vs Orchestration  
**Time:** 15 minutes

### 2. Circuit Breaker Pattern (README.md)
**Why:** Prevents cascading failures  
**Key Takeaway:** State machine (Closed/Open/Half-Open)  
**Time:** 10 minutes

### 3. Resilient Client - Python (boilerplates/)
**Why:** Production-ready code you can use immediately  
**Key Takeaway:** How to implement retries + circuit breaker  
**Time:** 20 minutes

### 4. Netflix Chaos Engineering (Case Study)
**Why:** Learn from real-world failures  
**Key Takeaway:** Test in production, design for failure  
**Time:** 5 minutes

### 5. Challenge 2: Implement Circuit Breaker (CHALLENGES.md)
**Why:** Hands-on practice solidifies learning  
**Key Takeaway:** Build it yourself  
**Time:** 3-4 hours

---

## 💡 Quick Reference

### Common Patterns Cheat Sheet

| Pattern | Use When | Example |
|---------|----------|---------|
| **Saga** | Distributed transactions | Order → Payment → Shipment |
| **Circuit Breaker** | Prevent cascading failures | Payment service down |
| **Bulkhead** | Isolate resources | Separate thread pools |
| **Retry** | Transient failures | Network timeout |
| **Event-Driven** | Loose coupling | Order placed → Notify inventory |
| **CQRS** | Read/Write optimization | Product catalog |
| **API Gateway** | Single entry point | Kong, Tyk |
| **Sidecar** | Cross-cutting concerns | Envoy, Dapr |

### When to Use Sync vs Async

| Factor | Synchronous (REST/gRPC) | Asynchronous (Kafka/RabbitMQ) |
|--------|------------------------|-------------------------------|
| **Latency Needed** | Low (< 100ms) | High latency OK |
| **Response Required** | Yes (user waiting) | No (fire-and-forget) |
| **Coupling** | Tighter | Looser |
| **Example** | User login | Email notification |

---

## 🛠️ Quick Commands

### Run Python Resilient Client
```bash
cd boilerplates/resilient-client-python/
pip install -r requirements.txt
python examples.py
```

### Run Go Resilient Client
```bash
cd boilerplates/resilient-client-go/
go get github.com/sony/gobreaker
go run main.go client.go retry.go
```

### Deploy Envoy Sidecar
```bash
cd boilerplates/k8s-manifests/
kubectl apply -f envoy-sidecar.yaml
```

### Deploy Dapr
```bash
dapr init -k
kubectl apply -f dapr-configuration.yaml
```

### Deploy Istio
```bash
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled
kubectl apply -f istio-virtualservice.yaml
```

---

## 🎓 Study Tips

### For Exams/Certifications:
- Focus on README.md theory sections
- Memorize pattern names and use cases
- Review Mermaid diagrams (visual memory)
- Answer interview questions out loud

### For Practical Projects:
- Start with boilerplate code
- Modify examples for your use case
- Complete challenges in order (1 → 10)
- Build the bonus full application

### For Job Interviews:
- Read all 3 case studies (Amazon, Netflix, Uber)
- Practice explaining patterns in simple terms
- Be ready to draw diagrams on whiteboard
- Know when NOT to use microservices

---

## 📞 Getting Help

**Stuck on a concept?**
- Re-read the relevant README.md section
- Look at the code examples
- Try the simpler challenges first

**Code not working?**
- Check dependencies (requirements.txt, go.mod)
- Verify versions match
- Read error messages carefully

**Want to go deeper?**
- Check "Additional Resources" in README.md
- Read the referenced books
- Explore official documentation links

---

## ✅ Daily Learning Plan

**Day 1: Foundations**
- Read "Patterns & Principles"
- Understand Monolith → Microservices

**Day 2: Communication**
- Learn sync (REST/gRPC)
- Learn async (Kafka/RabbitMQ)

**Day 3: Data & Transactions**
- Study Saga Pattern
- Understand CQRS

**Day 4: Resiliency**
- Circuit Breaker
- Bulkhead
- Retries

**Day 5: Hands-On**
- Run Python resilient client
- Complete Challenge 1

**Day 6: Deployment**
- Study k8s-manifests
- Try deploying locally

**Day 7: Review & Practice**
- Review all patterns
- Answer interview questions
- Plan your next project

---

## 🎯 Success Criteria

You've mastered this module when you can:

✅ Explain the difference between Saga Choreography and Orchestration  
✅ Implement a circuit breaker from scratch  
✅ Design a database schema for microservices (database-per-service)  
✅ Choose when to use sync vs async communication  
✅ Deploy a service mesh (Istio/Dapr)  
✅ Troubleshoot distributed tracing issues  
✅ Answer "How do you prevent cascading failures?"  
✅ Cite real-world examples (Netflix Chaos Monkey)  

---

**Ready to dive in?** → Start with [README.md](./README.md)  
**Need code now?** → Jump to [boilerplates](./boilerplates/)  
**Want a challenge?** → Open [CHALLENGES.md](./CHALLENGES.md)

---

**Last Updated:** 2026-01-19  
**Module:** 02-Microservices-Architecture
