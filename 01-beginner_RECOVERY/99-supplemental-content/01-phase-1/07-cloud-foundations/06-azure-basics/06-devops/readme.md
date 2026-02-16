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

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Repos</b>
</details>


<b>2. Which service manages package dependencies (Maven, NuGet, npm)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Artifacts</b>
</details>


<b>3. CI stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Continuous Integration</b>
</details>


<b>4. In YAML pipelines, the "trigger" section defines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) When the pipeline should run (e.g., commit to main)</b>
</details>


<b>5. Microsoft-hosted agents provide:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A fresh VM for each job, managed by Microsoft</b>
</details>


<b>6. "Azure Boards" is most similar to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Jira / Trello</b>
</details>


<b>7. Why use Self-hosted agents?</b>
<details>
<summary>Show Answer</summary>
Answer: A) To access resources inside a private network or require custom software caching</b>
</details>


<b>8. Bicep compiles (transpiles) into:</b>
<details>
<summary>Show Answer</summary>
Answer: A) ARM Templates (JSON)</b>
</details>


<b>9. Which file is used for YAML pipeline definition by default?</b>
<details>
<summary>Show Answer</summary>
Answer: A) azure-pipelines.yml</b>
</details>


<b>10. "Test Plans" allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Manage manual and automated testing efforts</b>
</details>


<b>11. Can Azure DevOps deploy to AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using appropriate tasks/scripts</b>
</details>


<b>12. "Pull Request" validation builds ensure:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Code builds successfully before merging to main</b>
</details>


<b>13. "Variables" in pipelines allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Reusing values and configuration across the pipeline</b>
</details>


<b>14. "Approvals" in Release Pipelines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Pause the pipeline until a human approves the deployment</b>
</details>


<b>15. Pipeline "Jobs" run:</b>
<details>
<summary>Show Answer</summary>
Answer: A) On an Agent (Sequentially or Parallel)</b>
</details>


<b>16. "Artifacts" are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Output files from a build (e.g., .zip, .jar) to be used in deployment</b>
</details>


<b>17. Which strategy deploys to a small subset of users first?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Canary Deployment</b>
</details>


<b>18. Azure Repos supports:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Git and TFVC (Team Foundation Version Control)</b>
</details>


<b>19. Service Hooks allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Notifying external services (Slack, Teams) on DevOps events</b>
</details>


<b>20. "Environment" in YAML pipelines represents:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks</b>
</details>


<b>21. Is Azure DevOps free?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Free tier available (First 5 users, limited minutes)</b>
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

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Repos</b>
</details>


<b>2. Which service manages package dependencies (Maven, NuGet, npm)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Artifacts</b>
</details>


<b>3. CI stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Continuous Integration</b>
</details>


<b>4. In YAML pipelines, the "trigger" section defines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) When the pipeline should run (e.g., commit to main)</b>
</details>


<b>5. Microsoft-hosted agents provide:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A fresh VM for each job, managed by Microsoft</b>
</details>


<b>6. "Azure Boards" is most similar to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Jira / Trello</b>
</details>


<b>7. Why use Self-hosted agents?</b>
<details>
<summary>Show Answer</summary>
Answer: A) To access resources inside a private network or require custom software caching</b>
</details>


<b>8. Bicep compiles (transpiles) into:</b>
<details>
<summary>Show Answer</summary>
Answer: A) ARM Templates (JSON)</b>
</details>


<b>9. Which file is used for YAML pipeline definition by default?</b>
<details>
<summary>Show Answer</summary>
Answer: A) azure-pipelines.yml</b>
</details>


<b>10. "Test Plans" allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Manage manual and automated testing efforts</b>
</details>


<b>11. Can Azure DevOps deploy to AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using appropriate tasks/scripts</b>
</details>


<b>12. "Pull Request" validation builds ensure:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Code builds successfully before merging to main</b>
</details>


<b>13. "Variables" in pipelines allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Reusing values and configuration across the pipeline</b>
</details>


<b>14. "Approvals" in Release Pipelines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Pause the pipeline until a human approves the deployment</b>
</details>


<b>15. Pipeline "Jobs" run:</b>
<details>
<summary>Show Answer</summary>
Answer: A) On an Agent (Sequentially or Parallel)</b>
</details>


<b>16. "Artifacts" are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Output files from a build (e.g., .zip, .jar) to be used in deployment</b>
</details>


<b>17. Which strategy deploys to a small subset of users first?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Canary Deployment</b>
</details>


<b>18. Azure Repos supports:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Git and TFVC (Team Foundation Version Control)</b>
</details>


<b>19. Service Hooks allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Notifying external services (Slack, Teams) on DevOps events</b>
</details>


<b>20. "Environment" in YAML pipelines represents:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A collection of resources to target (e.g., "Production", "Staging") with gates/checks</b>
</details>


<b>21. Is Azure DevOps free?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Free tier available (First 5 users, limited minutes)</b>
</details>
