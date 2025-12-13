# ML Infrastructure

## Overview

ML Infrastructure encompasses the compute, storage, networking, and orchestration components required to support machine learning workloads from development to production.

## Compute Infrastructure

### GPU Clusters
```yaml
# gpu-node-pool.yaml
apiVersion: v1
kind: Node
metadata:
  name: gpu-node
  labels:
    accelerator: nvidia-tesla-v100
spec:
  capacity:
    nvidia.com/gpu: "4"
  allocatable:
    nvidia.com/gpu: "4"
```

### CPU Optimization
```python
# cpu_optimization.py
import multiprocessing as mp
from concurrent.futures import ProcessPoolExecutor

class CPUOptimizedTraining:
    def __init__(self, n_jobs=None):
        self.n_jobs = n_jobs or mp.cpu_count()
    
    def parallel_training(self, data_chunks):
        with ProcessPoolExecutor(max_workers=self.n_jobs) as executor:
            futures = [executor.submit(self.train_chunk, chunk) for chunk in data_chunks]
            results = [future.result() for future in futures]
        return results
```

## Storage Systems

### Data Lake Architecture
```python
# data_lake.py
import boto3
from pathlib import Path

class DataLake:
    def __init__(self, bucket_name):
        self.s3 = boto3.client('s3')
        self.bucket = bucket_name
    
    def store_raw_data(self, data, partition_key):
        key = f"raw/{partition_key}/{data.name}"
        self.s3.upload_file(data, self.bucket, key)
    
    def store_processed_data(self, data, version):
        key = f"processed/v{version}/{data.name}"
        self.s3.upload_file(data, self.bucket, key)
    
    def store_model_artifacts(self, model_path, model_name, version):
        key = f"models/{model_name}/v{version}/model.pkl"
        self.s3.upload_file(model_path, self.bucket, key)
```

### Feature Store
```python
# feature_store.py
import pandas as pd
from datetime import datetime

class FeatureStore:
    def __init__(self, backend):
        self.backend = backend
    
    def register_feature_group(self, name, schema, description):
        feature_group = {
            'name': name,
            'schema': schema,
            'description': description,
            'created_at': datetime.now()
        }
        self.backend.create_table(name, schema)
        return feature_group
    
    def write_features(self, feature_group_name, features_df):
        self.backend.insert_data(feature_group_name, features_df)
    
    def read_features(self, feature_group_name, feature_names=None, filters=None):
        return self.backend.query_data(feature_group_name, feature_names, filters)
```

## Container Orchestration

### Kubernetes for ML
```yaml
# ml-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ml-workloads
  labels:
    name: ml-workloads
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ml-quota
  namespace: ml-workloads
spec:
  hard:
    requests.cpu: "100"
    requests.memory: 200Gi
    requests.nvidia.com/gpu: "10"
    limits.cpu: "200"
    limits.memory: 400Gi
    limits.nvidia.com/gpu: "10"
```

### Training Job Template
```yaml
# training-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ml-training-job
  namespace: ml-workloads
spec:
  template:
    spec:
      containers:
      - name: trainer
        image: ml-trainer:latest
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: "8Gi"
            cpu: "4"
          limits:
            nvidia.com/gpu: 1
            memory: "16Gi"
            cpu: "8"
        env:
        - name: CUDA_VISIBLE_DEVICES
          value: "0"
        volumeMounts:
        - name: data-volume
          mountPath: /data
        - name: model-volume
          mountPath: /models
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: ml-data-pvc
      - name model-volume
        persistentVolumeClaim:
          claimName: ml-models-pvc
      restartPolicy: Never
```

## Distributed Training

### Multi-GPU Training
```python
# distributed_training.py
import torch
import torch.distributed as dist
import torch.multiprocessing as mp
from torch.nn.parallel import DistributedDataParallel

def setup_distributed(rank, world_size):
    dist.init_process_group("nccl", rank=rank, world_size=world_size)
    torch.cuda.set_device(rank)

def train_distributed(rank, world_size, model, dataset):
    setup_distributed(rank, world_size)
    
    model = model.to(rank)
    model = DistributedDataParallel(model, device_ids=[rank])
    
    sampler = torch.utils.data.distributed.DistributedSampler(
        dataset, num_replicas=world_size, rank=rank
    )
    
    dataloader = torch.utils.data.DataLoader(
        dataset, batch_size=32, sampler=sampler
    )
    
    optimizer = torch.optim.Adam(model.parameters())
    
    for epoch in range(10):
        for batch in dataloader:
            optimizer.zero_grad()
            loss = model(batch)
            loss.backward()
            optimizer.step()

def main():
    world_size = torch.cuda.device_count()
    mp.spawn(train_distributed, args=(world_size, model, dataset), nprocs=world_size)
```

### Horovod Integration
```python
# horovod_training.py
import horovod.torch as hvd
import torch

def train_with_horovod():
    hvd.init()
    torch.cuda.set_device(hvd.local_rank())
    
    model = MyModel()
    optimizer = torch.optim.SGD(model.parameters(), lr=0.01 * hvd.size())
    optimizer = hvd.DistributedOptimizer(optimizer)
    
    hvd.broadcast_parameters(model.state_dict(), root_rank=0)
    hvd.broadcast_optimizer_state(optimizer, root_rank=0)
    
    for epoch in range(epochs):
        for batch in dataloader:
            optimizer.zero_grad()
            loss = model(batch)
            loss.backward()
            optimizer.step()
```

## Workflow Orchestration

### Apache Airflow for ML
```python
# ml_workflow.py
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.kubernetes_pod_operator import KubernetesPodOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'ml-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'ml_training_pipeline',
    default_args=default_args,
    description='ML Training Pipeline',
    schedule_interval='@daily'
)

data_extraction = KubernetesPodOperator(
    task_id='extract_data',
    name='data-extraction',
    namespace='ml-workloads',
    image='data-extractor:latest',
    dag=dag
)

feature_engineering = KubernetesPodOperator(
    task_id='feature_engineering',
    name='feature-engineering',
    namespace='ml-workloads',
    image='feature-engineer:latest',
    dag=dag
)

model_training = KubernetesPodOperator(
    task_id='train_model',
    name='model-training',
    namespace='ml-workloads',
    image='model-trainer:latest',
    resources={
        'request_memory': '8Gi',
        'request_cpu': '4',
        'limit_memory': '16Gi',
        'limit_cpu': '8'
    },
    dag=dag
)

data_extraction >> feature_engineering >> model_training
```

### Kubeflow Pipelines
```python
# kubeflow_pipeline.py
import kfp
from kfp import dsl

@dsl.component
def data_preprocessing_op(input_path: str, output_path: str):
    return dsl.ContainerOp(
        name='Data Preprocessing',
        image='data-preprocessor:latest',
        arguments=['--input', input_path, '--output', output_path]
    )

@dsl.component
def model_training_op(data_path: str, model_path: str):
    return dsl.ContainerOp(
        name='Model Training',
        image='model-trainer:latest',
        arguments=['--data', data_path, '--model', model_path]
    )

@dsl.pipeline(
    name='ML Training Pipeline',
    description='End-to-end ML training pipeline'
)
def ml_pipeline(input_data_path: str):
    preprocessing_task = data_preprocessing_op(input_data_path, '/tmp/processed_data')
    training_task = model_training_op(preprocessing_task.output, '/tmp/model')
    
    return training_task

if __name__ == '__main__':
    kfp.compiler.Compiler().compile(ml_pipeline, 'ml_pipeline.yaml')
```

## Infrastructure as Code

### Terraform for ML Infrastructure
```hcl
# ml_infrastructure.tf
resource "aws_eks_cluster" "ml_cluster" {
  name     = "ml-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.21"

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "gpu_nodes" {
  cluster_name    = aws_eks_cluster.ml_cluster.name
  node_group_name = "gpu-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["p3.2xlarge"]
  ami_type       = "AL2_x86_64_GPU"

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/ml-cluster" = "owned"
  }
}

resource "aws_s3_bucket" "ml_data_lake" {
  bucket = "company-ml-data-lake"
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    enabled = true
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
```

## Monitoring and Observability

### Prometheus Metrics for ML
```python
# ml_metrics.py
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time

# Define metrics
model_predictions_total = Counter('ml_model_predictions_total', 'Total predictions made')
model_prediction_duration = Histogram('ml_model_prediction_duration_seconds', 'Prediction duration')
model_accuracy = Gauge('ml_model_accuracy', 'Current model accuracy')
gpu_utilization = Gauge('ml_gpu_utilization_percent', 'GPU utilization percentage')

class MLMetrics:
    def __init__(self):
        start_http_server(8000)
    
    def record_prediction(self, duration):
        model_predictions_total.inc()
        model_prediction_duration.observe(duration)
    
    def update_accuracy(self, accuracy):
        model_accuracy.set(accuracy)
    
    def update_gpu_utilization(self, utilization):
        gpu_utilization.set(utilization)
```

### Grafana Dashboard Configuration
```json
{
  "dashboard": {
    "title": "ML Infrastructure Dashboard",
    "panels": [
      {
        "title": "Model Predictions Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ml_model_predictions_total[5m])",
            "legendFormat": "Predictions/sec"
          }
        ]
      },
      {
        "title": "GPU Utilization",
        "type": "singlestat",
        "targets": [
          {
            "expr": "ml_gpu_utilization_percent",
            "legendFormat": "GPU %"
          }
        ]
      }
    ]
  }
}
```

## Cost Optimization

### Spot Instance Management
```python
# spot_instance_manager.py
import boto3

class SpotInstanceManager:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.autoscaling = boto3.client('autoscaling')
    
    def create_spot_fleet(self, config):
        response = self.ec2.request_spot_fleet(
            SpotFleetRequestConfig={
                'IamFleetRole': config['iam_role'],
                'AllocationStrategy': 'diversified',
                'TargetCapacity': config['target_capacity'],
                'SpotPrice': config['max_price'],
                'LaunchSpecifications': config['launch_specs']
            }
        )
        return response['SpotFleetRequestId']
    
    def handle_spot_interruption(self, instance_id):
        # Gracefully handle spot instance interruption
        self.drain_workloads(instance_id)
        self.request_replacement_capacity()
```

### Auto-scaling Policies
```yaml
# cluster-autoscaler.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/ml-cluster
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

## Security and Compliance

### Network Security
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ml-workload-policy
  namespace: ml-workloads
spec:
  podSelector:
    matchLabels:
      app: ml-training
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ml-workloads
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: data-storage
    ports:
    - protocol: TCP
      port: 443
```

### Secrets Management
```python
# secrets_manager.py
import boto3
import json

class SecretsManager:
    def __init__(self):
        self.client = boto3.client('secretsmanager')
    
    def store_model_credentials(self, secret_name, credentials):
        self.client.create_secret(
            Name=secret_name,
            SecretString=json.dumps(credentials)
        )
    
    def get_model_credentials(self, secret_name):
        response = self.client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
```

## Disaster Recovery

### Backup Strategy
```python
# backup_strategy.py
import boto3
from datetime import datetime

class MLBackupManager:
    def __init__(self):
        self.s3 = boto3.client('s3')
    
    def backup_model_artifacts(self, source_bucket, backup_bucket):
        # Cross-region replication for model artifacts
        objects = self.s3.list_objects_v2(Bucket=source_bucket)
        
        for obj in objects.get('Contents', []):
            copy_source = {'Bucket': source_bucket, 'Key': obj['Key']}
            backup_key = f"backup/{datetime.now().strftime('%Y-%m-%d')}/{obj['Key']}"
            
            self.s3.copy_object(
                CopySource=copy_source,
                Bucket=backup_bucket,
                Key=backup_key
            )
    
    def restore_from_backup(self, backup_bucket, restore_bucket, backup_date):
        prefix = f"backup/{backup_date}/"
        objects = self.s3.list_objects_v2(Bucket=backup_bucket, Prefix=prefix)
        
        for obj in objects.get('Contents', []):
            original_key = obj['Key'].replace(prefix, '')
            copy_source = {'Bucket': backup_bucket, 'Key': obj['Key']}
            
            self.s3.copy_object(
                CopySource=copy_source,
                Bucket=restore_bucket,
                Key=original_key
            )
```

## Best Practices

1. **Resource Management**: Use resource quotas and limits
2. **Auto-scaling**: Implement both horizontal and vertical scaling
3. **Cost Optimization**: Use spot instances and reserved capacity
4. **Security**: Implement network policies and secrets management
5. **Monitoring**: Comprehensive observability across all components
6. **Backup**: Regular backups of models and data
7. **Documentation**: Maintain infrastructure documentation
8. **Testing**: Test disaster recovery procedures regularly

## Conclusion

ML Infrastructure requires careful planning and implementation of scalable, secure, and cost-effective systems. Success depends on choosing the right tools and architectures for your specific ML workloads while maintaining operational excellence.