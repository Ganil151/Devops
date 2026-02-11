# 🧪 DevOps Assessment Tests: The Screening Survival Guide

> **Goal:** Pass the initial "filter" rounds (Online Screens & Take-Homes) that eliminate 80% of candidates before they even talk to a human.

---

## 📂 Assessment Types

- ⏱️ **[Online Screening Strategies](./online-screening-strategies.md)**: Handling platform tests like HackerRank, Codility, and GLIDER.
- 🏠 **[Take-Home Project Logic](./take-home-logic.md)**: How to build a "Production-Grade" project in 4 hours that beats candidates who spend 20.
- 🧠 **[The "Self-Assessment" Hub](../../../../06-quizzes/README.md)**: Internal quizzes to test your own knowledge before the real thing.

---

## 🔍 What Companies are Testing For

Assessment tests are rarely just about the code. They are evaluating:

1. **Clean Documentation**: Does your `README.md` explain *how* to run the solution?
2. **Error Handling**: What happens if the API is down? Did you use `try/except` in Python?
3. **Security Awareness**: Did you hardcode an AWS Secret? (Instant fail).
4. **Idempotency**: If I run your Terraform/Ansible twice, does it break?

---

## 💡 The "DevOps Golden Rule" for Assessments

> **"Assume the person grading your test is tired and has 5 minutes."**

- **Automate the Setup**: Provide a `setup.sh` or `docker-compose up`.
- **Visualize**: Include an architecture diagram in the repo.
- **Fail Gracefully**: If your code fails, it should tell the user *why* clearly.

---

## 📈 Preparation Roadmap

1. **Junior**: Practice Bash/Python fundamentals and basic Docker containerization.
2. **Intermediate**: Focus on Terraform state management and Docker multi-stage builds.
3. **Senior/Staff**: Focus on High Availability (HA) logic, SLO/SLI measurement, and security posture.

---
*Next: [Online Screening Strategies](./online-screening-strategies.md)*
