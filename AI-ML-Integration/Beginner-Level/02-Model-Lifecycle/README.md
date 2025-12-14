# Model Lifecycle Management

## Overview

Model Lifecycle Management encompasses the entire journey of a machine learning model from conception to retirement, including development, deployment, monitoring, and maintenance phases.

## Model Lifecycle Stages

### 1. Problem Definition and Planning

#### Business Problem Identification
- Define business objectives and success metrics
- Identify stakeholders and requirements
- Assess feasibility and resource requirements
- Define project scope and timeline

#### Data Assessment
```python
# data_assessment.py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

class DataAssessment:
    def __init__(self, data_path):
        self.data = pd.read_csv(data_path)
    
    def generate_report(self):
        """Generate comprehensive data assessment report"""
        report = {
            'shape': self.data.shape,
            'missing_values': self.data.isnull().sum().to_dict(),
            'data_types': self.data.dtypes.to_dict(),
            'summary_stats': self.data.describe().to_dict(),
            'unique_values': {col: self.data[col].nunique() for col in self.data.columns}
        }
        
        return report
    
    def check_data_quality(self):
        """Check data quality issues"""
        issues = []
        
        # Check missing values
        missing_pct = (self.data.isnull().sum() / len(self.data)) * 100
        high_missing = missing_pct[missing_pct > 20]
        if not high_missing.empty:
            issues.append(f"High missing values (>20%): {high_missing.to_dict()}")
        
        # Check duplicates
        duplicates = self.data.duplicated().sum()
        if duplicates > 0:
            issues.append(f"Found {duplicates} duplicate rows")
        
        # Check data consistency
        for col in self.data.select_dtypes(include=[np.number]).columns:
            if (self.data[col] < 0).any():
                issues.append(f"Negative values found in {col}")
        
        return issues
```

### 2. Data Collection and Preparation

#### Data Ingestion Pipeline
```python
# data_ingestion.py
import pandas as pd
from sqlalchemy import create_engine
import boto3
from datetime import datetime

class DataIngestionPipeline:
    def __init__(self, config):
        self.config = config
        self.s3_client = boto3.client('s3')
    
    def ingest_from_database(self, query, connection_string):
        """Ingest data from database"""
        engine = create_engine(connection_string)
        df = pd.read_sql(query, engine)
        
        # Add metadata
        df['ingestion_timestamp'] = datetime.now()
        df['data_source'] = 'database'
        
        return df
    
    def ingest_from_s3(self, bucket, key):
        """Ingest data from S3"""
        obj = self.s3_client.get_object(Bucket=bucket, Key=key)
        df = pd.read_csv(obj['Body'])
        
        # Add metadata
        df['ingestion_timestamp'] = datetime.now()
        df['data_source'] = 's3'
        
        return df
    
    def validate_schema(self, df, expected_schema):
        """Validate data schema"""
        issues = []
        
        # Check required columns
        missing_cols = set(expected_schema.keys()) - set(df.columns)
        if missing_cols:
            issues.append(f"Missing columns: {missing_cols}")
        
        # Check data types
        for col, expected_type in expected_schema.items():
            if col in df.columns and df[col].dtype != expected_type:
                issues.append(f"Column {col}: expected {expected_type}, got {df[col].dtype}")
        
        return issues
```

#### Feature Engineering
```python
# feature_engineering.py
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.feature_selection import SelectKBest, f_classif

class FeatureEngineer:
    def __init__(self):
        self.scalers = {}
        self.encoders = {}
        self.feature_selector = None
    
    def create_temporal_features(self, df, date_column):
        """Create temporal features from date column"""
        df[date_column] = pd.to_datetime(df[date_column])
        
        df[f'{date_column}_year'] = df[date_column].dt.year
        df[f'{date_column}_month'] = df[date_column].dt.month
        df[f'{date_column}_day'] = df[date_column].dt.day
        df[f'{date_column}_dayofweek'] = df[date_column].dt.dayofweek
        df[f'{date_column}_quarter'] = df[date_column].dt.quarter
        
        return df
    
    def create_interaction_features(self, df, feature_pairs):
        """Create interaction features"""
        for feat1, feat2 in feature_pairs:
            if feat1 in df.columns and feat2 in df.columns:
                df[f'{feat1}_{feat2}_interaction'] = df[feat1] * df[feat2]
                df[f'{feat1}_{feat2}_ratio'] = df[feat1] / (df[feat2] + 1e-8)
        
        return df
    
    def encode_categorical_features(self, df, categorical_columns, method='label'):
        """Encode categorical features"""
        for col in categorical_columns:
            if col in df.columns:
                if method == 'label':
                    if col not in self.encoders:
                        self.encoders[col] = LabelEncoder()
                        df[col] = self.encoders[col].fit_transform(df[col].astype(str))
                    else:
                        df[col] = self.encoders[col].transform(df[col].astype(str))
                elif method == 'onehot':
                    dummies = pd.get_dummies(df[col], prefix=col)
                    df = pd.concat([df, dummies], axis=1)
                    df.drop(col, axis=1, inplace=True)
        
        return df
    
    def scale_numerical_features(self, df, numerical_columns):
        """Scale numerical features"""
        for col in numerical_columns:
            if col in df.columns:
                if col not in self.scalers:
                    self.scalers[col] = StandardScaler()
                    df[col] = self.scalers[col].fit_transform(df[[col]])
                else:
                    df[col] = self.scalers[col].transform(df[[col]])
        
        return df
    
    def select_features(self, X, y, k=10):
        """Select top k features"""
        if self.feature_selector is None:
            self.feature_selector = SelectKBest(score_func=f_classif, k=k)
            X_selected = self.feature_selector.fit_transform(X, y)
        else:
            X_selected = self.feature_selector.transform(X)
        
        selected_features = X.columns[self.feature_selector.get_support()].tolist()
        return pd.DataFrame(X_selected, columns=selected_features)
```

### 3. Model Development and Training

#### Experiment Management
```python
# experiment_manager.py
import mlflow
import mlflow.sklearn
import json
from datetime import datetime
import hashlib

class ExperimentManager:
    def __init__(self, experiment_name, tracking_uri=None):
        self.experiment_name = experiment_name
        if tracking_uri:
            mlflow.set_tracking_uri(tracking_uri)
        mlflow.set_experiment(experiment_name)
    
    def start_run(self, run_name=None, tags=None):
        """Start MLflow run with metadata"""
        run = mlflow.start_run(run_name=run_name, tags=tags)
        return run
    
    def log_experiment_config(self, config):
        """Log experiment configuration"""
        # Log parameters
        for key, value in config.items():
            if isinstance(value, dict):
                mlflow.log_params({f"{key}_{k}": v for k, v in value.items()})
            else:
                mlflow.log_param(key, value)
        
        # Log config as artifact
        config_path = "experiment_config.json"
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        mlflow.log_artifact(config_path)
    
    def log_data_info(self, X_train, X_test, y_train, y_test):
        """Log dataset information"""
        data_info = {
            'train_samples': len(X_train),
            'test_samples': len(X_test),
            'features': X_train.shape[1],
            'feature_names': list(X_train.columns),
            'target_distribution': y_train.value_counts().to_dict()
        }
        
        # Log as parameters
        mlflow.log_param("train_samples", data_info['train_samples'])
        mlflow.log_param("test_samples", data_info['test_samples'])
        mlflow.log_param("num_features", data_info['features'])
        
        # Log detailed info as artifact
        with open("data_info.json", 'w') as f:
            json.dump(data_info, f, indent=2)
        mlflow.log_artifact("data_info.json")
    
    def log_model_performance(self, model, X_test, y_test, metrics_dict):
        """Log model performance metrics"""
        # Log metrics
        for metric_name, metric_value in metrics_dict.items():
            mlflow.log_metric(metric_name, metric_value)
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
        
        # Generate and log feature importance if available
        if hasattr(model, 'feature_importances_'):
            import pandas as pd
            feature_importance = pd.DataFrame({
                'feature': X_test.columns,
                'importance': model.feature_importances_
            }).sort_values('importance', ascending=False)
            
            feature_importance.to_csv("feature_importance.csv", index=False)
            mlflow.log_artifact("feature_importance.csv")
```

#### Model Training Pipeline
```python
# model_training.py
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.model_selection import cross_val_score, GridSearchCV
import joblib

class ModelTrainer:
    def __init__(self, experiment_manager):
        self.experiment_manager = experiment_manager
        self.models = {
            'random_forest': RandomForestClassifier(random_state=42),
            'gradient_boosting': GradientBoostingClassifier(random_state=42),
            'logistic_regression': LogisticRegression(random_state=42),
            'svm': SVC(random_state=42, probability=True)
        }
        self.param_grids = {
            'random_forest': {
                'n_estimators': [50, 100, 200],
                'max_depth': [5, 10, 15],
                'min_samples_split': [2, 5, 10]
            },
            'gradient_boosting': {
                'n_estimators': [50, 100, 200],
                'learning_rate': [0.01, 0.1, 0.2],
                'max_depth': [3, 5, 7]
            },
            'logistic_regression': {
                'C': [0.1, 1, 10],
                'penalty': ['l1', 'l2'],
                'solver': ['liblinear', 'saga']
            }
        }
    
    def train_single_model(self, model_name, X_train, y_train, X_test, y_test, hyperparameter_tuning=False):
        """Train a single model"""
        with self.experiment_manager.start_run(run_name=f"{model_name}_training"):
            model = self.models[model_name]
            
            if hyperparameter_tuning and model_name in self.param_grids:
                # Perform hyperparameter tuning
                grid_search = GridSearchCV(
                    model, 
                    self.param_grids[model_name], 
                    cv=5, 
                    scoring='accuracy',
                    n_jobs=-1
                )
                grid_search.fit(X_train, y_train)
                model = grid_search.best_estimator_
                
                # Log best parameters
                for param, value in grid_search.best_params_.items():
                    mlflow.log_param(f"best_{param}", value)
            else:
                model.fit(X_train, y_train)
            
            # Make predictions
            y_pred = model.predict(X_test)
            y_pred_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else None
            
            # Calculate metrics
            metrics = self.calculate_metrics(y_test, y_pred, y_pred_proba)
            
            # Log experiment
            self.experiment_manager.log_model_performance(model, X_test, y_test, metrics)
            
            return model, metrics
    
    def train_multiple_models(self, X_train, y_train, X_test, y_test, model_names=None):
        """Train multiple models and compare performance"""
        if model_names is None:
            model_names = list(self.models.keys())
        
        results = {}
        
        for model_name in model_names:
            print(f"Training {model_name}...")
            model, metrics = self.train_single_model(
                model_name, X_train, y_train, X_test, y_test, hyperparameter_tuning=True
            )
            results[model_name] = {'model': model, 'metrics': metrics}
        
        # Find best model
        best_model_name = max(results.keys(), key=lambda x: results[x]['metrics']['accuracy'])
        best_model = results[best_model_name]['model']
        
        print(f"Best model: {best_model_name}")
        return best_model, results
    
    def calculate_metrics(self, y_true, y_pred, y_pred_proba=None):
        """Calculate comprehensive metrics"""
        metrics = {
            'accuracy': accuracy_score(y_true, y_pred),
            'precision': precision_score(y_true, y_pred, average='weighted'),
            'recall': recall_score(y_true, y_pred, average='weighted'),
            'f1_score': f1_score(y_true, y_pred, average='weighted')
        }
        
        if y_pred_proba is not None:
            metrics['roc_auc'] = roc_auc_score(y_true, y_pred_proba)
        
        return metrics
    
    def cross_validate_model(self, model, X, y, cv=5):
        """Perform cross-validation"""
        cv_scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')
        
        cv_results = {
            'cv_mean_accuracy': cv_scores.mean(),
            'cv_std_accuracy': cv_scores.std(),
            'cv_scores': cv_scores.tolist()
        }
        
        return cv_results
```

### 4. Model Validation and Testing

#### Model Validation Framework
```python
# model_validation.py
import numpy as np
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

class ModelValidator:
    def __init__(self, model, X_test, y_test):
        self.model = model
        self.X_test = X_test
        self.y_test = y_test
        self.y_pred = model.predict(X_test)
        self.y_pred_proba = model.predict_proba(X_test) if hasattr(model, 'predict_proba') else None
    
    def validate_performance(self, min_accuracy=0.8, min_precision=0.8, min_recall=0.8):
        """Validate model performance against thresholds"""
        from sklearn.metrics import accuracy_score, precision_score, recall_score
        
        accuracy = accuracy_score(self.y_test, self.y_pred)
        precision = precision_score(self.y_test, self.y_pred, average='weighted')
        recall = recall_score(self.y_test, self.y_pred, average='weighted')
        
        validation_results = {
            'accuracy_pass': accuracy >= min_accuracy,
            'precision_pass': precision >= min_precision,
            'recall_pass': recall >= min_recall,
            'overall_pass': all([
                accuracy >= min_accuracy,
                precision >= min_precision,
                recall >= min_recall
            ])
        }
        
        return validation_results
    
    def validate_fairness(self, sensitive_feature):
        """Validate model fairness across sensitive groups"""
        fairness_results = {}
        
        for group in self.X_test[sensitive_feature].unique():
            group_mask = self.X_test[sensitive_feature] == group
            group_accuracy = accuracy_score(
                self.y_test[group_mask], 
                self.y_pred[group_mask]
            )
            fairness_results[f'accuracy_group_{group}'] = group_accuracy
        
        # Calculate fairness metrics
        accuracies = list(fairness_results.values())
        fairness_results['accuracy_difference'] = max(accuracies) - min(accuracies)
        fairness_results['fairness_pass'] = fairness_results['accuracy_difference'] < 0.1
        
        return fairness_results
    
    def validate_robustness(self, noise_level=0.1):
        """Validate model robustness to input noise"""
        # Add noise to test data
        noise = np.random.normal(0, noise_level, self.X_test.shape)
        X_test_noisy = self.X_test + noise
        
        # Make predictions on noisy data
        y_pred_noisy = self.model.predict(X_test_noisy)
        
        # Calculate robustness metrics
        robustness_accuracy = accuracy_score(self.y_test, y_pred_noisy)
        prediction_stability = np.mean(self.y_pred == y_pred_noisy)
        
        robustness_results = {
            'robustness_accuracy': robustness_accuracy,
            'prediction_stability': prediction_stability,
            'robustness_pass': prediction_stability > 0.9
        }
        
        return robustness_results
    
    def generate_validation_report(self):
        """Generate comprehensive validation report"""
        report = {
            'classification_report': classification_report(self.y_test, self.y_pred, output_dict=True),
            'confusion_matrix': confusion_matrix(self.y_test, self.y_pred).tolist()
        }
        
        return report
```

### 5. Model Deployment

#### Model Packaging
```python
# model_packaging.py
import joblib
import json
import os
from datetime import datetime
import tarfile

class ModelPackager:
    def __init__(self, model, metadata, artifacts_dir="model_artifacts"):
        self.model = model
        self.metadata = metadata
        self.artifacts_dir = artifacts_dir
        os.makedirs(artifacts_dir, exist_ok=True)
    
    def package_model(self):
        """Package model with all necessary artifacts"""
        # Save model
        model_path = os.path.join(self.artifacts_dir, "model.pkl")
        joblib.dump(self.model, model_path)
        
        # Save metadata
        metadata_path = os.path.join(self.artifacts_dir, "metadata.json")
        with open(metadata_path, 'w') as f:
            json.dump(self.metadata, f, indent=2)
        
        # Create requirements.txt
        requirements_path = os.path.join(self.artifacts_dir, "requirements.txt")
        with open(requirements_path, 'w') as f:
            f.write("scikit-learn==1.0.2\n")
            f.write("pandas==1.3.3\n")
            f.write("numpy==1.21.2\n")
            f.write("joblib==1.1.0\n")
        
        # Create inference script
        self.create_inference_script()
        
        # Create Docker file
        self.create_dockerfile()
        
        # Create tar archive
        return self.create_archive()
    
    def create_inference_script(self):
        """Create inference script"""
        inference_script = '''
import joblib
import pandas as pd
import json

class ModelInference:
    def __init__(self, model_path="model.pkl", metadata_path="metadata.json"):
        self.model = joblib.load(model_path)
        with open(metadata_path, 'r') as f:
            self.metadata = json.load(f)
    
    def predict(self, input_data):
        """Make prediction on input data"""
        if isinstance(input_data, dict):
            input_df = pd.DataFrame([input_data])
        else:
            input_df = pd.DataFrame(input_data)
        
        prediction = self.model.predict(input_df)
        probability = None
        
        if hasattr(self.model, 'predict_proba'):
            probability = self.model.predict_proba(input_df)
        
        return {
            'prediction': prediction.tolist(),
            'probability': probability.tolist() if probability is not None else None,
            'model_version': self.metadata.get('version', 'unknown')
        }

if __name__ == "__main__":
    inference = ModelInference()
    # Example usage
    sample_input = {"feature1": 1.0, "feature2": 2.0}
    result = inference.predict(sample_input)
    print(result)
'''
        
        script_path = os.path.join(self.artifacts_dir, "inference.py")
        with open(script_path, 'w') as f:
            f.write(inference_script)
    
    def create_dockerfile(self):
        """Create Dockerfile for model deployment"""
        dockerfile_content = '''
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "inference.py"]
'''
        
        dockerfile_path = os.path.join(self.artifacts_dir, "Dockerfile")
        with open(dockerfile_path, 'w') as f:
            f.write(dockerfile_content)
    
    def create_archive(self):
        """Create tar archive of all artifacts"""
        archive_name = f"model_package_{datetime.now().strftime('%Y%m%d_%H%M%S')}.tar.gz"
        
        with tarfile.open(archive_name, "w:gz") as tar:
            tar.add(self.artifacts_dir, arcname=".")
        
        return archive_name
```

### 6. Model Monitoring and Maintenance

#### Model Performance Monitoring
```python
# model_monitoring.py
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import logging
from scipy import stats

class ModelMonitor:
    def __init__(self, model_name, reference_data, performance_threshold=0.8):
        self.model_name = model_name
        self.reference_data = reference_data
        self.performance_threshold = performance_threshold
        self.logger = logging.getLogger(__name__)
        self.prediction_log = []
    
    def log_prediction(self, input_data, prediction, actual=None, timestamp=None):
        """Log prediction for monitoring"""
        if timestamp is None:
            timestamp = datetime.now()
        
        log_entry = {
            'timestamp': timestamp,
            'input_data': input_data,
            'prediction': prediction,
            'actual': actual
        }
        
        self.prediction_log.append(log_entry)
        
        # Check for performance degradation if actual is available
        if actual is not None:
            self.check_performance_degradation()
    
    def detect_data_drift(self, current_data, feature_columns, drift_threshold=0.05):
        """Detect data drift using statistical tests"""
        drift_results = {}
        
        for feature in feature_columns:
            if feature in self.reference_data.columns and feature in current_data.columns:
                # Perform Kolmogorov-Smirnov test
                ks_stat, p_value = stats.ks_2samp(
                    self.reference_data[feature].dropna(),
                    current_data[feature].dropna()
                )
                
                drift_detected = p_value < drift_threshold
                
                drift_results[feature] = {
                    'drift_detected': drift_detected,
                    'p_value': p_value,
                    'ks_statistic': ks_stat
                }
                
                if drift_detected:
                    self.logger.warning(
                        f"Data drift detected for feature {feature}: "
                        f"p-value={p_value:.4f}, KS-stat={ks_stat:.4f}"
                    )
        
        return drift_results
    
    def check_performance_degradation(self, window_size=100):
        """Check for model performance degradation"""
        if len(self.prediction_log) < window_size:
            return
        
        # Get recent predictions with actuals
        recent_predictions = [
            entry for entry in self.prediction_log[-window_size:]
            if entry['actual'] is not None
        ]
        
        if len(recent_predictions) < 10:  # Need minimum samples
            return
        
        # Calculate recent accuracy
        correct_predictions = sum(
            1 for entry in recent_predictions
            if entry['prediction'] == entry['actual']
        )
        recent_accuracy = correct_predictions / len(recent_predictions)
        
        if recent_accuracy < self.performance_threshold:
            self.logger.warning(
                f"Model performance degraded: "
                f"Recent accuracy {recent_accuracy:.4f} below threshold {self.performance_threshold}"
            )
            
            # Trigger retraining alert
            self.trigger_retraining_alert(recent_accuracy)
    
    def trigger_retraining_alert(self, current_performance):
        """Trigger alert for model retraining"""
        alert_message = {
            'model_name': self.model_name,
            'alert_type': 'performance_degradation',
            'current_performance': current_performance,
            'threshold': self.performance_threshold,
            'timestamp': datetime.now().isoformat(),
            'action_required': 'model_retraining'
        }
        
        self.logger.critical(f"RETRAINING ALERT: {alert_message}")
        
        # Here you would integrate with your alerting system
        # e.g., send to Slack, email, or monitoring dashboard
    
    def generate_monitoring_report(self, days=7):
        """Generate monitoring report for specified period"""
        cutoff_date = datetime.now() - timedelta(days=days)
        
        recent_logs = [
            entry for entry in self.prediction_log
            if entry['timestamp'] >= cutoff_date
        ]
        
        report = {
            'model_name': self.model_name,
            'report_period_days': days,
            'total_predictions': len(recent_logs),
            'predictions_with_actuals': len([
                entry for entry in recent_logs if entry['actual'] is not None
            ])
        }
        
        # Calculate performance metrics if actuals are available
        predictions_with_actuals = [
            entry for entry in recent_logs if entry['actual'] is not None
        ]
        
        if predictions_with_actuals:
            correct = sum(
                1 for entry in predictions_with_actuals
                if entry['prediction'] == entry['actual']
            )
            report['accuracy'] = correct / len(predictions_with_actuals)
        
        return report
```

### 7. Model Retirement

#### Model Retirement Process
```python
# model_retirement.py
from datetime import datetime
import json
import os

class ModelRetirement:
    def __init__(self, model_registry, deployment_manager):
        self.model_registry = model_registry
        self.deployment_manager = deployment_manager
    
    def retire_model(self, model_name, version, reason, replacement_model=None):
        """Retire a model version"""
        retirement_info = {
            'model_name': model_name,
            'version': version,
            'retirement_date': datetime.now().isoformat(),
            'reason': reason,
            'replacement_model': replacement_model,
            'retired_by': 'system'  # or user ID
        }
        
        # Update model registry
        self.model_registry.update_status(model_name, version, 'retired')
        self.model_registry.add_retirement_info(model_name, version, retirement_info)
        
        # Remove from active deployment
        self.deployment_manager.undeploy_model(model_name, version)
        
        # Archive model artifacts
        self.archive_model_artifacts(model_name, version)
        
        # Generate retirement report
        return self.generate_retirement_report(retirement_info)
    
    def archive_model_artifacts(self, model_name, version):
        """Archive model artifacts for compliance"""
        archive_path = f"archived_models/{model_name}/v{version}"
        os.makedirs(archive_path, exist_ok=True)
        
        # Move artifacts to archive location
        # Implementation depends on your storage system
        pass
    
    def generate_retirement_report(self, retirement_info):
        """Generate model retirement report"""
        report = {
            'retirement_summary': retirement_info,
            'compliance_info': {
                'data_retention_period': '7_years',
                'audit_trail_preserved': True,
                'artifacts_archived': True
            },
            'impact_assessment': {
                'affected_services': [],  # List of services using this model
                'migration_status': 'completed' if retirement_info['replacement_model'] else 'pending'
            }
        }
        
        return report
```

## Model Lifecycle Automation

### CI/CD Pipeline for Model Lifecycle
```yaml
# .github/workflows/model-lifecycle.yml
name: Model Lifecycle Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

jobs:
  data-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Validate data schema
        run: |
          python scripts/validate_data_schema.py
      - name: Check data quality
        run: |
          python scripts/check_data_quality.py
      - name: Detect data drift
        run: |
          python scripts/detect_data_drift.py

  model-training:
    needs: data-validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Train models
        run: |
          python scripts/train_models.py
      - name: Validate model performance
        run: |
          python scripts/validate_model.py
      - name: Upload model artifacts
        uses: actions/upload-artifact@v3
        with:
          name: model-artifacts
          path: artifacts/

  model-deployment:
    needs: model-training
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Download model artifacts
        uses: actions/download-artifact@v3
        with:
          name: model-artifacts
          path: artifacts/
      - name: Package model
        run: |
          python scripts/package_model.py
      - name: Deploy to staging
        run: |
          python scripts/deploy_model.py --environment staging
      - name: Run integration tests
        run: |
          python scripts/integration_tests.py --environment staging
      - name: Deploy to production
        if: success()
        run: |
          python scripts/deploy_model.py --environment production

  model-monitoring:
    needs: model-deployment
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Setup monitoring
        run: |
          python scripts/setup_monitoring.py
      - name: Configure alerts
        run: |
          python scripts/configure_alerts.py
```

## Best Practices

### Model Lifecycle Best Practices

1. **Version Everything**
   - Code, data, models, configurations
   - Use semantic versioning for models
   - Maintain backward compatibility

2. **Automate Testing**
   - Data validation tests
   - Model performance tests
   - Integration tests
   - A/B testing in production

3. **Implement Monitoring**
   - Performance monitoring
   - Data drift detection
   - Infrastructure monitoring
   - Business metrics tracking

4. **Ensure Reproducibility**
   - Fixed random seeds
   - Environment management
   - Dependency pinning
   - Containerization

5. **Document Everything**
   - Model cards
   - API documentation
   - Deployment procedures
   - Troubleshooting guides

## Conclusion

Effective model lifecycle management is crucial for maintaining reliable, scalable, and compliant ML systems in production. By implementing proper processes, automation, and monitoring throughout the model lifecycle, organizations can ensure their ML models continue to deliver business value while maintaining quality and compliance standards.