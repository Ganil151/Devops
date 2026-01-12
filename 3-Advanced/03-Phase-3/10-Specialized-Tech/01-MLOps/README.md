# MLOps: Machine Learning Operations

Complete guide to deploying, monitoring, and maintaining machine learning models in production using DevOps practices.

---

## 📊 What is MLOps?

**MLOps** (Machine Learning Operations) is the practice of applying DevOps principles to machine learning systems. It combines ML, DevOps, and Data Engineering to deploy and maintain ML models in production reliably and efficiently.

### Why MLOps Matters

- **Model Deployment**: 87% of ML models never make it to production
- **Model Drift**: Production models degrade over time without monitoring
- **Reproducibility**: Experiments must be reproducible for compliance
- **Scalability**: Models need to handle production traffic
- **Collaboration**: Data scientists, ML engineers, and DevOps must work together

---

## 🔄 MLOps Lifecycle

### 1. Data Management
- **Data Versioning**: Track datasets like code (DVC, LakeFS)
- **Data Quality**: Validate and monitor data quality
- **Feature Store**: Centralized feature management
- **Data Lineage**: Track data transformations

**Tools**:
- [DVC](https://dvc.org) - Data Version Control
- [LakeFS](https://lakefs.io) - Git for data lakes
- [Great Expectations](https://greatexpectations.io) - Data validation
- [Feast](https://feast.dev) - Feature store

---

### 2. Model Development
- **Experiment Tracking**: Log parameters, metrics, artifacts
- **Model Versioning**: Version models like code
- **Hyperparameter Tuning**: Automated optimization
- **Notebook Management**: Reproducible notebooks

**Tools**:
- [MLflow](https://mlflow.org) - End-to-end ML platform
- [Weights & Biases](https://wandb.ai) - Experiment tracking
- [Neptune.ai](https://neptune.ai) - Metadata store
- [Kubeflow](https://www.kubeflow.org) - ML on Kubernetes

---

### 3. Model Training
- **Distributed Training**: Scale across multiple GPUs/nodes
- **Training Pipelines**: Automated, reproducible training
- **Resource Management**: Efficient GPU/CPU allocation
- **Cost Optimization**: Spot instances for training

**Infrastructure**:
```yaml
# Kubernetes Job for Model Training
apiVersion: batch/v1
kind: Job
metadata:
  name: model-training
spec:
  template:
    spec:
      containers:
      - name: trainer
        image: ml-training:v1
        resources:
          limits:
            nvidia.com/gpu: 2
        env:
        - name: MLFLOW_TRACKING_URI
          value: "http://mlflow:5000"
```

**Tools**:
- [Ray](https://www.ray.io) - Distributed computing
- [Horovod](https://horovod.ai) - Distributed deep learning
- [Kubeflow Training Operator](https://www.kubeflow.org/docs/components/training/) - K8s training jobs

---

### 4. Model Deployment

#### Deployment Patterns

**1. Batch Prediction**
- Process data in batches (hourly, daily)
- Lower latency requirements
- Cost-effective for large datasets

**2. Real-Time API**
- REST/gRPC endpoints
- Low latency (<100ms)
- Auto-scaling based on traffic

**3. Streaming**
- Process data streams (Kafka, Kinesis)
- Near real-time predictions
- Event-driven architecture

**4. Edge Deployment**
- Deploy to edge devices (mobile, IoT)
- Offline inference
- Model optimization (quantization, pruning)

#### Serving Frameworks

| Framework | Best For | Features |
|-----------|----------|----------|
| **[TensorFlow Serving](https://www.tensorflow.org/tfx/guide/serving)** | TensorFlow models | High performance, model versioning |
| **[TorchServe](https://pytorch.org/serve/)** | PyTorch models | Multi-model serving, metrics |
| **[Seldon Core](https://www.seldon.io)** | Kubernetes | A/B testing, canary deployments |
| **[KServe](https://kserve.github.io)** | Kubernetes | Serverless, auto-scaling |
| **[BentoML](https://www.bentoml.com)** | Any framework | Easy packaging, deployment |

**Example: KServe Deployment**
```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-iris
spec:
  predictor:
    sklearn:
      storageUri: "gs://kfserving-examples/models/sklearn/iris"
      resources:
        limits:
          cpu: "1"
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 1Gi
```

---

### 5. Model Monitoring

#### What to Monitor

**1. Model Performance**
- Accuracy, precision, recall
- Latency (p50, p95, p99)
- Throughput (requests/second)

**2. Data Drift**
- Input distribution changes
- Feature drift detection
- Concept drift

**3. Model Drift**
- Performance degradation over time
- Prediction distribution changes

**4. Infrastructure**
- CPU/GPU utilization
- Memory usage
- Error rates

**Tools**:
- [Evidently AI](https://evidentlyai.com) - ML monitoring
- [Arize AI](https://arize.com) - ML observability
- [Fiddler](https://www.fiddler.ai) - Model performance
- [WhyLabs](https://whylabs.ai) - Data quality monitoring

**Example: Prometheus Metrics**
```python
from prometheus_client import Counter, Histogram

prediction_counter = Counter('model_predictions_total', 'Total predictions')
prediction_latency = Histogram('model_prediction_latency_seconds', 'Prediction latency')

@prediction_latency.time()
def predict(data):
    prediction_counter.inc()
    return model.predict(data)
```

---

### 6. Model Retraining

**Triggers for Retraining**:
- Scheduled (weekly, monthly)
- Performance degradation
- Data drift detected
- New data available

**Automated Retraining Pipeline**:
```python
# Airflow DAG for Model Retraining
from airflow import DAG
from airflow.operators.python import PythonOperator

dag = DAG('model_retraining', schedule_interval='@weekly')

extract_data = PythonOperator(task_id='extract', python_callable=extract_fn)
validate_data = PythonOperator(task_id='validate', python_callable=validate_fn)
train_model = PythonOperator(task_id='train', python_callable=train_fn)
evaluate_model = PythonOperator(task_id='evaluate', python_callable=evaluate_fn)
deploy_model = PythonOperator(task_id='deploy', python_callable=deploy_fn)

extract_data >> validate_data >> train_model >> evaluate_model >> deploy_model
```

---

## 🏗️ MLOps Architecture

### Reference Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Data Sources                             │
│  (Databases, APIs, Data Lakes, Streaming)                   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  Data Pipeline                               │
│  (Airflow, Prefect, Dagster)                                │
│  • Data Extraction                                           │
│  • Data Validation                                           │
│  • Feature Engineering                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  Feature Store                               │
│  (Feast, Tecton, Hopsworks)                                 │
│  • Online Features (low latency)                            │
│  • Offline Features (training)                              │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Model Training                                  │
│  (Kubeflow, MLflow, Vertex AI)                              │
│  • Experiment Tracking                                       │
│  • Hyperparameter Tuning                                     │
│  • Distributed Training                                      │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Model Registry                                  │
│  (MLflow, Vertex AI, SageMaker)                             │
│  • Model Versioning                                          │
│  • Model Metadata                                            │
│  • Model Approval Workflow                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Model Serving                                   │
│  (KServe, Seldon, TorchServe)                               │
│  • A/B Testing                                               │
│  • Canary Deployments                                        │
│  • Auto-scaling                                              │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Monitoring & Observability                      │
│  (Prometheus, Grafana, Evidently)                           │
│  • Model Performance                                         │
│  • Data Drift                                                │
│  • Infrastructure Metrics                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ MLOps Tech Stack

### Complete Stack Example

**Infrastructure**:
- **Kubernetes**: Container orchestration
- **Terraform**: Infrastructure as Code
- **ArgoCD**: GitOps for ML pipelines

**Data**:
- **DVC**: Data versioning
- **Feast**: Feature store
- **Great Expectations**: Data validation

**Training**:
- **Kubeflow**: ML workflows on K8s
- **MLflow**: Experiment tracking
- **Ray**: Distributed training

**Serving**:
- **KServe**: Model serving on K8s
- **Istio**: Traffic management
- **NGINX**: API gateway

**Monitoring**:
- **Prometheus**: Metrics
- **Grafana**: Visualization
- **Evidently**: ML monitoring

---

## 📝 MLOps Best Practices

### 1. Version Everything
- **Code**: Git
- **Data**: DVC, LakeFS
- **Models**: MLflow, Model Registry
- **Environment**: Docker, Conda
- **Infrastructure**: Terraform

### 2. Automate Pipelines
```python
# Example: Kubeflow Pipeline
from kfp import dsl

@dsl.pipeline(name='ML Pipeline')
def ml_pipeline(data_path: str):
    # Data preprocessing
    preprocess = dsl.ContainerOp(
        name='preprocess',
        image='preprocess:v1',
        arguments=['--data', data_path]
    )
    
    # Model training
    train = dsl.ContainerOp(
        name='train',
        image='train:v1',
        arguments=['--data', preprocess.output]
    )
    
    # Model evaluation
    evaluate = dsl.ContainerOp(
        name='evaluate',
        image='evaluate:v1',
        arguments=['--model', train.output]
    )
    
    # Model deployment
    deploy = dsl.ContainerOp(
        name='deploy',
        image='deploy:v1',
        arguments=['--model', train.output]
    ).after(evaluate)
```

### 3. Implement CI/CD for ML

**CI Pipeline**:
- Data validation tests
- Model training tests
- Model performance tests
- Integration tests

**CD Pipeline**:
- Model packaging
- Canary deployment
- A/B testing
- Gradual rollout

**Example: GitHub Actions**
```yaml
name: ML CI/CD

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: pytest tests/
      
  train:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Train model
        run: python train.py
      - name: Evaluate model
        run: python evaluate.py
      
  deploy:
    needs: train
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        run: kubectl apply -f k8s/staging/
      - name: Run smoke tests
        run: pytest tests/smoke/
      - name: Deploy to production
        run: kubectl apply -f k8s/production/
```

### 4. Monitor Continuously
- Set up alerts for performance degradation
- Track data drift
- Monitor infrastructure metrics
- Log predictions for debugging

### 5. Ensure Reproducibility
- Pin dependencies
- Use Docker containers
- Version datasets
- Document experiments

---

## 🚀 Getting Started with MLOps

### Week 1: Foundation
- [ ] Set up MLflow for experiment tracking
- [ ] Containerize ML training code
- [ ] Version your dataset with DVC
- [ ] Create reproducible environment (requirements.txt, Dockerfile)

### Week 2: Deployment
- [ ] Deploy model as REST API (FastAPI, Flask)
- [ ] Set up Kubernetes cluster (Minikube for local)
- [ ] Deploy model with KServe or Seldon
- [ ] Implement health checks and monitoring

### Week 3: Automation
- [ ] Create training pipeline (Airflow, Kubeflow)
- [ ] Set up CI/CD (GitHub Actions, GitLab CI)
- [ ] Implement automated testing
- [ ] Configure auto-scaling

### Week 4: Monitoring
- [ ] Set up Prometheus and Grafana
- [ ] Implement model performance tracking
- [ ] Configure data drift detection
- [ ] Create alerting rules

---

## 💼 MLOps Career Opportunities

### Roles
- **MLOps Engineer**: $120k-200k
- **ML Platform Engineer**: $130k-220k
- **ML Infrastructure Engineer**: $140k-230k

### Skills in Demand
- Kubernetes & Docker
- Python & ML frameworks (TensorFlow, PyTorch)
- CI/CD & GitOps
- Cloud platforms (AWS SageMaker, GCP Vertex AI, Azure ML)
- Monitoring & observability

---

## 📚 Resources

### Learning
- [MLOps Community](https://mlops.community) - Community and resources
- [Made With ML](https://madewithml.com) - MLOps course
- [Full Stack Deep Learning](https://fullstackdeeplearning.com) - Production ML

### Tools Documentation
- [Kubeflow Docs](https://www.kubeflow.org/docs/)
- [MLflow Docs](https://mlflow.org/docs/latest/index.html)
- [KServe Docs](https://kserve.github.io/website/)

### Books
- "Designing Machine Learning Systems" by Chip Huyen
- "Building Machine Learning Powered Applications" by Emmanuel Ameisen
- "Machine Learning Engineering" by Andriy Burkov

---

> [!IMPORTANT]
> **The #1 MLOps Mistake**: Focusing on the latest tools instead of solving real problems. Start simple (Flask API + Docker), then add complexity as needed.

> [!TIP]
> **Quick Win**: Start by tracking experiments with MLflow. It takes 5 minutes to set up and immediately improves reproducibility.

**Ready to implement MLOps?** Start with experiment tracking and gradually build your ML platform! 🤖
