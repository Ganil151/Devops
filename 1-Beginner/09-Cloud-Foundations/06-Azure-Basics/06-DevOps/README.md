# Azure DevOps

Comprehensive guide to Azure DevOps services including Pipelines, Repos, and deployment strategies.

## Azure DevOps Services
```yaml
Core Services:
  - Azure Repos: Git repositories
  - Azure Pipelines: CI/CD automation
  - Azure Boards: Work item tracking
  - Azure Test Plans: Testing tools
  - Azure Artifacts: Package management
```

## Azure Pipelines
```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build application'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

    - task: DotNetCoreCLI@2
      displayName: 'Run tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --collect "Code coverage"'

    - task: DotNetCoreCLI@2
      displayName: 'Publish application'
      inputs:
        command: 'publish'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'

    - task: PublishBuildArtifacts@1
      displayName: 'Publish artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop'

- stage: Deploy
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployToAzure
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Azure-Connection'
              appType: 'webApp'
              appName: 'mywebapp'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'
```

## Infrastructure as Code
```yaml
# ARM Template deployment
- task: AzureResourceManagerTemplateDeployment@3
  displayName: 'Deploy ARM Template'
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: 'Azure-Connection'
    subscriptionId: '$(subscriptionId)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: 'East US'
    templateLocation: 'Linked artifact'
    csmFile: 'infrastructure/template.json'
    csmParametersFile: 'infrastructure/parameters.json'
    deploymentMode: 'Incremental'
```

## Container Deployment
```yaml
# Docker build and push
- task: Docker@2
  displayName: 'Build and push Docker image'
  inputs:
    containerRegistry: 'myContainerRegistry'
    repository: 'myapp'
    command: 'buildAndPush'
    Dockerfile: '**/Dockerfile'
    tags: |
      $(Build.BuildId)
      latest

# Deploy to AKS
- task: KubernetesManifest@0
  displayName: 'Deploy to AKS'
  inputs:
    action: 'deploy'
    kubernetesServiceConnection: 'aks-connection'
    namespace: 'production'
    manifests: |
      k8s/deployment.yaml
      k8s/service.yaml
    containers: 'myregistry.azurecr.io/myapp:$(Build.BuildId)'
```

This guide covers Azure DevOps for continuous integration and deployment automation.

## Real World Scenarios

### Scenario 1: Automated Release gating
**Context:** You must not deploy to Production if there are High Severity bugs or if performance tests fail.
**Solution:**
- **Azure Pipelines (Release Gates):** Configure a "Gate" before the Prod stage.
- **Query Work Items:** Check for "Bug" with tag "Blocker".
- **Azure Monitor:** Check "Avg Response Time" < 200ms.
**Benefit:** Prevents bad code from reaching production automatically.

### Scenario 2: Infrastructure as Code (IaC)
**Context:** You need to deploy the exact same environment for Dev, Test, and Prod.
**Solution:**
- **Azure Repos:** Store Bicep/Terraform code.
- **Azure Pipelines:** Run `az deployment group create` (Bicep) or `terraform apply`.
**Benefit:** Idempotent, repeatable infrastructure. Removes manual errors.

---

## Interview Questions

### Basic Level
1. **What is Azure DevOps?**
   - A SaaS platform providing end-to-end DevOps tooling: Repos (Git), Pipelines (CI/CD), Boards (Planning), Test Plans, and Artifacts.
2. **What is a Pipeline?**
   - An automated process that builds, tests, and deploys code.
3. **What is CI/CD?**
   - **CI:** Continuous Integration (Build & Test on commit).
   - **CD:** Continuous Deployment/Delivery (Release to environments).

### Intermediate Level
4. **Explain "YAML Pipelines" vs "Classic Editor".**
   - **YAML:** Definitions stored as code in the repo. Version controlled. Modern standard.
   - **Classic:** GUI-based. Easier for beginners but harder to version control.
5. **What is an Azure Agent?**
   - The computing infrastructure (VM/Container) that runs the jobs in your pipeline. Can be Microsoft-hosted or Self-hosted.
6. **What are "Boards"?**
   - Agile project management tool (Kanban/Scrum boards) to track work items, bugs, and user stories.

### Advanced Level
7. **What is "Bicep"?**
   - A Domain Specific Language (DSL) for deploying Azure resources declaratively. It's a cleaner abstraction over ARM templates (JSON).
8. **How do you secure secrets in a Pipeline?**
   - Use **Variable Groups** linked to **Azure Key Vault**. Never hardcode secrets in YAML.
9. **Explain "Multi-stage Pipelines".**
   - A single YAML file defining the entire workflow from Build -> Test -> Deploy Dev -> Deploy Prod.
10. **What are "Service Connections"?**
   - Secure connections that allow Azure Pipelines to access external resources (like your Azure Subscription, Docker Hub, or SonarQube).

---

## Quiz: Azure DevOps

<details>
<summary><b>1. Which service hosts private Git repositories?</b></summary>
A) Azure Repos<br>
B) Azure Boards<br>
C) Azure Artifacts<br>
D) GitHub (External, but integrated)<br>
<br>
<b>Answer: A) Azure Repos</b>
</details>

<details>
<summary><b>2. Which service manages package dependencies (Maven, NuGet, npm)?</b></summary>
A) Azure Artifacts<br>
B) Azure Storage<br>
C) Azure Bins<br>
D) Docker Hub<br>
<br>
<b>Answer: A) Azure Artifacts</b>
</details>

<details>
<summary><b>3. CI stands for:</b></summary>
A) Continuous Integration<br>
B) Continuous Improvement<br>
C) Cloud Integration<br>
D) Code Inspection<br>
<br>
<b>Answer: A) Continuous Integration</b>
</details>

<details>
<summary><b>4. In YAML pipelines, the "trigger" section defines:</b></summary>
A) When the pipeline should run (e.g., commit to main)<br>
B) Who runs it<br>
C) The price<br>
D) The error<br>
<br>
<b>Answer: A) When the pipeline should run (e.g., commit to main)</b>
</details>

<details>
<summary><b>5. Microsoft-hosted agents provide:</b></summary>
A) A fresh VM for each job, managed by Microsoft<br>
B) Your own on-prem server<br>
C) A container<br>
D) A persistent VM<br>
<br>
<b>Answer: A) A fresh VM for each job, managed by Microsoft</b>
</details>

<details>
<summary><b>6. "Azure Boards" is most similar to:</b></summary>
A) Jira / Trello<br>
B) Jenkins<br>
C) Git<br>
D) Docker<br>
<br>
<b>Answer: A) Jira / Trello</b>
</details>

<details>
<summary><b>7. Why use Self-hosted agents?</b></summary>
A) To access resources inside a private network or require custom software caching<br>
B) It's always cheaper<br>
C) Microsoft ran out of agents<br>
D) It's mandatory<br>
<br>
<b>Answer: A) To access resources inside a private network or require custom software caching</b>
</details>

<details>
<summary><b>8. Bicep compiles (transpiles) into:</b></summary>
A) ARM Templates (JSON)<br>
B) Python<br>
C) C#<br>
D) Binary<br>
<br>
<b>Answer: A) ARM Templates (JSON)</b>
</details>

<details>
<summary><b>9. Which file is used for YAML pipeline definition by default?</b></summary>
A) azure-pipelines.yml<br>
B) build.json<br>
C) pipeline.xml<br>
D) Jenkinsfile<br>
<br>
<b>Answer: A) azure-pipelines.yml</b>
</details>

<details>
<summary><b>10. "Test Plans" allows you to:</b></summary>
A) Manage manual and automated testing efforts<br>
B) Write code<br>
C) Plan meetings<br>
D) Deploy apps<br>
<br>
<b>Answer: A) Manage manual and automated testing efforts</b>
</details>

<details>
<summary><b>11. Can Azure DevOps deploy to AWS?</b></summary>
A) Yes, using appropriate tasks/scripts<br>
B) No, only Azure<br>
<br>
<b>Answer: A) Yes, using appropriate tasks/scripts</b>
</details>

<details>
<summary><b>12. "Pull Request" validation builds ensure:</b></summary>
A) Code builds successfully before merging to main<br>
B) Code is deployed<br>
C) Code is deleted<br>
D) Nothing<br>
<br>
<b>Answer: A) Code builds successfully before merging to main</b>
</details>

<details>
<summary><b>13. "Variables" in pipelines allow:</b></summary>
A) Reusing values and configuration across the pipeline<br>
B) Math<br>
C) Randomness<br>
D) Storage<br>
<br>
<b>Answer: A) Reusing values and configuration across the pipeline</b>
</details>

<details>
<summary><b>14. "Approvals" in Release Pipelines:</b></summary>
A) Pause the pipeline until a human approves the deployment<br>
B) Auto-approve<br>
C) Are deprecated<br>
D) Do nothing<br>
<br>
<b>Answer: A) Pause the pipeline until a human approves the deployment</b>
</details>

<details>
<summary><b>15. Pipeline "Jobs" run:</b></summary>
A) On an Agent (Sequentially or Parallel)<br>
B) In the cloud ether<br>
C) On your phone<br>
D) Once a year<br>
<br>
<b>Answer: A) On an Agent (Sequentially or Parallel)</b>
</details>

<details>
<summary><b>16. "Artifacts" are:</b></summary>
A) Output files from a build (e.g., .zip, .jar) to be used in deployment<br>
B) Ancient relics<br>
C) Errors<br>
D) Source code<br>
<br>
<b>Answer: A) Output files from a build (e.g., .zip, .jar) to be used in deployment</b>
</details>

<details>
<summary><b>17. Which strategy deploys to a small subset of users first?</b></summary>
A) Canary Deployment<br>
B) Big Bang<br>
C) Rolling<br>
D) None<br>
<br>
<b>Answer: A) Canary Deployment</b>
</details>

<details>
<summary><b>18. Azure Repos supports:</b></summary>
A) Git and TFVC (Team Foundation Version Control)<br>
B) SVN<br>
C) Mercurial<br>
D) CVS<br>
<br>
<b>Answer: A) Git and TFVC (Team Foundation Version Control)</b>
</details>

<details>
<summary><b>19. Service Hooks allow:</b></summary>
A) Notifying external services (Slack, Teams) on DevOps events<br>
B) Fishing<br>
C) Coding<br>
D) Nothing<br>
<br>
<b>Answer: A) Notifying external services (Slack, Teams) on DevOps events</b>
</details>

<details>
<summary><b>20. "Environment" in YAML pipelines represents:</b></summary>
A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks<br>
B) The weather<br>
C) Variables<br>
D) Nothing<br>
<br>
<b>Answer: A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks</b>
</details>

<details>
<summary><b>21. Is Azure DevOps free?</b></summary>
A) Free tier available (First 5 users, limited minutes)<br>
B) No, 100% paid<br>
<br>
<b>Answer: A) Free tier available (First 5 users, limited minutes)</b>
</details>


## Real World Scenarios

### Scenario 1: Automated Release gating
**Context:** You must not deploy to Production if there are High Severity bugs or if performance tests fail.
**Solution:**
- **Azure Pipelines (Release Gates):** Configure a "Gate" before the Prod stage.
- **Query Work Items:** Check for "Bug" with tag "Blocker".
- **Azure Monitor:** Check "Avg Response Time" < 200ms.
**Benefit:** Prevents bad code from reaching production automatically.

### Scenario 2: Infrastructure as Code (IaC)
**Context:** You need to deploy the exact same environment for Dev, Test, and Prod.
**Solution:**
- **Azure Repos:** Store Bicep/Terraform code.
- **Azure Pipelines:** Run `az deployment group create` (Bicep) or `terraform apply`.
**Benefit:** Idempotent, repeatable infrastructure. Removes manual errors.

---

## Interview Questions

### Basic Level
1. **What is Azure DevOps?**
   - A SaaS platform providing end-to-end DevOps tooling: Repos (Git), Pipelines (CI/CD), Boards (Planning), Test Plans, and Artifacts.
2. **What is a Pipeline?**
   - An automated process that builds, tests, and deploys code.
3. **What is CI/CD?**
   - **CI:** Continuous Integration (Build & Test on commit).
   - **CD:** Continuous Deployment/Delivery (Release to environments).

### Intermediate Level
4. **Explain "YAML Pipelines" vs "Classic Editor".**
   - **YAML:** Definitions stored as code in the repo. Version controlled. Modern standard.
   - **Classic:** GUI-based. Easier for beginners but harder to version control.
5. **What is an Azure Agent?**
   - The computing infrastructure (VM/Container) that runs the jobs in your pipeline. Can be Microsoft-hosted or Self-hosted.
6. **What are "Boards"?**
   - Agile project management tool (Kanban/Scrum boards) to track work items, bugs, and user stories.

### Advanced Level
7. **What is "Bicep"?**
   - A Domain Specific Language (DSL) for deploying Azure resources declaratively. It's a cleaner abstraction over ARM templates (JSON).
8. **How do you secure secrets in a Pipeline?**
   - Use **Variable Groups** linked to **Azure Key Vault**. Never hardcode secrets in YAML.
9. **Explain "Multi-stage Pipelines".**
   - A single YAML file defining the entire workflow from Build -> Test -> Deploy Dev -> Deploy Prod.
10. **What are "Service Connections"?**
   - Secure connections that allow Azure Pipelines to access external resources (like your Azure Subscription, Docker Hub, or SonarQube).

---

## Quiz: Azure DevOps

<details>
<summary><b>1. Which service hosts private Git repositories?</b></summary>
A) Azure Repos<br>
B) Azure Boards<br>
C) Azure Artifacts<br>
D) GitHub (External, but integrated)<br>
<br>
<b>Answer: A) Azure Repos</b>
</details>

<details>
<summary><b>2. Which service manages package dependencies (Maven, NuGet, npm)?</b></summary>
A) Azure Artifacts<br>
B) Azure Storage<br>
C) Azure Bins<br>
D) Docker Hub<br>
<br>
<b>Answer: A) Azure Artifacts</b>
</details>

<details>
<summary><b>3. CI stands for:</b></summary>
A) Continuous Integration<br>
B) Continuous Improvement<br>
C) Cloud Integration<br>
D) Code Inspection<br>
<br>
<b>Answer: A) Continuous Integration</b>
</details>

<details>
<summary><b>4. In YAML pipelines, the "trigger" section defines:</b></summary>
A) When the pipeline should run (e.g., commit to main)<br>
B) Who runs it<br>
C) The price<br>
D) The error<br>
<br>
<b>Answer: A) When the pipeline should run (e.g., commit to main)</b>
</details>

<details>
<summary><b>5. Microsoft-hosted agents provide:</b></summary>
A) A fresh VM for each job, managed by Microsoft<br>
B) Your own on-prem server<br>
C) A container<br>
D) A persistent VM<br>
<br>
<b>Answer: A) A fresh VM for each job, managed by Microsoft</b>
</details>

<details>
<summary><b>6. "Azure Boards" is most similar to:</b></summary>
A) Jira / Trello<br>
B) Jenkins<br>
C) Git<br>
D) Docker<br>
<br>
<b>Answer: A) Jira / Trello</b>
</details>

<details>
<summary><b>7. Why use Self-hosted agents?</b></summary>
A) To access resources inside a private network or require custom software caching<br>
B) It's always cheaper<br>
C) Microsoft ran out of agents<br>
D) It's mandatory<br>
<br>
<b>Answer: A) To access resources inside a private network or require custom software caching</b>
</details>

<details>
<summary><b>8. Bicep compiles (transpiles) into:</b></summary>
A) ARM Templates (JSON)<br>
B) Python<br>
C) C#<br>
D) Binary<br>
<br>
<b>Answer: A) ARM Templates (JSON)</b>
</details>

<details>
<summary><b>9. Which file is used for YAML pipeline definition by default?</b></summary>
A) azure-pipelines.yml<br>
B) build.json<br>
C) pipeline.xml<br>
D) Jenkinsfile<br>
<br>
<b>Answer: A) azure-pipelines.yml</b>
</details>

<details>
<summary><b>10. "Test Plans" allows you to:</b></summary>
A) Manage manual and automated testing efforts<br>
B) Write code<br>
C) Plan meetings<br>
D) Deploy apps<br>
<br>
<b>Answer: A) Manage manual and automated testing efforts</b>
</details>

<details>
<summary><b>11. Can Azure DevOps deploy to AWS?</b></summary>
A) Yes, using appropriate tasks/scripts<br>
B) No, only Azure<br>
<br>
<b>Answer: A) Yes, using appropriate tasks/scripts</b>
</details>

<details>
<summary><b>12. "Pull Request" validation builds ensure:</b></summary>
A) Code builds successfully before merging to main<br>
B) Code is deployed<br>
C) Code is deleted<br>
D) Nothing<br>
<br>
<b>Answer: A) Code builds successfully before merging to main</b>
</details>

<details>
<summary><b>13. "Variables" in pipelines allow:</b></summary>
A) Reusing values and configuration across the pipeline<br>
B) Math<br>
C) Randomness<br>
D) Storage<br>
<br>
<b>Answer: A) Reusing values and configuration across the pipeline</b>
</details>

<details>
<summary><b>14. "Approvals" in Release Pipelines:</b></summary>
A) Pause the pipeline until a human approves the deployment<br>
B) Auto-approve<br>
C) Are deprecated<br>
D) Do nothing<br>
<br>
<b>Answer: A) Pause the pipeline until a human approves the deployment</b>
</details>

<details>
<summary><b>15. Pipeline "Jobs" run:</b></summary>
A) On an Agent (Sequentially or Parallel)<br>
B) In the cloud ether<br>
C) On your phone<br>
D) Once a year<br>
<br>
<b>Answer: A) On an Agent (Sequentially or Parallel)</b>
</details>

<details>
<summary><b>16. "Artifacts" are:</b></summary>
A) Output files from a build (e.g., .zip, .jar) to be used in deployment<br>
B) Ancient relics<br>
C) Errors<br>
D) Source code<br>
<br>
<b>Answer: A) Output files from a build (e.g., .zip, .jar) to be used in deployment</b>
</details>

<details>
<summary><b>17. Which strategy deploys to a small subset of users first?</b></summary>
A) Canary Deployment<br>
B) Big Bang<br>
C) Rolling<br>
D) None<br>
<br>
<b>Answer: A) Canary Deployment</b>
</details>

<details>
<summary><b>18. Azure Repos supports:</b></summary>
A) Git and TFVC (Team Foundation Version Control)<br>
B) SVN<br>
C) Mercurial<br>
D) CVS<br>
<br>
<b>Answer: A) Git and TFVC (Team Foundation Version Control)</b>
</details>

<details>
<summary><b>19. Service Hooks allow:</b></summary>
A) Notifying external services (Slack, Teams) on DevOps events<br>
B) Fishing<br>
C) Coding<br>
D) Nothing<br>
<br>
<b>Answer: A) Notifying external services (Slack, Teams) on DevOps events</b>
</details>

<details>
<summary><b>20. "Environment" in YAML pipelines represents:</b></summary>
A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks<br>
B) The weather<br>
C) Variables<br>
D) Nothing<br>
<br>
<b>Answer: A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks</b>
</details>

<details>
<summary><b>21. Is Azure DevOps free?</b></summary>
A) Free tier available (First 5 users, limited minutes)<br>
B) No, 100% paid<br>
<br>
<b>Answer: A) Free tier available (First 5 users, limited minutes)</b>
</details>