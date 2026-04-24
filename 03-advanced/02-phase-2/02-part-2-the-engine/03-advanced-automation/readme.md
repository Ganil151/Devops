# 🤖 Advanced Automation & Orchestration

> **"If you do it twice, automate it. If you need it done instantly, build an event-driven system. If it requires 500 lines of Bash, switch to Python."**

Welcome to **Advanced Automation**. This is where we break out of "Simple Scripts" and build "Automation Platforms."

## 🛣️ The Curriculum

### [📐 Part 1: The Blueprint (Advanced Python)](./01-part-1-the-blueprint/)
**The Objective**: Write software, not scripts.
*   **Key Concepts**: 
    *   **AsyncIO**: Managing 1,000 concurrent API calls.
    *   **Decorators**: Meta-programming for logging and retry logic.
    *   **Design Patterns**: Factory and Strategy patterns for multi-cloud abstraction.

### [⚙️ Part 2: The Engine (Infra Scale)](./02-part-2-the-engine/)
**The Objective**: Provisioning beyond the basics.
*   **Key Concepts**:
    *   **Terraform Enterprise**: Private Module Registries and Sentinel Policy Sets.
    *   **Bare Metal**: PXE Boot, MaaS, and automating physical hardware.

### [🧩 Part 3: The Building Blocks (Orchestration)](./03-part-3-the-building-blocks/)
**The Objective**: Complex Workflows.
*   **Key Concepts**:
    *   **Advanced CI/CD**: Dynamic Pipelines generated at runtime.
    *   **Custom Scripts**: Integration glue for weird legacy systems.

### [🛡️ Part 4: The Safety Net (Performance)](./04-part-4-the-safety-net/)
**The Objective**: Automation must be fast and safe.
*   **Key Concepts**:
    *   **Performance Testing**: Load testing APIs with Locust.
    *   **Rate Limiting**: Handling backpressure in automated systems.

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal Approach |
|:---|:---|:---|
| **Concurrency** | "I run the script in 5 terminal tabs." | "I use Python `asyncio` to handle 10k connections." |
| **Logic** | "Verify output with `grep`." | "Parse JSON output and validate schema." |
| **Hardware** | "We install OS manually." | "We boot via PXE and configure via Ansible." |

---

## 🛠️ The Toolkit

*   **Python (AsyncIO/Click)**: Building CLI tools.
*   **Terraform Enterprise**: Managing state at scale.
*   **Locust**: Python-based load testing.

---
**Status**: ✅ Organized (2026-02-02)
