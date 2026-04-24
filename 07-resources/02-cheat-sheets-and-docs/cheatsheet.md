# 08-cicd-pipelines

## 🛡️ Best Practices (Junior to Senior)

- **Build Once, Deploy Many**: Build a single artifact (JAR, Docker Image) and promote it through environments. Don't rebuild for Prod.
- **Fail Fast**: Run unit tests, linting, and security scans in the first stage.
- **Immutable Artifacts**: Tag artifacts with the Git SHA (e.g., `app:a1b2c3d`), never just `latest`.
- **Infrastructure as Code**: Define pipelines in code (`Jenkinsfile`, `.github/workflows`) stored in the repo.

---

## 🤵 Jenkinsfile (Declarative)

### Standard Pipeline Structure

```groovy
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'my-registry.com'
        IMAGE_NAME = "myapp:${GIT_COMMIT.take(7)}"
    }

    stages {
        stage('Build & Test') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t $IMAGE_NAME ."
            }
        }

        stage('Deploy Dev') {
            when { branch 'develop' }
            steps {
                sh './deploy.sh dev'
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
        failure {
            mail to: 'team@example.com', subject: 'Build Failed'
        }
    }
}
```

---

## 🐙 GitHub Actions

### Workflow Syntax

File: `.github/workflows/ci.yaml`

```yaml
name: CI Pipeline

on:
  push:
    branches: ['main']
  pull_request:
    branches: ['main']

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'maven'

      - name: Build with Maven
        run: mvn -B package --file pom.xml

      - name: Upload Artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-jar
          path: target/*.jar
```
