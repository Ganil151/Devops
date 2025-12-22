# Module 10: Software Stack Foundations

As a DevOps Engineer, you aren't just managing servers; you are managing the **delivery pipeline for software**. To build effective pipelines, you must understand the anatomy of the applications you are deploying.

---

## 🎨 1. Frontend: The User's Gateway

The "Front End" is everything the user interacts with directly in their browser.

### Core Technologies
- **HTML (Structure)**: The skeleton of the page.
- **CSS (Presentation)**: The skin and style (Layout, colors, fonts).
- **JavaScript (Behavior)**: The muscles. It handles clicks, form submissions, and data fetching.

### Modern Architectures
- **SPA (Single Page Application)**: The entire app loads once (e.g., React, Vue). Navigation doesn't refresh the page; JS dynamically swaps content. 
- **MPA (Multi-Page Application)**: The "Old School" way. Every link click sends a request to the server, which returns a brand new HTML page.

---

## ⚙️ 2. Backend: The Engine Room

The "Back End" runs on a server and handles data processing, security, and database interactions.

### API Architectures (How Frontend talks to Backend)
- **REST**: Uses standard HTTP methods (GET, POST, PUT, DELETE). Most common.
- **GraphQL**: Allows the client to request *exactly* the data they need.
- **gRPC**: High-performance communication used primarily for internal microservices.

### Language Ecosystems
| Language | DevOps Context |
| :--- | :--- |
| **Node.js (JS/TS)** | Fast, lightweight, used extensively for SPAs and serverless. |
| **Python** | The "Swiss Army Knife." Used for APIs (Flask/Django) and heavily in DevOps scripts. |
| **Java** | Enterprise standard. Requires a JVM (Java Virtual Machine) to run. |
| **Go** | Built for performance and concurrency. Most modern DevOps tools (Docker, K8s) are written in Go. |

---

## 📚 3. Libraries vs. Frameworks

Both are reusable code written by others, but they differ in **Control**.

- **Library (You control it)**: A collection of helper functions. You call the library when you need it (e.g., `lodash`, `requests`).
- **Framework (It controls you)**: A "skeleton" for your app. The framework calls *your* code at specific points. This is called **Inversion of Control** (e.g., `React`, `Spring Boot`, `Django`).

> [!NOTE]
> **DevOps Impact**: Frameworks often come with their own "opinionated" build tools and directory structures, which you'll need to account for in your CI/CD pipelines.

---

## 🚀 4. Runtime Environments

A **Runtime** is the environment in which a program executes. It provides the necessary resources (libraries, memory management) for the code to run.

### Common Runtimes
- **The Browser**: Executes HTML/CSS/JS (V8 engine in Chrome/Edge, SpiderMonkey in Firefox).
- **Node.js**: A runtime that allows JavaScript to run *outside* the browser (on servers).
- **JVM (Java Virtual Machine)**: Allows Java code to run on any OS without modification.
- **Python Interpreter**: Reads and executes Python code line-by-line.

---

## 🐳 5. Transitioning to Containers

In the "old days," we installed these runtimes directly on server OSs. This led to "Version Hell" (e.g., App A needs Node 14, App B needs Node 18).

**The DevOps Solution**: Containerization (Docker). We package the **Application + Runtime + Libraries** into a single image. This ensures the environment is identical from the developer's laptop to the production cluster.

---

## 🛠️ DevOps Checklist for App Stacks
1. **Dependency Scanning**: Are the libraries used by the app secure?
2. **Build Artifacts**: Does the build produce a static folder (Frontend) or an executable/container (Backend)?
3. **Environment Variables**: How does the app get its database URLs or API keys?
4. **Health Checks**: How does the platform (K8s) know if the runtime has crashed?
