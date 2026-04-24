# Azure Functions: Event-Driven Serverless Logic

Azure Functions is a serverless solution that allows you to write less code, maintain less infrastructure, and save on costs. Instead of worrying about deploying and maintaining servers, the cloud infrastructure provides all the up-to-date resources needed to keep your applications running.

## 🚀 The "DevOps Why": Agile Integration
Azure Functions excels in the Microsoft ecosystem due to its **Bindings** and **Triggers** system.
- **Seamless Integration**: Use "Bindings" to declaratively connect to services like CosmosDB, Service Bus, or Blob Storage without writing boilerplate SDK code.
- **Compute Scalability**: Automatically scales from zero to thousands of instances in response to event bursts.
- **Developer Flexibility**: Supports C#, Java, JavaScript, Python, and PowerShell.

---

## 🏗️ Core Mechanics

### 1. Hosting Plans
- **Consumption Plan**: The default serverless plan. Scalable, pay-per-execution.
- **Premium Plan**: Provides features like VNET connectivity, no cold start (pre-warmed instances), and longer execution durations.
- **Dedicated (App Service) Plan**: Run functions on dedicated VMs for predictable costs.

### 2. Triggers and Bindings
| Component | Purpose | Examples |
| :--- | :--- | :--- |
| **Trigger** | Defines *how* a function starts. | HTTP, Timer, Service Bus Queue. |
| **Input Binding** | Data the function *receives*. | Read a row from CosmosDB automatically. |
| **Output Binding** | Data the function *sends*. | Write a message to an SQS/Queue automatically. |

---

## 🛠️ Infrastructure as Code (Bicep)
Professional deployment using Azure Bicep:

```bicep
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'func-app-devops-001'
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
      ]
    }
  }
}
```

---

## 📂 Real-World Scenario: File Processing Pipeline
**Scenario**: A user uploads an image to **Azure Blob Storage**.
**The Solution**:
1. Global Event Grid detects the upload.
2. **Azure Function** is triggered.
3. The Function uses an **Input Binding** to read the image and an **Output Binding** to save a thumbnail back to another container.
4. Total infrastructure managed: **Zero**.
