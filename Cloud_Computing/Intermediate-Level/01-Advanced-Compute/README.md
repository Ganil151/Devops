# Advanced Compute Services

Comprehensive guide to advanced compute services including containers, serverless, and high-availability architectures across major cloud platforms.

## Container Services

### AWS Container Services

#### Amazon ECS (Elastic Container Service)
```yaml
# ECS Task Definition
{
  "family": "web-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "web-container",
      "image": "nginx:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/web-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### Amazon EKS (Elastic Kubernetes Service)
```yaml
# EKS Cluster Configuration
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: production-cluster
  region: us-east-1
  version: "1.28"

nodeGroups:
  - name: worker-nodes
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 1
    maxSize: 5
    volumeSize: 20
    ssh:
      allow: true
      publicKeyName: my-key-pair

addons:
  - name: vpc-cni
  - name: coredns
  - name: kube-proxy
  - name: aws-load-balancer-controller
```

### Azure Container Services

#### Azure Container Instances (ACI)
```yaml
# ACI Deployment Template
apiVersion: 2019-12-01
location: East US
name: web-app-container
properties:
  containers:
  - name: web-app
    properties:
      image: nginx:latest
      resources:
        requests:
          cpu: 1
          memoryInGb: 1.5
      ports:
      - port: 80
        protocol: TCP
  osType: Linux
  restartPolicy: Always
  ipAddress:
    type: Public
    ports:
    - protocol: TCP
      port: 80
```

#### Azure Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --node-vm-size Standard_D2s_v3 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --network-plugin azure \
  --service-cidr 10.0.0.0/16 \
  --dns-service-ip 10.0.0.10

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### Google Cloud Container Services

#### Google Kubernetes Engine (GKE)
```yaml
# GKE Cluster Configuration
apiVersion: container.v1
kind: Cluster
name: production-cluster
location: us-central1
initialNodeCount: 3
nodeConfig:
  machineType: e2-medium
  diskSizeGb: 100
  oauthScopes:
  - https://www.googleapis.com/auth/cloud-platform
addonsConfig:
  httpLoadBalancing:
    disabled: false
  horizontalPodAutoscaling:
    disabled: false
networkPolicy:
  enabled: true
```

#### Cloud Run
```yaml
# Cloud Run Service
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: web-app
  annotations:
    run.googleapis.com/ingress: all
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "100"
        run.googleapis.com/cpu-throttling: "false"
    spec:
      containerConcurrency: 80
      containers:
      - image: gcr.io/project-id/web-app:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 1000m
            memory: 512Mi
        env:
        - name: NODE_ENV
          value: production
```

## Serverless Computing

### AWS Lambda
```python
# Lambda Function Example
import json
import boto3

def lambda_handler(event, context):
    # Process the event
    s3 = boto3.client('s3')
    
    try:
        # Extract bucket and key from event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        # Process the file
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read()
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully processed {key}',
                'size': len(content)
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
```

### Azure Functions
```csharp
// Azure Function Example
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

public static class ProcessData
{
    [FunctionName("ProcessData")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
        [Blob("processed/{rand-guid}.json", FileAccess.Write)] Stream outputBlob,
        ILogger log)
    {
        log.LogInformation("Processing data request");
        
        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        var data = JsonConvert.DeserializeObject(requestBody);
        
        // Process data
        var processedData = ProcessBusinessLogic(data);
        
        // Write to blob storage
        using (var writer = new StreamWriter(outputBlob))
        {
            await writer.WriteAsync(JsonConvert.SerializeObject(processedData));
        }
        
        return new OkObjectResult(new { message = "Data processed successfully" });
    }
}
```

### Google Cloud Functions
```javascript
// Cloud Function Example
const functions = require('@google-cloud/functions-framework');
const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

functions.cloudEvent('processFile', async (cloudEvent) => {
  const file = cloudEvent.data;
  
  console.log(`Processing file: ${file.name}`);
  console.log(`Bucket: ${file.bucket}`);
  
  try {
    // Download file
    const bucket = storage.bucket(file.bucket);
    const fileObj = bucket.file(file.name);
    const [contents] = await fileObj.download();
    
    // Process file contents
    const processedData = processData(contents);
    
    // Upload processed file
    const processedFileName = `processed/${file.name}`;
    const processedFile = bucket.file(processedFileName);
    
    await processedFile.save(JSON.stringify(processedData), {
      metadata: {
        contentType: 'application/json'
      }
    });
    
    console.log(`File processed and saved as: ${processedFileName}`);
  } catch (error) {
    console.error('Error processing file:', error);
    throw error;
  }
});
```

## Auto-Scaling and High Availability

### AWS Auto Scaling
```json
{
  "AutoScalingGroupName": "web-app-asg",
  "LaunchTemplate": {
    "LaunchTemplateId": "lt-12345678",
    "Version": "$Latest"
  },
  "MinSize": 2,
  "MaxSize": 10,
  "DesiredCapacity": 3,
  "DefaultCooldown": 300,
  "AvailabilityZones": [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ],
  "TargetGroupARNs": [
    "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/web-app-tg/1234567890123456"
  ],
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 300,
  "Tags": [
    {
      "Key": "Name",
      "Value": "web-app-instance",
      "PropagateAtLaunch": true
    }
  ]
}
```

### Azure Virtual Machine Scale Sets
```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2021-03-01",
  "name": "web-app-vmss",
  "location": "East US",
  "sku": {
    "name": "Standard_D2s_v3",
    "tier": "Standard",
    "capacity": 3
  },
  "properties": {
    "upgradePolicy": {
      "mode": "Rolling",
      "rollingUpgradePolicy": {
        "maxBatchInstancePercent": 20,
        "maxUnhealthyInstancePercent": 20,
        "maxUnhealthyUpgradedInstancePercent": 20,
        "pauseTimeBetweenBatches": "PT5M"
      }
    },
    "virtualMachineProfile": {
      "osProfile": {
        "computerNamePrefix": "webapp",
        "adminUsername": "azureuser",
        "linuxConfiguration": {
          "disablePasswordAuthentication": true,
          "ssh": {
            "publicKeys": [
              {
                "path": "/home/azureuser/.ssh/authorized_keys",
                "keyData": "ssh-rsa AAAAB3NzaC1yc2E..."
              }
            ]
          }
        }
      },
      "storageProfile": {
        "imageReference": {
          "publisher": "Canonical",
          "offer": "0001-com-ubuntu-server-focal",
          "sku": "20_04-lts-gen2",
          "version": "latest"
        }
      },
      "networkProfile": {
        "networkInterfaceConfigurations": [
          {
            "name": "webapp-nic",
            "properties": {
              "primary": true,
              "ipConfigurations": [
                {
                  "name": "internal",
                  "properties": {
                    "subnet": {
                      "id": "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
                    },
                    "loadBalancerBackendAddressPools": [
                      {
                        "id": "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Network/loadBalancers/lb/backendAddressPools/pool"
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
```

### Google Cloud Managed Instance Groups
```yaml
# Instance Template
apiVersion: compute/v1
kind: InstanceTemplate
name: web-app-template
properties:
  machineType: e2-medium
  disks:
  - boot: true
    initializeParams:
      sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts
  networkInterfaces:
  - network: projects/project-id/global/networks/default
    accessConfigs:
    - type: ONE_TO_ONE_NAT
  metadata:
    items:
    - key: startup-script
      value: |
        #!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
        systemctl enable nginx

---
# Managed Instance Group
apiVersion: compute/v1
kind: InstanceGroupManager
name: web-app-mig
zone: us-central1-a
baseInstanceName: web-app
instanceTemplate: projects/project-id/global/instanceTemplates/web-app-template
targetSize: 3
autoHealingPolicies:
- healthCheck: projects/project-id/global/healthChecks/web-app-hc
  initialDelaySec: 300
```

## Performance Optimization

### Compute Optimization Strategies
```yaml
# AWS EC2 Instance Types Selection
compute_optimization:
  general_purpose:
    - t3.micro    # Burstable, low baseline
    - t3.small    # Burstable, moderate baseline
    - m5.large    # Balanced compute, memory, networking
  
  compute_optimized:
    - c5.large    # High-performance processors
    - c5n.large   # Enhanced networking
  
  memory_optimized:
    - r5.large    # Memory-intensive applications
    - x1e.large   # High memory-to-vCPU ratio
  
  storage_optimized:
    - i3.large    # NVMe SSD-backed instance storage
    - d2.large    # Dense HDD storage

# Right-sizing recommendations
right_sizing:
  cpu_utilization: "Target 70-80% average"
  memory_utilization: "Target 80-90% average"
  network_utilization: "Monitor bandwidth requirements"
  storage_iops: "Match application requirements"
```

### Container Optimization
```dockerfile
# Multi-stage Docker build for optimization
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:16-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

This comprehensive guide covers advanced compute services essential for modern cloud architectures and scalable application deployment.