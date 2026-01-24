# Jenkins Architecture
*Understanding the Controller-Agent Model*

To scale Jenkins beyond simple jobs, you must understand its distributed architecture. Scaling is achieved by offloading work from the primary "Controller" to multiple "Agents."

---

## 🏗️ Master-Agent (Controller-Agent) Model

Jenkins operates on a distributed architecture to handle large numbers of builds simultaneously.

> **⚠️ Missing Image**: *Jenkins Master-Agent Architecture* ('../../../../../00-Resources/03-Images-Diagrams/jenkins_master_agent_architecture.png')

### 1. The Controller (The Brain)
*   **Role**: Manages the UI, configuration, plugin management, and project scheduling.
*   **Best Practice**: The Controller should **never** run actual build jobs. Its job is to coordinate.

### 2. The Agent (The Muscle)
*   **Role**: Executes the actual build steps defined in the pipeline.
*   **Connectivity**: 
    *   **SSH**: Standard for Linux agents.
    *   **JNLP/Inbound**: Common for Windows agents behind firewalls.
    *   **Docker/K8s**: Dynamic agents that spin up on-demand.

---

## ⚙️ Key Architectural Components

### Executors
The number of parallel tasks an Agent can perform at once. Generally based on the available CPU/RAM of the agent machine.

### Workspaces
The directory on the Agent where the build takes place. Jenkins automatically wipes or keeps these based on the `post` actions.

### Remoting
The protocol Jenkins uses to communicate between the Controller and the Agents.

---

## 💡 Real-World Scenario: Parallel Scaling
If you have 10 teams all building Docker images at 9:00 AM, a single server would crash. By using **Ephemeral Agents** (on AWS or Kubernetes), Jenkins can spin up 10 temporary Linux containers, run the builds in parallel, and then tear them down.

---

## 🎤 Interview Preparation

### 1. Why should you avoid running builds on the Jenkins Controller?
Running builds on the Controller can exhaust its resources (CPU/Memory/Disk), making the UI unresponsive and potentially crashing the entire system.

### 2. What are "Dynamic Agents"?
Agents that are created only when a build starts (e.g., as a Docker container or K8s Pod) and are destroyed immediately after the build completes.

### 3. How do Agents connect to the Controller?
Via SSH (Inbound to Agent) or JNLP (Outbound from Agent to Controller).

---

## 🎯 Next Steps
*   **[Installation and Setup](../03-Installation-and-Setup/README.md)**: Putting theory into practice.
