# Model Deployment

## Overview

Model deployment is the process of making trained machine learning models available for inference in production environments. This involves packaging, serving, scaling, and managing ML models to deliver predictions to end users or applications.

## Deployment Strategies

### 1. Blue-Green Deployment
```python
# blue_green_deployment.py
class BlueGreenDeployment:
    def __init__(self, load_balancer):
        self.load_balancer = load_balancer
        self.blue_env = "blue"
        self.green_env = "green"
        self.active_env = self.blue_env
    
    def deploy_new_version(self, model_version):
        inactive_env = self.green_env if self.active_env == self.blue_env else self.blue_env
        
        # Deploy to inactive environment
        self.deploy_to_environment(model_version, inactive_env)
        
        # Run health checks
        if self.health_check(inactive_env):
            # Switch traffic
            self.switch_traffic(inactive_env)
            self.active_env = inactive_env
            return True
        return False
    
    def switch_traffic(self, target_env):
        self.load_balancer.route_traffic(target_env)
```

### 2. Canary Deployment
```python
# canary_deployment.py
class CanaryDeployment:
    def __init__(self, traffic_split=0.1):
        self.traffic_split = traffic_split
        self.canary_metrics = {}
    
    def deploy_canary(self, new_model, baseline_model):
        for request in self.get_requests():
            if random.random() < self.traffic_split:
                response = new_model.predict(request)
                self.log_canary_metrics(response)
            else:
                response = baseline_model.predict(request)
            
            yield response
    
    def evaluate_canary(self):
        return self.canary_metrics['error_rate'] < 0.05
```

### 3. A/B Testing
```python
# ab_testing.py
class ABTestingDeployment:
    def __init__(self, model_a, model_b):
        self.model_a = model_a
        self.model_b = model_b
        self.results = {'a': [], 'b': []}
    
    def route_request(self, user_id, features):
        variant = 'a' if hash(user_id) % 2 == 0 else 'b'
        model = self.model_a if variant == 'a' else self.model_b
        
        prediction = model.predict(features)
        self.results[variant].append(prediction)
        
        return prediction, variant
```

## Model Serving Frameworks

### 1. TensorFlow Serving
```dockerfile
# tensorflow-serving.dockerfile
FROM tensorflow/serving:latest

COPY model/ /models/my_model/1/
ENV MODEL_NAME=my_model
ENV MODEL_BASE_PATH=/models

EXPOSE 8501
```

### 2. TorchServe
```python
# torch_handler.py
from ts.torch_handler.base_handler import BaseHandler
import torch

class CustomHandler(BaseHandler):
    def preprocess(self, data):
        return torch.tensor(data[0]['body'])
    
    def inference(self, data):
        return self.model(data)
    
    def postprocess(self, data):
        return data.tolist()
```

### 3. MLflow Model Serving
```python
# mlflow_serving.py
import mlflow.pyfunc

class MLflowModelServer:
    def __init__(self, model_uri):
        self.model = mlflow.pyfunc.load_model(model_uri)
    
    def predict(self, data):
        return self.model.predict(data)
```

## Containerized Deployment

### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Kubernetes Deployment
```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-model-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ml-model
  template:
    metadata:
      labels:
        app: ml-model
    spec:
      containers:
      - name: ml-model
        image: ml-model:v1.0.0
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: ml-model-service
spec:
  selector:
    app: ml-model
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

## Serverless Deployment

### AWS Lambda
```python
# lambda_handler.py
import json
import joblib
import numpy as np

model = joblib.load('model.pkl')

def lambda_handler(event, context):
    try:
        data = json.loads(event['body'])
        features = np.array(data['features']).reshape(1, -1)
        prediction = model.predict(features)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'prediction': prediction.tolist()
            })
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
```

## Real-time vs Batch Inference

### Real-time Inference
```python
# realtime_inference.py
from fastapi import FastAPI
import joblib

app = FastAPI()
model = joblib.load('model.pkl')

@app.post("/predict")
async def predict(data: dict):
    features = data['features']
    prediction = model.predict([features])
    return {"prediction": prediction[0]}
```

### Batch Inference
```python
# batch_inference.py
import pandas as pd
from concurrent.futures import ThreadPoolExecutor

class BatchInference:
    def __init__(self, model, batch_size=1000):
        self.model = model
        self.batch_size = batch_size
    
    def process_batch(self, data_batch):
        return self.model.predict(data_batch)
    
    def run_batch_inference(self, input_file, output_file):
        df = pd.read_csv(input_file)
        
        with ThreadPoolExecutor() as executor:
            futures = []
            for i in range(0, len(df), self.batch_size):
                batch = df.iloc[i:i+self.batch_size]
                future = executor.submit(self.process_batch, batch)
                futures.append(future)
            
            results = [future.result() for future in futures]
        
        predictions = np.concatenate(results)
        df['prediction'] = predictions
        df.to_csv(output_file, index=False)
```

## Model Versioning and Registry

### Model Registry
```python
# model_registry.py
class ModelRegistry:
    def __init__(self, storage_backend):
        self.storage = storage_backend
        self.models = {}
    
    def register_model(self, name, version, model_path, metadata):
        model_id = f"{name}:{version}"
        self.models[model_id] = {
            'path': model_path,
            'metadata': metadata,
            'status': 'registered'
        }
    
    def promote_model(self, name, version, stage):
        model_id = f"{name}:{version}"
        if model_id in self.models:
            self.models[model_id]['stage'] = stage
    
    def get_model(self, name, stage='production'):
        for model_id, info in self.models.items():
            if model_id.startswith(name) and info.get('stage') == stage:
                return self.storage.load_model(info['path'])
        return None
```

## Auto-scaling Configuration

### Horizontal Pod Autoscaler
```yaml
# hpa.yaml
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
```

## Monitoring and Health Checks

### Health Check Implementation
```python
# health_check.py
from fastapi import FastAPI, HTTPException
import joblib
import time

app = FastAPI()
model = None
model_load_time = None

@app.on_event("startup")
async def load_model():
    global model, model_load_time
    model = joblib.load('model.pkl')
    model_load_time = time.time()

@app.get("/health")
async def health_check():
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    return {
        "status": "healthy",
        "model_loaded": True,
        "uptime": time.time() - model_load_time
    }

@app.get("/readiness")
async def readiness_check():
    # Perform more comprehensive checks
    try:
        test_prediction = model.predict([[1, 2, 3, 4, 5]])
        return {"status": "ready", "test_prediction": test_prediction.tolist()}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Model not ready: {str(e)}")
```

## Performance Optimization

### Model Optimization
```python
# model_optimization.py
import onnx
import onnxruntime as ort
from sklearn.ensemble import RandomForestClassifier
from skl2onnx import convert_sklearn

class ModelOptimizer:
    def __init__(self, model):
        self.model = model
    
    def convert_to_onnx(self, initial_types):
        onnx_model = convert_sklearn(self.model, initial_types=initial_types)
        return onnx_model
    
    def optimize_onnx(self, onnx_model):
        # Apply ONNX optimizations
        from onnxruntime.tools import optimizer
        optimized_model = optimizer.optimize_model(onnx_model)
        return optimized_model
    
    def create_inference_session(self, onnx_model_path):
        providers = ['CPUExecutionProvider']
        if ort.get_device() == 'GPU':
            providers.insert(0, 'CUDAExecutionProvider')
        
        session = ort.InferenceSession(onnx_model_path, providers=providers)
        return session
```

## Security Considerations

### Secure Model Serving
```python
# secure_serving.py
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt

app = FastAPI()
security = HTTPBearer()

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, "secret", algorithms=["HS256"])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

@app.post("/predict")
async def secure_predict(data: dict, user=Depends(verify_token)):
    # Rate limiting, input validation, etc.
    prediction = model.predict([data['features']])
    return {"prediction": prediction[0]}
```

## Deployment Automation

### CI/CD Pipeline
```yaml
# deployment-pipeline.yml
name: Model Deployment

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: |
          docker build -t ml-model:${{ github.ref_name }} .
      
      - name: Deploy to staging
        run: |
          kubectl set image deployment/ml-model-staging ml-model=ml-model:${{ github.ref_name }}
      
      - name: Run tests
        run: |
          python test_deployment.py --environment staging
      
      - name: Deploy to production
        if: success()
        run: |
          kubectl set image deployment/ml-model-prod ml-model=ml-model:${{ github.ref_name }}
```

## Best Practices

1. **Model Packaging**: Use containers for consistent environments
2. **Version Control**: Tag and version all model artifacts
3. **Health Checks**: Implement comprehensive health monitoring
4. **Auto-scaling**: Configure based on traffic patterns
5. **Security**: Implement authentication and input validation
6. **Monitoring**: Track performance and business metrics
7. **Rollback**: Have quick rollback procedures
8. **Testing**: Validate deployments thoroughly

## Conclusion

Successful model deployment requires careful consideration of deployment strategies, infrastructure choices, monitoring, and security. The key is to start simple and gradually add complexity as needed while maintaining reliability and performance.