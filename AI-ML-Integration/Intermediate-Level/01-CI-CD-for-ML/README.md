# CI/CD for Machine Learning

## Overview

CI/CD for Machine Learning extends traditional software development practices to handle the unique challenges of ML systems, including data dependencies, model training, validation, and deployment automation.

## ML-Specific CI/CD Challenges

### Traditional CI/CD vs ML CI/CD

| Aspect | Traditional CI/CD | ML CI/CD |
|--------|------------------|----------|
| Artifacts | Code, Binaries | Code, Data, Models |
| Testing | Unit, Integration | Data validation, Model validation |
| Deployment | Blue-green, Rolling | A/B testing, Shadow deployment |
| Rollback | Code version | Model + Data version |
| Triggers | Code changes | Code, Data, or Performance changes |

### Key Differences

1. **Data Dependencies**: ML pipelines depend on data quality and availability
2. **Non-deterministic Outputs**: Model training can produce different results
3. **Performance Degradation**: Models can degrade over time without code changes
4. **Complex Testing**: Requires statistical validation and business metric evaluation
5. **Gradual Rollouts**: Need for careful model deployment strategies

## ML Pipeline Architecture

### Pipeline Components

```python
# ml_pipeline_config.py
from dataclasses import dataclass
from typing import List, Dict, Any

@dataclass
class MLPipelineConfig:
    """Configuration for ML pipeline"""
    
    # Data configuration
    data_source: str
    data_validation_rules: Dict[str, Any]
    feature_engineering_config: Dict[str, Any]
    
    # Model configuration
    model_type: str
    model_parameters: Dict[str, Any]
    training_config: Dict[str, Any]
    
    # Validation configuration
    validation_metrics: List[str]
    performance_thresholds: Dict[str, float]
    
    # Deployment configuration
    deployment_strategy: str
    deployment_targets: List[str]
    
    # Monitoring configuration
    monitoring_config: Dict[str, Any]

# Example configuration
ml_config = MLPipelineConfig(
    data_source="s3://ml-data-bucket/training-data/",
    data_validation_rules={
        "schema_validation": True,
        "data_quality_checks": True,
        "drift_detection": True
    },
    feature_engineering_config={
        "scaling": "standard",
        "encoding": "label",
        "feature_selection": "top_k"
    },
    model_type="random_forest",
    model_parameters={
        "n_estimators": 100,
        "max_depth": 10,
        "random_state": 42
    },
    training_config={
        "test_size": 0.2,
        "validation_size": 0.1,
        "cross_validation": 5
    },
    validation_metrics=["accuracy", "precision", "recall", "f1_score"],
    performance_thresholds={
        "accuracy": 0.85,
        "precision": 0.80,
        "recall": 0.80
    },
    deployment_strategy="canary",
    deployment_targets=["staging", "production"],
    monitoring_config={
        "drift_detection": True,
        "performance_monitoring": True,
        "alert_thresholds": {"accuracy_drop": 0.05}
    }
)
```

### Pipeline Stages

1. **Data Pipeline**
   - Data extraction and validation
   - Feature engineering
   - Data preprocessing
   - Data splitting

2. **Training Pipeline**
   - Model training
   - Hyperparameter optimization
   - Model evaluation
   - Model validation

3. **Deployment Pipeline**
   - Model packaging
   - Infrastructure provisioning
   - Model deployment
   - Integration testing

4. **Monitoring Pipeline**
   - Performance monitoring
   - Data drift detection
   - Alert management
   - Retraining triggers

## Data Pipeline Implementation

### Data Validation Pipeline
```python
# data_pipeline.py
import pandas as pd
import numpy as np
from great_expectations import DataContext
from scipy import stats
import logging

class DataPipeline:
    def __init__(self, config):
        self.config = config
        self.logger = logging.getLogger(__name__)
        self.data_context = DataContext()
    
    def extract_data(self, source_path):
        """Extract data from source"""
        try:
            if source_path.endswith('.csv'):
                df = pd.read_csv(source_path)
            elif source_path.endswith('.parquet'):
                df = pd.read_parquet(source_path)
            else:
                raise ValueError(f"Unsupported file format: {source_path}")
            
            self.logger.info(f"Extracted {len(df)} rows from {source_path}")
            return df
        except Exception as e:
            self.logger.error(f"Data extraction failed: {str(e)}")
            raise
    
    def validate_schema(self, df, expected_schema):
        """Validate data schema"""
        validation_results = {
            'schema_valid': True,
            'issues': []
        }
        
        # Check required columns
        missing_columns = set(expected_schema.keys()) - set(df.columns)
        if missing_columns:
            validation_results['schema_valid'] = False
            validation_results['issues'].append(f"Missing columns: {missing_columns}")
        
        # Check data types
        for column, expected_type in expected_schema.items():
            if column in df.columns:
                if df[column].dtype != expected_type:
                    validation_results['schema_valid'] = False
                    validation_results['issues'].append(
                        f"Column {column}: expected {expected_type}, got {df[column].dtype}"
                    )
        
        return validation_results
    
    def validate_data_quality(self, df):
        """Validate data quality"""
        quality_results = {
            'quality_valid': True,
            'issues': []
        }
        
        # Check for missing values
        missing_pct = (df.isnull().sum() / len(df)) * 100
        high_missing = missing_pct[missing_pct > 20]
        if not high_missing.empty:
            quality_results['quality_valid'] = False
            quality_results['issues'].append(f"High missing values: {high_missing.to_dict()}")
        
        # Check for duplicates
        duplicate_count = df.duplicated().sum()
        if duplicate_count > len(df) * 0.1:  # More than 10% duplicates
            quality_results['quality_valid'] = False
            quality_results['issues'].append(f"High duplicate rate: {duplicate_count} duplicates")
        
        # Check for outliers in numerical columns
        numerical_columns = df.select_dtypes(include=[np.number]).columns
        for column in numerical_columns:
            z_scores = np.abs(stats.zscore(df[column].dropna()))
            outlier_count = (z_scores > 3).sum()
            if outlier_count > len(df) * 0.05:  # More than 5% outliers
                quality_results['issues'].append(f"High outlier rate in {column}: {outlier_count}")
        
        return quality_results
    
    def detect_data_drift(self, current_df, reference_df, threshold=0.05):
        """Detect data drift between current and reference data"""
        drift_results = {
            'drift_detected': False,
            'drift_features': []
        }
        
        common_columns = set(current_df.columns) & set(reference_df.columns)
        numerical_columns = current_df[list(common_columns)].select_dtypes(include=[np.number]).columns
        
        for column in numerical_columns:
            # Perform Kolmogorov-Smirnov test
            ks_stat, p_value = stats.ks_2samp(
                reference_df[column].dropna(),
                current_df[column].dropna()
            )
            
            if p_value < threshold:
                drift_results['drift_detected'] = True
                drift_results['drift_features'].append({
                    'feature': column,
                    'p_value': p_value,
                    'ks_statistic': ks_stat
                })
        
        return drift_results
    
    def preprocess_data(self, df):
        """Preprocess data for training"""
        # Handle missing values
        df = df.fillna(df.mean(numeric_only=True))
        
        # Remove duplicates
        df = df.drop_duplicates()
        
        # Feature engineering based on config
        if self.config.feature_engineering_config.get('scaling') == 'standard':
            from sklearn.preprocessing import StandardScaler
            numerical_columns = df.select_dtypes(include=[np.number]).columns
            scaler = StandardScaler()
            df[numerical_columns] = scaler.fit_transform(df[numerical_columns])
        
        return df
    
    def run_pipeline(self, source_path, reference_data_path=None):
        """Run complete data pipeline"""
        pipeline_results = {
            'success': True,
            'data': None,
            'validation_results': {},
            'issues': []
        }
        
        try:
            # Extract data
            df = self.extract_data(source_path)
            
            # Validate schema
            expected_schema = {'feature1': 'float64', 'feature2': 'int64', 'target': 'int64'}
            schema_results = self.validate_schema(df, expected_schema)
            pipeline_results['validation_results']['schema'] = schema_results
            
            if not schema_results['schema_valid']:
                pipeline_results['success'] = False
                pipeline_results['issues'].extend(schema_results['issues'])
                return pipeline_results
            
            # Validate data quality
            quality_results = self.validate_data_quality(df)
            pipeline_results['validation_results']['quality'] = quality_results
            
            if not quality_results['quality_valid']:
                pipeline_results['success'] = False
                pipeline_results['issues'].extend(quality_results['issues'])
                return pipeline_results
            
            # Check for data drift if reference data is provided
            if reference_data_path:
                reference_df = self.extract_data(reference_data_path)
                drift_results = self.detect_data_drift(df, reference_df)
                pipeline_results['validation_results']['drift'] = drift_results
                
                if drift_results['drift_detected']:
                    self.logger.warning("Data drift detected")
                    # Decide whether to proceed or fail based on drift severity
            
            # Preprocess data
            processed_df = self.preprocess_data(df)
            pipeline_results['data'] = processed_df
            
            self.logger.info("Data pipeline completed successfully")
            
        except Exception as e:
            pipeline_results['success'] = False
            pipeline_results['issues'].append(str(e))
            self.logger.error(f"Data pipeline failed: {str(e)}")
        
        return pipeline_results
```

## Training Pipeline Implementation

### Model Training Pipeline
```python
# training_pipeline.py
import mlflow
import mlflow.sklearn
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import joblib
import json

class TrainingPipeline:
    def __init__(self, config):
        self.config = config
        self.model = None
        self.training_results = {}
    
    def prepare_data(self, df):
        """Prepare data for training"""
        # Separate features and target
        X = df.drop('target', axis=1)
        y = df['target']
        
        # Split data
        X_train, X_temp, y_train, y_temp = train_test_split(
            X, y, 
            test_size=self.config.training_config['test_size'] + self.config.training_config['validation_size'],
            random_state=42,
            stratify=y
        )
        
        # Split temp into validation and test
        val_size = self.config.training_config['validation_size'] / (
            self.config.training_config['test_size'] + self.config.training_config['validation_size']
        )
        
        X_val, X_test, y_val, y_test = train_test_split(
            X_temp, y_temp,
            test_size=1-val_size,
            random_state=42,
            stratify=y_temp
        )
        
        return X_train, X_val, X_test, y_train, y_val, y_test
    
    def train_model(self, X_train, y_train, X_val, y_val):
        """Train model with hyperparameter optimization"""
        with mlflow.start_run():
            # Log configuration
            mlflow.log_params(self.config.model_parameters)
            
            # Initialize model
            if self.config.model_type == 'random_forest':
                base_model = RandomForestClassifier(**self.config.model_parameters)
            else:
                raise ValueError(f"Unsupported model type: {self.config.model_type}")
            
            # Hyperparameter tuning
            param_grid = {
                'n_estimators': [50, 100, 200],
                'max_depth': [5, 10, 15, None],
                'min_samples_split': [2, 5, 10]
            }
            
            grid_search = GridSearchCV(
                base_model,
                param_grid,
                cv=self.config.training_config['cross_validation'],
                scoring='accuracy',
                n_jobs=-1
            )
            
            grid_search.fit(X_train, y_train)
            self.model = grid_search.best_estimator_
            
            # Log best parameters
            for param, value in grid_search.best_params_.items():
                mlflow.log_param(f"best_{param}", value)
            
            # Validate on validation set
            val_predictions = self.model.predict(X_val)
            val_metrics = self.calculate_metrics(y_val, val_predictions)
            
            # Log validation metrics
            for metric, value in val_metrics.items():
                mlflow.log_metric(f"val_{metric}", value)
            
            # Cross-validation
            cv_scores = cross_val_score(
                self.model, X_train, y_train,
                cv=self.config.training_config['cross_validation'],
                scoring='accuracy'
            )
            
            mlflow.log_metric("cv_mean_accuracy", cv_scores.mean())
            mlflow.log_metric("cv_std_accuracy", cv_scores.std())
            
            # Log model
            mlflow.sklearn.log_model(self.model, "model")
            
            return val_metrics
    
    def calculate_metrics(self, y_true, y_pred):
        """Calculate evaluation metrics"""
        return {
            'accuracy': accuracy_score(y_true, y_pred),
            'precision': precision_score(y_true, y_pred, average='weighted'),
            'recall': recall_score(y_true, y_pred, average='weighted'),
            'f1_score': f1_score(y_true, y_pred, average='weighted')
        }
    
    def validate_model(self, X_test, y_test):
        """Validate model performance against thresholds"""
        test_predictions = self.model.predict(X_test)
        test_metrics = self.calculate_metrics(y_test, test_predictions)
        
        validation_results = {
            'metrics': test_metrics,
            'thresholds_met': True,
            'failed_thresholds': []
        }
        
        # Check against thresholds
        for metric, threshold in self.config.performance_thresholds.items():
            if test_metrics.get(metric, 0) < threshold:
                validation_results['thresholds_met'] = False
                validation_results['failed_thresholds'].append({
                    'metric': metric,
                    'value': test_metrics.get(metric, 0),
                    'threshold': threshold
                })
        
        return validation_results
    
    def run_pipeline(self, df):
        """Run complete training pipeline"""
        pipeline_results = {
            'success': True,
            'model': None,
            'metrics': {},
            'validation_results': {},
            'issues': []
        }
        
        try:
            # Prepare data
            X_train, X_val, X_test, y_train, y_val, y_test = self.prepare_data(df)
            
            # Train model
            val_metrics = self.train_model(X_train, y_train, X_val, y_val)
            
            # Validate model
            validation_results = self.validate_model(X_test, y_test)
            
            if not validation_results['thresholds_met']:
                pipeline_results['success'] = False
                pipeline_results['issues'].append("Model performance below thresholds")
                pipeline_results['issues'].extend([
                    f"{item['metric']}: {item['value']:.4f} < {item['threshold']}"
                    for item in validation_results['failed_thresholds']
                ])
            
            pipeline_results['model'] = self.model
            pipeline_results['metrics'] = validation_results['metrics']
            pipeline_results['validation_results'] = validation_results
            
        except Exception as e:
            pipeline_results['success'] = False
            pipeline_results['issues'].append(str(e))
        
        return pipeline_results
```

## Deployment Pipeline Implementation

### Model Deployment Pipeline
```python
# deployment_pipeline.py
import docker
import boto3
import json
import os
from datetime import datetime
import requests

class DeploymentPipeline:
    def __init__(self, config):
        self.config = config
        self.docker_client = docker.from_env()
        self.s3_client = boto3.client('s3')
    
    def package_model(self, model, model_metadata):
        """Package model for deployment"""
        # Create model package directory
        package_dir = f"model_package_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        os.makedirs(package_dir, exist_ok=True)
        
        # Save model
        model_path = os.path.join(package_dir, "model.pkl")
        joblib.dump(model, model_path)
        
        # Save metadata
        metadata_path = os.path.join(package_dir, "metadata.json")
        with open(metadata_path, 'w') as f:
            json.dump(model_metadata, f, indent=2)
        
        # Create inference script
        self.create_inference_script(package_dir)
        
        # Create Dockerfile
        self.create_dockerfile(package_dir)
        
        # Create requirements.txt
        self.create_requirements_file(package_dir)
        
        return package_dir
    
    def create_inference_script(self, package_dir):
        """Create inference script for model serving"""
        inference_script = '''
from flask import Flask, request, jsonify
import joblib
import pandas as pd
import json
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Load model and metadata
model = joblib.load("model.pkl")
with open("metadata.json", "r") as f:
    metadata = json.load(f)

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({
        "status": "healthy",
        "model_version": metadata.get("version", "unknown"),
        "model_name": metadata.get("name", "unknown")
    })

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        
        # Convert to DataFrame
        if isinstance(data, dict):
            df = pd.DataFrame([data])
        else:
            df = pd.DataFrame(data)
        
        # Make prediction
        prediction = model.predict(df)
        probability = None
        
        if hasattr(model, "predict_proba"):
            probability = model.predict_proba(df)
        
        response = {
            "prediction": prediction.tolist(),
            "model_version": metadata.get("version", "unknown")
        }
        
        if probability is not None:
            response["probability"] = probability.tolist()
        
        logging.info(f"Prediction made: {response}")
        return jsonify(response)
        
    except Exception as e:
        logging.error(f"Prediction error: {str(e)}")
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
'''
        
        script_path = os.path.join(package_dir, "app.py")
        with open(script_path, 'w') as f:
            f.write(inference_script)
    
    def create_dockerfile(self, package_dir):
        """Create Dockerfile for model container"""
        dockerfile_content = '''
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
'''
        
        dockerfile_path = os.path.join(package_dir, "Dockerfile")
        with open(dockerfile_path, 'w') as f:
            f.write(dockerfile_content)
    
    def create_requirements_file(self, package_dir):
        """Create requirements.txt file"""
        requirements = [
            "flask==2.0.1",
            "scikit-learn==1.0.2",
            "pandas==1.3.3",
            "numpy==1.21.2",
            "joblib==1.1.0"
        ]
        
        requirements_path = os.path.join(package_dir, "requirements.txt")
        with open(requirements_path, 'w') as f:
            f.write('\n'.join(requirements))
    
    def build_container(self, package_dir, image_name, tag):
        """Build Docker container"""
        try:
            image, logs = self.docker_client.images.build(
                path=package_dir,
                tag=f"{image_name}:{tag}",
                rm=True
            )
            
            return image
        except Exception as e:
            raise Exception(f"Container build failed: {str(e)}")
    
    def deploy_to_staging(self, image_name, tag):
        """Deploy model to staging environment"""
        try:
            # Stop existing staging container if running
            try:
                existing_container = self.docker_client.containers.get(f"{image_name}-staging")
                existing_container.stop()
                existing_container.remove()
            except docker.errors.NotFound:
                pass
            
            # Run new container
            container = self.docker_client.containers.run(
                f"{image_name}:{tag}",
                name=f"{image_name}-staging",
                ports={'5000/tcp': 5001},
                detach=True,
                restart_policy={"Name": "unless-stopped"}
            )
            
            # Wait for container to be ready
            import time
            time.sleep(10)
            
            # Health check
            health_check_result = self.health_check("http://localhost:5001")
            
            return {
                'success': health_check_result['healthy'],
                'container_id': container.id,
                'endpoint': 'http://localhost:5001'
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def deploy_to_production(self, image_name, tag):
        """Deploy model to production environment"""
        if self.config.deployment_strategy == 'canary':
            return self.canary_deployment(image_name, tag)
        elif self.config.deployment_strategy == 'blue_green':
            return self.blue_green_deployment(image_name, tag)
        else:
            return self.rolling_deployment(image_name, tag)
    
    def canary_deployment(self, image_name, tag, traffic_percentage=10):
        """Implement canary deployment strategy"""
        try:
            # Deploy canary version
            canary_container = self.docker_client.containers.run(
                f"{image_name}:{tag}",
                name=f"{image_name}-canary",
                ports={'5000/tcp': 5002},
                detach=True,
                restart_policy={"Name": "unless-stopped"}
            )
            
            # Configure load balancer to route traffic
            # This would integrate with your load balancer (nginx, ALB, etc.)
            self.configure_canary_routing(traffic_percentage)
            
            # Monitor canary performance
            canary_metrics = self.monitor_canary_deployment(
                "http://localhost:5002", 
                duration_minutes=30
            )
            
            if canary_metrics['success_rate'] > 0.95:
                # Promote canary to production
                return self.promote_canary_to_production(image_name, tag)
            else:
                # Rollback canary
                return self.rollback_canary_deployment(image_name)
                
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def health_check(self, endpoint):
        """Perform health check on deployed model"""
        try:
            response = requests.get(f"{endpoint}/health", timeout=10)
            if response.status_code == 200:
                return {
                    'healthy': True,
                    'response': response.json()
                }
            else:
                return {
                    'healthy': False,
                    'status_code': response.status_code
                }
        except Exception as e:
            return {
                'healthy': False,
                'error': str(e)
            }
    
    def integration_test(self, endpoint):
        """Run integration tests against deployed model"""
        test_results = {
            'success': True,
            'tests': []
        }
        
        # Test 1: Health check
        health_result = self.health_check(endpoint)
        test_results['tests'].append({
            'name': 'health_check',
            'passed': health_result['healthy']
        })
        
        if not health_result['healthy']:
            test_results['success'] = False
        
        # Test 2: Prediction test
        try:
            test_data = {"feature1": 1.0, "feature2": 2.0}
            response = requests.post(
                f"{endpoint}/predict",
                json=test_data,
                timeout=10
            )
            
            prediction_test_passed = (
                response.status_code == 200 and 
                'prediction' in response.json()
            )
            
            test_results['tests'].append({
                'name': 'prediction_test',
                'passed': prediction_test_passed
            })
            
            if not prediction_test_passed:
                test_results['success'] = False
                
        except Exception as e:
            test_results['tests'].append({
                'name': 'prediction_test',
                'passed': False,
                'error': str(e)
            })
            test_results['success'] = False
        
        return test_results
    
    def run_pipeline(self, model, model_metadata):
        """Run complete deployment pipeline"""
        pipeline_results = {
            'success': True,
            'stages': {},
            'issues': []
        }
        
        try:
            # Package model
            package_dir = self.package_model(model, model_metadata)
            pipeline_results['stages']['packaging'] = {'success': True}
            
            # Build container
            image_name = model_metadata.get('name', 'ml-model')
            tag = model_metadata.get('version', 'latest')
            
            image = self.build_container(package_dir, image_name, tag)
            pipeline_results['stages']['build'] = {'success': True, 'image_id': image.id}
            
            # Deploy to staging
            staging_result = self.deploy_to_staging(image_name, tag)
            pipeline_results['stages']['staging_deployment'] = staging_result
            
            if not staging_result['success']:
                pipeline_results['success'] = False
                pipeline_results['issues'].append("Staging deployment failed")
                return pipeline_results
            
            # Run integration tests
            integration_result = self.integration_test(staging_result['endpoint'])
            pipeline_results['stages']['integration_tests'] = integration_result
            
            if not integration_result['success']:
                pipeline_results['success'] = False
                pipeline_results['issues'].append("Integration tests failed")
                return pipeline_results
            
            # Deploy to production if configured
            if 'production' in self.config.deployment_targets:
                production_result = self.deploy_to_production(image_name, tag)
                pipeline_results['stages']['production_deployment'] = production_result
                
                if not production_result['success']:
                    pipeline_results['success'] = False
                    pipeline_results['issues'].append("Production deployment failed")
            
        except Exception as e:
            pipeline_results['success'] = False
            pipeline_results['issues'].append(str(e))
        
        return pipeline_results
```

## GitHub Actions ML Pipeline

### Complete ML CI/CD Pipeline
```yaml
# .github/workflows/ml-cicd.yml
name: ML CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Daily retraining check

env:
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  DOCKER_REGISTRY: ${{ secrets.DOCKER_REGISTRY }}

jobs:
  data-pipeline:
    runs-on: ubuntu-latest
    outputs:
      data-valid: ${{ steps.data-validation.outputs.valid }}
      drift-detected: ${{ steps.drift-detection.outputs.detected }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Extract data
        run: |
          python scripts/extract_data.py
      
      - name: Validate data schema
        id: schema-validation
        run: |
          python scripts/validate_schema.py
          echo "valid=$(cat schema_validation_result.txt)" >> $GITHUB_OUTPUT
      
      - name: Check data quality
        id: quality-check
        run: |
          python scripts/check_data_quality.py
          echo "valid=$(cat quality_check_result.txt)" >> $GITHUB_OUTPUT
      
      - name: Detect data drift
        id: drift-detection
        run: |
          python scripts/detect_drift.py
          echo "detected=$(cat drift_detection_result.txt)" >> $GITHUB_OUTPUT
      
      - name: Data validation summary
        id: data-validation
        run: |
          if [[ "${{ steps.schema-validation.outputs.valid }}" == "true" && "${{ steps.quality-check.outputs.valid }}" == "true" ]]; then
            echo "valid=true" >> $GITHUB_OUTPUT
          else
            echo "valid=false" >> $GITHUB_OUTPUT
          fi
      
      - name: Upload processed data
        if: steps.data-validation.outputs.valid == 'true'
        uses: actions/upload-artifact@v3
        with:
          name: processed-data
          path: data/processed/

  training-pipeline:
    needs: data-pipeline
    runs-on: ubuntu-latest
    if: needs.data-pipeline.outputs.data-valid == 'true'
    outputs:
      model-valid: ${{ steps.model-validation.outputs.valid }}
      model-version: ${{ steps.model-training.outputs.version }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Download processed data
        uses: actions/download-artifact@v3
        with:
          name: processed-data
          path: data/processed/
      
      - name: Train model
        id: model-training
        run: |
          python scripts/train_model.py
          echo "version=$(cat model_version.txt)" >> $GITHUB_OUTPUT
      
      - name: Validate model performance
        id: model-validation
        run: |
          python scripts/validate_model.py
          echo "valid=$(cat model_validation_result.txt)" >> $GITHUB_OUTPUT
      
      - name: Run model tests
        run: |
          python -m pytest tests/test_model.py -v
      
      - name: Upload model artifacts
        if: steps.model-validation.outputs.valid == 'true'
        uses: actions/upload-artifact@v3
        with:
          name: model-artifacts
          path: artifacts/

  deployment-pipeline:
    needs: [data-pipeline, training-pipeline]
    runs-on: ubuntu-latest
    if: |
      needs.training-pipeline.outputs.model-valid == 'true' && 
      (github.ref == 'refs/heads/main' || needs.data-pipeline.outputs.drift-detected == 'true')
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Download model artifacts
        uses: actions/download-artifact@v3
        with:
          name: model-artifacts
          path: artifacts/
      
      - name: Build Docker image
        run: |
          docker build -t ml-model:${{ needs.training-pipeline.outputs.model-version }} .
      
      - name: Deploy to staging
        run: |
          python scripts/deploy_staging.py --version ${{ needs.training-pipeline.outputs.model-version }}
      
      - name: Run integration tests
        run: |
          python scripts/integration_tests.py --environment staging
      
      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        run: |
          python scripts/deploy_production.py --version ${{ needs.training-pipeline.outputs.model-version }}
      
      - name: Setup monitoring
        if: github.ref == 'refs/heads/main'
        run: |
          python scripts/setup_monitoring.py --version ${{ needs.training-pipeline.outputs.model-version }}

  monitoring-pipeline:
    needs: deployment-pipeline
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Configure monitoring dashboards
        run: |
          python scripts/configure_dashboards.py
      
      - name: Setup alerting rules
        run: |
          python scripts/setup_alerts.py
      
      - name: Validate monitoring setup
        run: |
          python scripts/validate_monitoring.py

  retraining-check:
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Check model performance
        run: |
          python scripts/check_model_performance.py
      
      - name: Trigger retraining if needed
        run: |
          if [[ -f "retraining_required.txt" ]]; then
            gh workflow run ml-cicd.yml --ref main
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Best Practices

### CI/CD Best Practices for ML

1. **Automated Testing**
   - Data validation tests
   - Model performance tests
   - Integration tests
   - A/B testing automation

2. **Version Control**
   - Code versioning with Git
   - Data versioning with DVC
   - Model versioning with MLflow
   - Pipeline versioning

3. **Monitoring and Alerting**
   - Performance monitoring
   - Data drift detection
   - Infrastructure monitoring
   - Business metrics tracking

4. **Security and Compliance**
   - Secrets management
   - Access controls
   - Audit logging
   - Compliance validation

5. **Rollback Strategies**
   - Model rollback procedures
   - Data rollback capabilities
   - Infrastructure rollback
   - Automated rollback triggers

## Conclusion

Implementing CI/CD for Machine Learning requires extending traditional DevOps practices to handle the unique challenges of ML systems. Success depends on proper automation, testing, monitoring, and deployment strategies that account for the probabilistic nature of ML models and their dependencies on data quality and availability.