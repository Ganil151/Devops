# Jenkins Pipelines as Code
*Automating the Automation with Jenkinsfiles*

In the early days of Jenkins, CI/CD jobs were created using a point-and-click GUI (Freestyle Jobs). While simple, this approach was not scalable, version-controlled, or reproducible. **Pipelines as Code** changed everything by allowing engineers to define entire delivery workflows in a simple text file: the `Jenkinsfile`.

---

## 🏗️ The Pipeline Architecture
Modern Jenkins relies on **Declarative** and **Scripted** pipelines. Declarative is the industry standard for 99% of use cases due to its strict, readable syntax.

> **⚠️ Missing Image**: *Declarative Pipeline Lifecycle* ('../../../../../00-Resources/03-Images-Diagrams/declarative_pipeline_lifecycle.png')

### Why "As Code"?
| Feature | Legacy Jenkins (Freestyle) | Modern Jenkins (Pipeline) |
| :--- | :--- | :--- |
| **Config Type** | GUI-Based | Code-Based (`Jenkinsfile`) |
| **Version Control** | Not versioned easily | Stored in Git |
| **Logic** | Simple, linear tasks | Parallel, complex workflows |
| **Audit Trail** | Hard to track changes | Clear Git history |

---

## 🏗️ Declarative Pipeline Syntax
A Declarative Pipeline is wrapped in a `pipeline {}` block and follows a hierarchical structure:

```groovy
pipeline {
    agent any // Where to run the build
    
    environment {
        DB_USER = 'admin'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/example/repo.git'
            }
        }
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
        }
        success {
            echo 'Pipeline finished successfully!'
        }
    }
}
```

---

## 💡 Real-World Scenario: Automated Testing
Imagine a development team pushing code 50 times a day.
*   **Trigger**: A developer pushes a commit to the `main` branch.
*   **Process**: Jenkins detects the change, pulls the code, builds the Docker image, and runs a suite of 500 unit tests.
*   **Result**: If a single test fails, the pipeline stops, and the developer receives an immediate notification via Slack or Email. This ensures that "broken" code never reaches the user.

---

## 🛠️ Hands-On Challenge
1.  Navigate to the `CHALLENGES.md` file in this directory.
2.  Your task is to create a multi-stage `Jenkinsfile` that includes a "Static Analysis" stage using a simple shell echo.

---

## 🎤 Interview Preparation

### 1. What is a Jenkinsfile?
A text file that contains the definition of a Jenkins Pipeline and is checked into source control. It allows the pipeline to be versioned and reviewed like any other code.

### 2. Difference between Declarative and Scripted Pipelines?
Declarative uses a stricter, pre-defined structure (`pipeline {}`), making it easier to read and maintain. Scripted uses Groovy-based logic directly, providing more power but with higher complexity.

### 3. What is the purpose of the 'agent' directive?
It specifies where the pipeline (or a specific stage) will execute. `agent any` lets Jenkins decide, while `agent { label 'linux' }` forces it to run on a specific node.

### 4. How do 'post' actions work?
Segments of code that run at the end of a pipeline. Common blocks include `always`, `success`, `failure`, and `unstable`, allowing for cleanup or notifications.

### 5. Why use Pipelines as Code instead of Freestyle jobs?
Pipeline as Code allows for better scalability, version control, reusability, and handling of complex, non-linear workflows.

---

## 🎯 Next Steps
*   **[Boilerplate Template](./Boilerplates/SAMPLE_JENKINSFILE.txt)**: A production-ready template for your projects.
*   **[CI/CD Integrations](../05-Integrations-and-Plugins/README.md)**: Learning how to connect Jenkins to External Tools.
