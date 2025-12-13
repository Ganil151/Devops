# MLOps Fundamentals

## Overview

MLOps (Machine Learning Operations) is a practice that combines Machine Learning, DevOps, and Data Engineering to deploy and maintain ML systems in production reliably and efficiently.

## Core Concepts

### What is MLOps?

MLOps is the application of DevOps principles to machine learning systems, focusing on:
- Automating the ML lifecycle
- Ensuring reproducibility and reliability
- Enabling continuous integration and deployment of ML models
- Monitoring and maintaining ML systems in production

### MLOps Maturity Levels

#### Level 0: Manual Process
- Manual data analysis and model building
- Disconnected ML and operations teams
- Infrequent model releases
- No CI/CD for ML

#### Level 1: ML Pipeline Automation
- Automated training pipelines
- Continuous training of models
- Experimental-operational symmetry
- Modularized code for ML components

#### Level 2: CI/CD Pipeline Automation
- Automated build, test, and deployment
- Version control for ML artifacts
- Automated model validation
- Production monitoring

### Key Principles

1. **Automation**
   - Automate data validation
   - Automate model training
   - Automate model deployment
   - Automate monitoring and alerting

2. **Version Control**
   - Code versioning with Git
   - Data versioning with DVC
   - Model versioning with MLflow
   - Environment versioning with Docker

3. **Testing**
   - Data validation tests
   - Model performance tests
   - Integration tests
   - A/B testing in production

4. **Monitoring**
   - Model performance monitoring
   - Data drift detection
   - Infrastructure monitoring
   - Business metrics tracking

5. **Reproducibility**
   - Deterministic training processes
   - Environment consistency
   - Seed management
   - Dependency management

## MLOps Workflow

### 1. Data Management
```python
# data_validation.py
import pandas as pd
from great_expectations import DataContext

def validate_data(data_path):
    """Validate incoming data against expectations"""
    context = DataContext()
    
    # Load data
    df = pd.read_csv(data_path)
    
    # Create batch
    batch = context.get_batch({
        "path": data_path,
        "datasource": "my_datasource"
    })
    
    # Run validation
    results = context.run_validation_operator(
        "action_list_operator",
        assets_to_validate=[batch]
    )
    
    return results.success
```

### 2. Model Development
```python
# model_training.py
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

def train_model(data_path, experiment_name):
    """Train and log model with MLflow"""
    mlflow.set_experiment(experiment_name)
    
    with mlflow.start_run():
        # Load and prepare data
        df = pd.read_csv(data_path)
        X = df.drop('target', axis=1)
        y = df['target']
        
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Train model
        model = RandomForestClassifier(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        
        # Evaluate model
        predictions = model.predict(X_test)
        accuracy = accuracy_score(y_test, predictions)
        
        # Log parameters and metrics
        mlflow.log_param("n_estimators", 100)
        mlflow.log_metric("accuracy", accuracy)
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
        
        return model, accuracy
```

### 3. Model Deployment
```python
# model_deployment.py
import joblib
import boto3
from datetime import datetime

class ModelDeployer:
    def __init__(self, s3_bucket, model_registry):
        self.s3_bucket = s3_bucket
        self.model_registry = model_registry
        self.s3_client = boto3.client('s3')
    
    def deploy_model(self, model, model_name, version):
        """Deploy model to production"""
        try:
            # Save model locally
            model_path = f"{model_name}_v{version}.pkl"
            joblib.dump(model, model_path)
            
            # Upload to S3
            s3_key = f"models/{model_name}/v{version}/{model_path}"
            self.s3_client.upload_file(model_path, self.s3_bucket, s3_key)
            
            # Register model
            self.register_model(model_name, version, s3_key)
            
            return True
        except Exception as e:
            print(f"Deployment failed: {str(e)}")
            return False
    
    def register_model(self, model_name, version, s3_path):
        """Register model in model registry"""
        model_info = {
            'name': model_name,
            'version': version,
            'path': s3_path,
            'deployed_at': datetime.now().isoformat(),
            'status': 'active'
        }
        
        # Store in model registry (implementation depends on registry choice)
        self.model_registry.register(model_info)
```

## MLOps Architecture

### Components

1. **Data Layer**
   - Data sources (databases, APIs, files)
   - Data lakes and warehouses
   - Feature stores
   - Data validation services

2. **ML Development Layer**
   - Jupyter notebooks for experimentation
   - ML frameworks (TensorFlow, PyTorch, Scikit-learn)
   - Experiment tracking (MLflow, Weights & Biases)
   - Model development environments

3. **ML Operations Layer**
   - CI/CD pipelines
   - Model registry
   - Model serving infrastructure
   - Monitoring and alerting systems

4. **Infrastructure Layer**
   - Container orchestration (Kubernetes)
   - Cloud services (AWS, Azure, GCP)
   - Infrastructure as Code (Terraform)
   - Security and compliance tools

### Reference Architecture

```yaml
# mlops-architecture.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mlops-config
data:
  data_sources: |
    - type: database
      connection: postgresql://user:pass@host:5432/db
    - type: s3
      bucket: ml-data-bucket
    - type: api
      endpoint: https://api.example.com/data
  
  model_registry: |
    type: mlflow
    tracking_uri: http://mlflow-server:5000
    artifact_store: s3://ml-artifacts-bucket
  
  deployment_targets: |
    - name: staging
      type: kubernetes
      namespace: ml-staging
    - name: production
      type: kubernetes
      namespace: ml-production
```

## Tools and Technologies

### Data Management
- **Apache Airflow**: Workflow orchestration
- **DVC**: Data version control
- **Great Expectations**: Data validation
- **Apache Kafka**: Real-time data streaming

### Model Development
- **Jupyter**: Interactive development
- **MLflow**: Experiment tracking and model registry
- **Weights & Biases**: Experiment tracking and visualization
- **Optuna**: Hyperparameter optimization

### Model Deployment
- **Docker**: Containerization
- **Kubernetes**: Container orchestration
- **Seldon Core**: ML model serving on Kubernetes
- **TensorFlow Serving**: TensorFlow model serving

### Monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and alerting
- **Evidently**: ML model monitoring
- **Alibi Detect**: Outlier and drift detection

## Best Practices

### Development Practices

1. **Use Version Control for Everything**
   ```bash
   # Initialize Git repository
   git init
   git add .
   git commit -m "Initial commit"
   
   # Initialize DVC for data versioning
   dvc init
   dvc add data/raw_data.csv
   git add data/raw_data.csv.dvc .gitignore
   git commit -m "Add raw data to DVC"
   ```

2. **Implement Automated Testing**
   ```python
   # test_model.py
   import pytest
   import pandas as pd
   from model_training import train_model
   
   def test_model_accuracy():
       """Test that model meets minimum accuracy threshold"""
       model, accuracy = train_model("test_data.csv", "test_experiment")
       assert accuracy > 0.8, f"Model accuracy {accuracy} below threshold"
   
   def test_model_predictions():
       """Test model prediction format"""
       model, _ = train_model("test_data.csv", "test_experiment")
       test_input = [[1, 2, 3, 4, 5]]
       prediction = model.predict(test_input)
       assert len(prediction) == 1
       assert isinstance(prediction[0], (int, float))
   ```

3. **Use Configuration Management**
   ```yaml
   # config.yaml
   data:
     train_path: "data/train.csv"
     test_path: "data/test.csv"
     validation_split: 0.2
   
   model:
     type: "RandomForestClassifier"
     parameters:
       n_estimators: 100
       max_depth: 10
       random_state: 42
   
   training:
     batch_size: 32
     epochs: 100
     learning_rate: 0.001
   
   deployment:
     model_name: "customer_churn_model"
     version: "1.0.0"
     environment: "production"
   ```

### Operational Practices

1. **Implement Comprehensive Monitoring**
   ```python
   # monitoring.py
   import logging
   from datetime import datetime
   import numpy as np
   
   class ModelMonitor:
       def __init__(self, model_name, threshold=0.1):
           self.model_name = model_name
           self.threshold = threshold
           self.logger = logging.getLogger(__name__)
       
       def log_prediction(self, input_data, prediction, actual=None):
           """Log prediction for monitoring"""
           log_entry = {
               'timestamp': datetime.now().isoformat(),
               'model_name': self.model_name,
               'input_hash': hash(str(input_data)),
               'prediction': prediction,
               'actual': actual
           }
           
           self.logger.info(f"Prediction logged: {log_entry}")
           
           if actual is not None:
               self.check_performance(prediction, actual)
       
       def check_performance(self, prediction, actual):
           """Check if prediction performance is degrading"""
           error = abs(prediction - actual)
           if error > self.threshold:
               self.logger.warning(
                   f"High prediction error: {error} > {self.threshold}"
               )
   ```

2. **Implement Gradual Rollouts**
   ```python
   # canary_deployment.py
   import random
   
   class CanaryDeployment:
       def __init__(self, old_model, new_model, traffic_split=0.1):
           self.old_model = old_model
           self.new_model = new_model
           self.traffic_split = traffic_split
       
       def predict(self, input_data):
           """Route traffic between old and new models"""
           if random.random() < self.traffic_split:
               # Route to new model
               prediction = self.new_model.predict(input_data)
               model_used = "new"
           else:
               # Route to old model
               prediction = self.old_model.predict(input_data)
               model_used = "old"
           
           # Log which model was used
           self.log_prediction(input_data, prediction, model_used)
           
           return prediction
       
       def log_prediction(self, input_data, prediction, model_used):
           """Log prediction with model information"""
           print(f"Model {model_used} used for prediction: {prediction}")
   ```

## Common Challenges and Solutions

### Challenge 1: Data Quality Issues
**Solution**: Implement automated data validation
```python
# data_quality_checks.py
def check_data_quality(df):
    """Perform comprehensive data quality checks"""
    issues = []
    
    # Check for missing values
    missing_pct = df.isnull().sum() / len(df) * 100
    high_missing = missing_pct[missing_pct > 10]
    if not high_missing.empty:
        issues.append(f"High missing values: {high_missing.to_dict()}")
    
    # Check for duplicates
    duplicate_count = df.duplicated().sum()
    if duplicate_count > 0:
        issues.append(f"Found {duplicate_count} duplicate rows")
    
    # Check data types
    expected_types = {'feature1': 'float64', 'feature2': 'int64'}
    for col, expected_type in expected_types.items():
        if col in df.columns and df[col].dtype != expected_type:
            issues.append(f"Column {col} has type {df[col].dtype}, expected {expected_type}")
    
    return issues
```

### Challenge 2: Model Drift
**Solution**: Implement drift detection
```python
# drift_detection.py
from scipy import stats
import numpy as np

def detect_drift(reference_data, current_data, threshold=0.05):
    """Detect data drift using statistical tests"""
    drift_results = {}
    
    for column in reference_data.columns:
        if column in current_data.columns:
            # Perform Kolmogorov-Smirnov test
            ks_stat, p_value = stats.ks_2samp(
                reference_data[column].dropna(),
                current_data[column].dropna()
            )
            
            drift_detected = p_value < threshold
            drift_results[column] = {
                'drift_detected': drift_detected,
                'p_value': p_value,
                'ks_statistic': ks_stat
            }
    
    return drift_results
```

### Challenge 3: Scalability
**Solution**: Implement auto-scaling infrastructure
```yaml
# kubernetes-autoscaling.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ml-model-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ml-model-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Getting Started Checklist

- [ ] Set up version control for code and data
- [ ] Implement basic CI/CD pipeline
- [ ] Set up experiment tracking
- [ ] Create model registry
- [ ] Implement basic monitoring
- [ ] Set up automated testing
- [ ] Create deployment pipeline
- [ ] Implement data validation
- [ ] Set up alerting system
- [ ] Document processes and procedures

## Conclusion

MLOps fundamentals provide the foundation for reliable, scalable, and maintainable machine learning systems. By implementing these practices incrementally and focusing on automation, monitoring, and reproducibility, organizations can successfully operationalize their ML workflows and deliver consistent business value.