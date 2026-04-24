# Orchestration Beyond Compose Challenges 🏗️

Bridge the gap between single-host Compose and multi-host orchestration.

---

## 🏆 Challenge 01: Swarm Mode Initialization
**Objective**: Transform your single Docker host into a one-node cluster.

1.  **Task**: Enable Swarm mode on your machine.
2.  **Command**: Research the `docker swarm init` command.
3.  **Verification**: Run `docker node ls` and identify your machine as the "Leader."

---

## 🏆 Challenge 02: Declarative Deployment
**Objective**: Define service replicas using the `deploy` key.

1.  **Task**: Create a `swarm-stack.yml` file.
2.  **Requirement**: Add a `deploy` section to a service with `replicas: 3`.
3.  **Command**: Research how to deploy this stack using `docker stack deploy`.
4.  **Goal**: Explain why `docker compose up` ignores the `deploy` key while `docker stack deploy` uses it.

---

## 🏆 Challenge 03: The Kompose Bridge
**Objective**: Translate a Compose file into Kubernetes manifests.

1.  **Requirement**: Install the `kompose` tool.
2.  **Task**: Take any working `docker-compose.yml` and run `kompose convert`.
3.  **Analysis**: Look at the generated files (e.g., `web-deployment.yaml`, `web-service.yaml`).
4.  **Question**: How does `kompose` handle Docker "Volumes" when converting to Kubernetes? (Research: PersistentVolumeClaims).

---

## 📁 Solutions
Conceptual guides and CLI snippets are located in the `README.md` of this module.
