# Pipeline Governance & Strategy Reference

**Doc Version:** 1.0.0
**Role:** Release Engineer
**Scope:** Pipeline Design Patterns & Artifact Lifecycle

---

## 1. The Core Philosophy: Build Once, Deploy Many

This is the single most important rule in Continuous Delivery.

- **The Anti-Pattern:**
    - Build for Dev -> Deploy.
    - Re-build for QA (from same commit) -> Deploy.
    - Re-build for Prod (from same commit) -> Deploy.
    *Risk:* The compilers/dependencies might have changed slightly between builds. You are checking "Code", not the "Binary".

- **The Enterprise Pattern (Immutability):**
    - **Build STAGE:** Create `app-v1.jar` -> Upload to Artifactory.
    - **Deploy Dev STAGE:** Download `app-v1.jar` -> Deploy.
    - **Deploy Prod STAGE:** Download `app-v1.jar` -> Deploy.
    *Guarantee:* Exactly the same bytes running in Prod as were tested in QA.

---

## 2. Pipeline Stages & Gates

A robust Enterprise pipeline is a series of gates.

### 1. The Commit Stage (Fast Feedback)
- **Goal:** < 5 Minutes.
- **Jobs:** Compile, Unit Tests, Static Analysis (Linting).
- **Result:** If this fails, the code is rejected immediately.

### 2. The Acceptance Stage (Confidence)
- **Goal:** < 30 Minutes.
- **Jobs:** Integration Tests, Security Scanning (SAST/DAST), Docker Build.
- **Parallelism:** Run lengthy tests in parallel to save time.

### 3. The Deployment Stage (Control)
- **Goal:** Reliability.
- **Jobs:** Infrastructure update (Terraform), App Deployment, Health Checks.
- **Manual Gate:** Production usually requires a human "Click to Promote" button.

---

## 3. Idempotency

**Definition:** Running the pipeline twice on the same commit should produce the same result (or a safe "no-op").
- **Bad:** A script that appends a line to a config file every run (file grows infinitely).
- **Good:** A script that ensures the line exists (checks presence before adding).

---

## 4. Fail Fast Strategy

In a Directed Acyclic Graph (DAG) of jobs, dependencies matter.

- If `Build` fails, do **not** run `Test` or `Deploy`.
- **Why?** Saves compute costs and reduces noise.
- **Implementation:**
  - GitHub Actions: `needs: [build]`
  - Jenkins: `stage('Test') { ... }` (Sequential by default)

---

## 5. Branch Strategy Mapping

Your pipeline strategy must match your branching strategy (Ref: *Git Reference*).

| Branch | Pipeline Behavior |
| :--- | :--- |
| **Feature Branches** | Run Unit Tests + Linting. No Deploy. Report Status to PR. |
| **Main/Master** | Run Full Suite + Deploy to Staging/Dev. |
| **Tags (v1.0)** | Trigger Release Pipeline -> Deploy to Production. |
