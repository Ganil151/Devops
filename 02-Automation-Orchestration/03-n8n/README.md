# 🤖 n8n AI Automation Stack

A production-ready, self-hosted automation infrastructure combining the power of **n8n orchestration**, **PostgreSQL persistence**, and **Ollama local AI**.

## 🏗️ Architecture
This stack consists of three primary layers:
1.  **n8n (Orchestrator)**: The brain of the operation, where workflows are built and executed.
2.  **PostgreSQL (Persistence)**: A robust database to store workflow data, credentials, and execution history.
3.  **Ollama (AI Engine)**: A local inference engine hosting Large Language Models (LLMs) like Qwen and DeepSeek, ensuring data privacy.

## 📋 Prerequisites
- **Docker & Docker Compose**: Installed and running.
- **System Memory**: 
  - Minimum **8GB RAM** for small models (1.5B/3B).
  - Recommended **16GB+ RAM** for larger models (7B/DeepSeek-R1).
- **Disk Space**: ~20GB for database records and AI model weights.

## 🚀 Quick Start
Launch the entire stack with a single command from this directory:
```bash
sudo docker compose up -d
```

# Pull Qwen 2.5-Coder for development
sudo docker exec -it ollama ollama pull qwen2.5-coder

# Pull DeepSeek-R1 for reasoning
sudo docker exec -it ollama ollama pull deepseek-r1

---
*Created by the Senior DevOps & Automation Architect.*
