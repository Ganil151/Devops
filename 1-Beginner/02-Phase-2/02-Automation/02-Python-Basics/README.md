# Module 2: Python for DevOps Automation
*Mastering System Orchestration and Web Interaction with Python*

Python is the "glue" of the DevOps world. Its readability, vast ecosystem of libraries, and cross-platform compatibility make it the primary choice for complex automation that exceeds the capabilities of Shell scripting.

![Python DevOps Hub](./assets/python_devops_hub.png)

---

## 🗺️ Learning Path

![Python Learning Path](./assets/python_learning_path.png)

---

## 🌐 Python DevOps Ecosystem

![Python Ecosystem](./assets/python_ecosystem.png)

---

## 🎯 Learning Objectives
- Master Python environments and package management (`pip`, `venv`).
- Automate web interactions: HTTP Requests, Scraping, and REST API integration.
- Build micro-web services for automation status and internal tools.
- Implement browser-based automation for legacy systems and testing.
- Leverage asynchronous patterns for high-performance automation.

---

## 🏛️ Python Automation Architecture
```mermaid
graph TD
    A[Python Automation Engine] --> B[System Ops]
    A --> C[Web & API Ops]
    A --> D[GUI & Browser Ops]
    
    subgraph "System Ops"
        B --> B1[OS & Sys Modules]
        B --> B2[Subprocess Management]
        B --> B3[File & Directory Handling]
    end
    
    subgraph "Web & API Ops"
        C --> C1[HTTP Requests - requests]
        C --> C2[Web Scraping - BS4/lxml]
        C --> C3[REST APIs - GitHub/AWS/etc]
        C --> C4[Micro Services - Bottle/Tornado]
    end
    
    subgraph "Browser Ops"
        D --> D1[Selenium WebDriver]
        D --> D2[Browser Manipulation]
        D --> D3[Headless Automation]
    end
    
    style A fill:#306998,stroke:#ffe873,color:#fff
    style B fill:#4b8bbe,stroke:#306998,color:#fff
    style C fill:#4b8bbe,stroke:#306998,color:#fff
    style D fill:#4b8bbe,stroke:#306998,color:#fff
```

---

## 📂 Curriculum Topics

### 🟢 Beginner Fundamentals (Modules 1-17)

| # | Module | Description |
|---|--------|-------------|
| 01 | [Python Fundamentals](./01-Python-Fundamentals/README.md) | Variables, data types, control flow, PEP 8 |
| 02 | [Data Structures](./02-Data-Structures/README.md) | Lists, dicts, sets, tuples - choosing wisely |
| 03 | [Functions and Modules](./03-Functions-and-Modules/README.md) | Functions, imports, packages |
| 04 | [File Operations](./04-File-Operations/README.md) | Reading, writing, context managers |
| 05 | [Error Handling](./05-Error-Handling/README.md) | try/except, custom exceptions, retries |
| 06 | [Working with JSON](./06-Working-with-JSON/README.md) | Parsing, serialization, API data |
| 07 | [Working with YAML](./07-Working-with-YAML/README.md) | K8s manifests, Ansible configs |
| 08 | [Environment Variables](./08-Environment-Variables/README.md) | os.environ, python-dotenv, 12-factor |
| 09 | [Command Line Arguments](./09-Command-Line-Arguments/README.md) | argparse, CLI tool creation |
| 10 | [Subprocess Module](./10-Subprocess-Module/README.md) | Shell commands, output capture |
| 11 | [Pathlib Basics](./11-Pathlib-Basics/README.md) | Modern cross-platform paths |
| 12 | [Datetime Operations](./12-Datetime-Operations/README.md) | Timestamps, timezones, scheduling |
| 13 | [Regular Expressions](./13-Regular-Expressions/README.md) | Log parsing, pattern matching |
| 14 | [Logging Basics](./14-Logging-Basics/README.md) | Professional logging setup |
| 15 | [Virtual Environments](./15-Virtual-Environments/README.md) | Dependency isolation with venv |
| 16 | [Package Management](./16-Package-Management/README.md) | pip, requirements.txt |
| 17 | [First Automation Script](./17-First-Automation-Script/README.md) | Complete capstone project |

---

### 🌐 Web & API Topics

### 1. **[Working with the Web](./01-Working-with-the-Web.md)**
- **HTTP Requests**: Mastering GET/POST with the `requests` library.
- **Data Extraction**: Parsing HTML with `BeautifulSoup` and `lxml`.
- **API Integration**: Complete CRUD operations with GitHub REST API (Gists).

### 2. **[Web Automation & Selenium](./02-Web-Automation.md)**
- **Browser Control**: Spawning and controlling Firefox/Chrome/Safari.
- **Element Interaction**: Locating elements by ID, Name, and XPath.
- **Form Automation**: Handling logins and automated data entry.

### 3. **[Micro-Frameworks & Async Operations](./03-Micro-Frameworks-and-Async.md)**
- **Bottle**: Building single-file micro-services for automation dashboards.
- **Tornado**: High-performance, asynchronous web servers for concurrent tasks.
- **CRUD Workflows**: Implementing Create, Read, Update, Delete for internal tools.

---

## 🛠️ Essential DevOps Libraries Reference

| Library | Category | Use Case |
|---------|----------|----------|
| `os` / `sys` | System | Path manipulation, script arguments, env vars |
| `subprocess` | System | Running shell commands and capturing output |
| `requests` | Web | Making API calls and fetching web content |
| `beautifulsoup4` | Parsing | Extracting data from complex HTML structures |
| `selenium` | Automation | Browser-based task automation and testing |
| `bottle` | Web Apps | Lightweight internal status pages or web hooks |
| `tornado` | Async | Handling thousands of concurrent connections |

---

## 📖 Stories from the Field: The API Pivot
**Scenario**: A team was manually taking screenshots of 50 different monitoring dashboards every morning.
**Solution**: A Python script using `selenium` was written to log in, navigate through the dashboards, and save the screenshots automatically into a daily Slack channel.
**Outcome**: Saved 2 hours of engineering time daily and ensured consistency in reporting.

---

## ❓ Interview Questions
1. **Explain the difference between `os.system()` and `subprocess.run()`.**
2. **Why is `requests` preferred over `urllib2` for DevOps tasks?**
3. **What is an "Asynchronous" HTTP server and when should you use it?**

---

## 🧠 Quiz
1. Which module is used to parse HTML content? `(BeautifulSoup / lxml)`
2. What HTTP method is used to update a resource? `(PATCH / PUT)`
3. Which tool allows Python to interact with a physical browser? `(Selenium)`

---
**Next Step**: Start with **[Working with the Web](./01-Working-with-the-Web.md)**.
