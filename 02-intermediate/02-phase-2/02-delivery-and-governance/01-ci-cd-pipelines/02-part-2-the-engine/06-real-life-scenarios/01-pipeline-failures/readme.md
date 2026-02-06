# Pipeline Failures and Recovery

Automation is only as good as its error handling. Learn from these real production failures to build robust, "Self-Healing" pipelines.

## 🏗️ Scenario: The "Zombie" Workspace
**The Crisis**: Jenkins builds started failing with "No Space Left on Device", even though the server had a 1TB disk.
**The Root Cause**: A pipeline was creating 20GB of temp files per build and never cleaning them up. Because the builds failed, the "RM" command at the end was never reached.
**The Solution**: Implemented a `post { always { cleanWs() } }` block in every Jenkinsfile.
**The Outcome**: Disk usage dropped to 5% and remained stable.

---

## 🏗️ Scenario: The "Plugin Conflict"
**The Crisis**: After updating the "GitHub" plugin, 500 pipelines stopped triggering on commits.
**The Root Cause**: The new version of the plugin required a newer version of the "Credentials" plugin, which was incompatible with the current Jenkins core version.
**The Solution**: Reverted to the previous plugin version and implemented a **Pre-Production Jenkins Server** to test all updates.
**The Outcome**: Future updates are now tested against a "Staging" Jenkins before hitting the production orchestrator.

---

## 🛡️ Safety Guards Boilerplate
Use this pattern to ensure your CI/CD server survives a bad build script.

```groovy
pipeline {
    agent any
    options {
        // 1. Timeout prevents "Hanging" builds from blocking agents
        timeout(time: 30, unit: 'MINUTES')
        
        // 2. Build Discarder prevents disk bloat
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // 3. Disable Concurrent Builds if resources are limited
        disableConcurrentBuilds()
    }
    stages {
        stage('Work') {
            steps {
                sh './risky_script.sh'
            }
        }
    }
    post {
        always {
            // 4. Force Cleanup even on Failure
            cleanWs()
        }
    }
}
```

---

## ❓ Interview Questions
1. **How do you monitor Jenkins health?**
   - *Answer*: Use the Prometheus/Grafana plugin to track queue length, build duration, and executor usage. Set alerts for high failure rates.
2. **What is a 'Cascading Failure' in CI/CD?**
   - *Answer*: When a failure in the build stage isn't caught, causing the pipeline to push broken code or artifacts to downstream stages, eventually taking down Production.
