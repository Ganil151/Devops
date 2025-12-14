# Experiment Tracking

## Overview

Experiment tracking involves systematically recording, organizing, and analyzing machine learning experiments to enable reproducibility, comparison, and optimization of model development workflows.

## MLflow Integration

### MLflow Setup and Configuration
```python
# mlflow_setup.py
import mlflow
import mlflow.sklearn
import mlflow.tensorflow
import mlflow.pytorch
from mlflow.tracking import MlflowClient
import os

class MLflowExperimentManager:
    def __init__(self, tracking_uri=None, experiment_name="default"):
        if tracking_uri:
            mlflow.set_tracking_uri(tracking_uri)
        
        self.client = MlflowClient()
        self.experiment_name = experiment_name
        
        # Create experiment if it doesn't exist
        try:
            self.experiment_id = self.client.create_experiment(experiment_name)
        except:
            experiment = self.client.get_experiment_by_name(experiment_name)
            self.experiment_id = experiment.experiment_id
        
        mlflow.set_experiment(experiment_name)
    
    def start_run(self, run_name=None, tags=None):
        """Start MLflow run with optional name and tags"""
        run = mlflow.start_run(run_name=run_name, tags=tags)
        return run
    
    def log_parameters(self, params):
        """Log parameters to MLflow"""
        for key, value in params.items():
            mlflow.log_param(key, value)
    
    def log_metrics(self, metrics, step=None):
        """Log metrics to MLflow"""
        for key, value in metrics.items():
            mlflow.log_metric(key, value, step=step)
    
    def log_artifacts(self, artifact_path, local_path):
        """Log artifacts to MLflow"""
        mlflow.log_artifacts(local_path, artifact_path)
    
    def log_model(self, model, artifact_path, model_type="sklearn"):
        """Log model to MLflow"""
        if model_type == "sklearn":
            mlflow.sklearn.log_model(model, artifact_path)
        elif model_type == "tensorflow":
            mlflow.tensorflow.log_model(model, artifact_path)
        elif model_type == "pytorch":
            mlflow.pytorch.log_model(model, artifact_path)
    
    def search_runs(self, filter_string="", order_by=None, max_results=1000):
        """Search runs with filters"""
        runs = self.client.search_runs(
            experiment_ids=[self.experiment_id],
            filter_string=filter_string,
            order_by=order_by,
            max_results=max_results
        )
        return runs
    
    def get_best_run(self, metric_name, ascending=False):
        """Get best run based on metric"""
        order_by = f"metrics.{metric_name} {'ASC' if ascending else 'DESC'}"
        runs = self.search_runs(order_by=[order_by], max_results=1)
        return runs[0] if runs else None
```

### Comprehensive Experiment Logging
```python
# experiment_logging.py
import mlflow
import json
import pickle
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import pandas as pd
import numpy as np

class ComprehensiveExperimentLogger:
    def __init__(self, experiment_manager):
        self.experiment_manager = experiment_manager
    
    def log_dataset_info(self, X_train, X_test, y_train, y_test):
        """Log comprehensive dataset information"""
        dataset_info = {
            "train_samples": len(X_train),
            "test_samples": len(X_test),
            "features": X_train.shape[1] if hasattr(X_train, 'shape') else len(X_train.columns),
            "train_target_distribution": dict(pd.Series(y_train).value_counts()),
            "test_target_distribution": dict(pd.Series(y_test).value_counts())
        }
        
        # Log as parameters
        for key, value in dataset_info.items():
            if isinstance(value, dict):
                mlflow.log_param(key, json.dumps(value))
            else:
                mlflow.log_param(key, value)
        
        # Create and log dataset summary
        summary_df = pd.DataFrame({
            'Dataset': ['Train', 'Test'],
            'Samples': [dataset_info['train_samples'], dataset_info['test_samples']],
            'Features': [dataset_info['features'], dataset_info['features']]
        })
        
        summary_df.to_csv("dataset_summary.csv", index=False)
        mlflow.log_artifact("dataset_summary.csv")
        
        return dataset_info
    
    def log_model_architecture(self, model):
        """Log model architecture and parameters"""
        model_info = {
            "model_type": type(model).__name__,
            "model_module": type(model).__module__
        }
        
        # Get model parameters if available
        if hasattr(model, 'get_params'):
            model_params = model.get_params()
            for key, value in model_params.items():
                mlflow.log_param(f"model_{key}", value)
        
        # Log model info
        mlflow.log_param("model_type", model_info["model_type"])
        mlflow.log_param("model_module", model_info["model_module"])
        
        # Save model summary
        with open("model_info.json", "w") as f:
            json.dump(model_info, f, indent=2, default=str)
        mlflow.log_artifact("model_info.json")
        
        return model_info
    
    def log_training_metrics(self, y_true, y_pred, y_pred_proba=None, prefix=""):
        """Log comprehensive training metrics"""
        from sklearn.metrics import (
            accuracy_score, precision_score, recall_score, f1_score,
            roc_auc_score, log_loss, mean_squared_error, mean_absolute_error
        )
        
        metrics = {}
        
        # Classification metrics
        if len(np.unique(y_true)) <= 10:  # Assume classification
            metrics[f"{prefix}accuracy"] = accuracy_score(y_true, y_pred)
            metrics[f"{prefix}precision"] = precision_score(y_true, y_pred, average='weighted')
            metrics[f"{prefix}recall"] = recall_score(y_true, y_pred, average='weighted')
            metrics[f"{prefix}f1_score"] = f1_score(y_true, y_pred, average='weighted')
            
            if y_pred_proba is not None:
                if len(np.unique(y_true)) == 2:  # Binary classification
                    metrics[f"{prefix}roc_auc"] = roc_auc_score(y_true, y_pred_proba[:, 1])
                else:  # Multi-class
                    metrics[f"{prefix}roc_auc"] = roc_auc_score(y_true, y_pred_proba, multi_class='ovr')
                
                metrics[f"{prefix}log_loss"] = log_loss(y_true, y_pred_proba)
        
        # Regression metrics
        else:
            metrics[f"{prefix}mse"] = mean_squared_error(y_true, y_pred)
            metrics[f"{prefix}mae"] = mean_absolute_error(y_true, y_pred)
            metrics[f"{prefix}rmse"] = np.sqrt(mean_squared_error(y_true, y_pred))
        
        # Log all metrics
        for key, value in metrics.items():
            mlflow.log_metric(key, value)
        
        return metrics
    
    def log_feature_importance(self, model, feature_names):
        """Log feature importance if available"""
        if hasattr(model, 'feature_importances_'):
            importance_df = pd.DataFrame({
                'feature': feature_names,
                'importance': model.feature_importances_
            }).sort_values('importance', ascending=False)
            
            # Save feature importance
            importance_df.to_csv("feature_importance.csv", index=False)
            mlflow.log_artifact("feature_importance.csv")
            
            # Create and log feature importance plot
            plt.figure(figsize=(10, 8))
            top_features = importance_df.head(20)
            sns.barplot(data=top_features, x='importance', y='feature')
            plt.title('Top 20 Feature Importances')
            plt.tight_layout()
            plt.savefig("feature_importance_plot.png", dpi=300, bbox_inches='tight')
            mlflow.log_artifact("feature_importance_plot.png")
            plt.close()
            
            return importance_df
        
        return None
    
    def log_confusion_matrix(self, y_true, y_pred, class_names=None):
        """Log confusion matrix"""
        cm = confusion_matrix(y_true, y_pred)
        
        # Create confusion matrix plot
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                   xticklabels=class_names, yticklabels=class_names)
        plt.title('Confusion Matrix')
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        plt.tight_layout()
        plt.savefig("confusion_matrix.png", dpi=300, bbox_inches='tight')
        mlflow.log_artifact("confusion_matrix.png")
        plt.close()
        
        # Save confusion matrix data
        cm_df = pd.DataFrame(cm, index=class_names, columns=class_names)
        cm_df.to_csv("confusion_matrix.csv")
        mlflow.log_artifact("confusion_matrix.csv")
        
        return cm
    
    def log_learning_curves(self, train_scores, val_scores, train_sizes=None):
        """Log learning curves"""
        if train_sizes is None:
            train_sizes = range(1, len(train_scores) + 1)
        
        plt.figure(figsize=(10, 6))
        plt.plot(train_sizes, train_scores, 'o-', label='Training Score')
        plt.plot(train_sizes, val_scores, 'o-', label='Validation Score')
        plt.xlabel('Training Set Size' if len(train_sizes) > 10 else 'Epoch')
        plt.ylabel('Score')
        plt.title('Learning Curves')
        plt.legend()
        plt.grid(True)
        plt.tight_layout()
        plt.savefig("learning_curves.png", dpi=300, bbox_inches='tight')
        mlflow.log_artifact("learning_curves.png")
        plt.close()
        
        # Log final scores as metrics
        mlflow.log_metric("final_train_score", train_scores[-1])
        mlflow.log_metric("final_val_score", val_scores[-1])
    
    def log_hyperparameter_search(self, search_results):
        """Log hyperparameter search results"""
        # Convert search results to DataFrame
        results_df = pd.DataFrame(search_results)
        results_df.to_csv("hyperparameter_search_results.csv", index=False)
        mlflow.log_artifact("hyperparameter_search_results.csv")
        
        # Log best parameters
        if 'best_params' in search_results:
            for param, value in search_results['best_params'].items():
                mlflow.log_param(f"best_{param}", value)
        
        # Log search statistics
        if 'cv_results' in search_results:
            mlflow.log_metric("best_cv_score", search_results['best_score'])
            mlflow.log_metric("n_candidates", len(search_results['cv_results']['params']))
```

## Weights & Biases Integration

### W&B Experiment Tracking
```python
# wandb_integration.py
import wandb
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

class WandBExperimentTracker:
    def __init__(self, project_name, entity=None):
        self.project_name = project_name
        self.entity = entity
        self.run = None
    
    def start_experiment(self, config, run_name=None, tags=None):
        """Start W&B experiment"""
        self.run = wandb.init(
            project=self.project_name,
            entity=self.entity,
            name=run_name,
            config=config,
            tags=tags
        )
        return self.run
    
    def log_metrics(self, metrics, step=None):
        """Log metrics to W&B"""
        wandb.log(metrics, step=step)
    
    def log_model_performance(self, y_true, y_pred, y_pred_proba=None, class_names=None):
        """Log comprehensive model performance"""
        from sklearn.metrics import classification_report, confusion_matrix
        
        # Log confusion matrix
        if class_names:
            wandb.log({
                "confusion_matrix": wandb.plot.confusion_matrix(
                    probs=None,
                    y_true=y_true,
                    preds=y_pred,
                    class_names=class_names
                )
            })
        
        # Log ROC curve for binary classification
        if y_pred_proba is not None and len(np.unique(y_true)) == 2:
            wandb.log({
                "roc_curve": wandb.plot.roc_curve(y_true, y_pred_proba)
            })
        
        # Log precision-recall curve
        if y_pred_proba is not None:
            wandb.log({
                "pr_curve": wandb.plot.pr_curve(y_true, y_pred_proba)
            })
    
    def log_feature_importance(self, feature_names, importances):
        """Log feature importance"""
        importance_df = pd.DataFrame({
            'feature': feature_names,
            'importance': importances
        }).sort_values('importance', ascending=False)
        
        # Create bar plot
        fig, ax = plt.subplots(figsize=(10, 8))
        top_features = importance_df.head(20)
        ax.barh(range(len(top_features)), top_features['importance'])
        ax.set_yticks(range(len(top_features)))
        ax.set_yticklabels(top_features['feature'])
        ax.set_xlabel('Importance')
        ax.set_title('Feature Importance')
        
        wandb.log({"feature_importance": wandb.Image(fig)})
        plt.close(fig)
        
        # Log as table
        wandb.log({"feature_importance_table": wandb.Table(dataframe=importance_df)})
    
    def log_hyperparameter_sweep(self, sweep_config):
        """Create and run hyperparameter sweep"""
        sweep_id = wandb.sweep(sweep_config, project=self.project_name)
        return sweep_id
    
    def log_model_artifacts(self, model, model_name="model"):
        """Log model artifacts"""
        # Save model
        model_path = f"{model_name}.pkl"
        import joblib
        joblib.dump(model, model_path)
        
        # Log as artifact
        artifact = wandb.Artifact(model_name, type="model")
        artifact.add_file(model_path)
        wandb.log_artifact(artifact)
    
    def finish_experiment(self):
        """Finish W&B experiment"""
        if self.run:
            wandb.finish()
```

## Custom Experiment Tracking

### Database-Based Tracking
```python
# custom_experiment_tracker.py
import sqlite3
import json
import pickle
import hashlib
from datetime import datetime
import pandas as pd

class CustomExperimentTracker:
    def __init__(self, db_path="experiments.db"):
        self.db_path = db_path
        self.init_database()
        self.current_experiment_id = None
    
    def init_database(self):
        """Initialize experiment tracking database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create experiments table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS experiments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status TEXT DEFAULT 'running'
            )
        ''')
        
        # Create runs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS runs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                experiment_id INTEGER,
                name TEXT,
                parameters TEXT,
                metrics TEXT,
                artifacts TEXT,
                model_hash TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                duration_seconds REAL,
                status TEXT DEFAULT 'running',
                FOREIGN KEY (experiment_id) REFERENCES experiments (id)
            )
        ''')
        
        # Create metrics_history table for time series metrics
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS metrics_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                run_id INTEGER,
                metric_name TEXT,
                metric_value REAL,
                step INTEGER,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (run_id) REFERENCES runs (id)
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def create_experiment(self, name, description=None):
        """Create new experiment"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO experiments (name, description) VALUES (?, ?)",
            (name, description)
        )
        
        experiment_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        self.current_experiment_id = experiment_id
        return experiment_id
    
    def start_run(self, experiment_id=None, run_name=None, parameters=None):
        """Start new run"""
        if experiment_id is None:
            experiment_id = self.current_experiment_id
        
        if experiment_id is None:
            raise ValueError("No experiment specified")
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        parameters_json = json.dumps(parameters) if parameters else None
        
        cursor.execute(
            "INSERT INTO runs (experiment_id, name, parameters) VALUES (?, ?, ?)",
            (experiment_id, run_name, parameters_json)
        )
        
        run_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return run_id
    
    def log_metrics(self, run_id, metrics, step=None):
        """Log metrics for a run"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Update run metrics
        cursor.execute("SELECT metrics FROM runs WHERE id = ?", (run_id,))
        current_metrics = cursor.fetchone()[0]
        
        if current_metrics:
            current_metrics = json.loads(current_metrics)
            current_metrics.update(metrics)
        else:
            current_metrics = metrics
        
        cursor.execute(
            "UPDATE runs SET metrics = ? WHERE id = ?",
            (json.dumps(current_metrics), run_id)
        )
        
        # Log to metrics history
        for metric_name, metric_value in metrics.items():
            cursor.execute(
                "INSERT INTO metrics_history (run_id, metric_name, metric_value, step) VALUES (?, ?, ?, ?)",
                (run_id, metric_name, metric_value, step)
            )
        
        conn.commit()
        conn.close()
    
    def log_model(self, run_id, model, model_name="model"):
        """Log model for a run"""
        # Serialize model
        model_bytes = pickle.dumps(model)
        model_hash = hashlib.sha256(model_bytes).hexdigest()
        
        # Save model file
        model_path = f"models/{model_hash}.pkl"
        import os
        os.makedirs("models", exist_ok=True)
        
        with open(model_path, 'wb') as f:
            f.write(model_bytes)
        
        # Update run with model info
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("SELECT artifacts FROM runs WHERE id = ?", (run_id,))
        current_artifacts = cursor.fetchone()[0]
        
        if current_artifacts:
            artifacts = json.loads(current_artifacts)
        else:
            artifacts = {}
        
        artifacts[model_name] = {
            'path': model_path,
            'hash': model_hash,
            'type': 'model'
        }
        
        cursor.execute(
            "UPDATE runs SET artifacts = ?, model_hash = ? WHERE id = ?",
            (json.dumps(artifacts), model_hash, run_id)
        )
        
        conn.commit()
        conn.close()
        
        return model_hash
    
    def finish_run(self, run_id, status='completed'):
        """Finish a run"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Calculate duration
        cursor.execute("SELECT created_at FROM runs WHERE id = ?", (run_id,))
        start_time = datetime.fromisoformat(cursor.fetchone()[0])
        duration = (datetime.now() - start_time).total_seconds()
        
        cursor.execute(
            "UPDATE runs SET status = ?, duration_seconds = ? WHERE id = ?",
            (status, duration, run_id)
        )
        
        conn.commit()
        conn.close()
    
    def get_experiment_runs(self, experiment_id):
        """Get all runs for an experiment"""
        conn = sqlite3.connect(self.db_path)
        
        query = '''
            SELECT id, name, parameters, metrics, created_at, duration_seconds, status
            FROM runs 
            WHERE experiment_id = ?
            ORDER BY created_at DESC
        '''
        
        df = pd.read_sql_query(query, conn, params=(experiment_id,))
        conn.close()
        
        return df
    
    def get_best_run(self, experiment_id, metric_name, ascending=False):
        """Get best run based on metric"""
        runs_df = self.get_experiment_runs(experiment_id)
        
        best_run = None
        best_value = float('inf') if ascending else float('-inf')
        
        for _, run in runs_df.iterrows():
            if run['metrics']:
                metrics = json.loads(run['metrics'])
                if metric_name in metrics:
                    value = metrics[metric_name]
                    if (ascending and value < best_value) or (not ascending and value > best_value):
                        best_value = value
                        best_run = run
        
        return best_run
    
    def compare_runs(self, run_ids):
        """Compare multiple runs"""
        conn = sqlite3.connect(self.db_path)
        
        placeholders = ','.join(['?' for _ in run_ids])
        query = f'''
            SELECT id, name, parameters, metrics, duration_seconds, status
            FROM runs 
            WHERE id IN ({placeholders})
        '''
        
        df = pd.read_sql_query(query, conn, params=run_ids)
        conn.close()
        
        # Parse JSON columns
        df['parameters'] = df['parameters'].apply(lambda x: json.loads(x) if x else {})
        df['metrics'] = df['metrics'].apply(lambda x: json.loads(x) if x else {})
        
        return df
```

## Experiment Analysis and Visualization

### Experiment Analytics
```python
# experiment_analytics.py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

class ExperimentAnalytics:
    def __init__(self, experiment_tracker):
        self.tracker = experiment_tracker
    
    def analyze_hyperparameter_impact(self, experiment_id, target_metric):
        """Analyze impact of hyperparameters on target metric"""
        runs_df = self.tracker.get_experiment_runs(experiment_id)
        
        # Extract parameters and metrics
        param_data = []
        metric_values = []
        
        for _, run in runs_df.iterrows():
            if run['parameters'] and run['metrics']:
                params = json.loads(run['parameters'])
                metrics = json.loads(run['metrics'])
                
                if target_metric in metrics:
                    param_data.append(params)
                    metric_values.append(metrics[target_metric])
        
        if not param_data:
            return None
        
        # Convert to DataFrame
        params_df = pd.DataFrame(param_data)
        params_df[target_metric] = metric_values
        
        # Calculate correlations
        correlations = {}
        for col in params_df.columns:
            if col != target_metric and pd.api.types.is_numeric_dtype(params_df[col]):
                corr = params_df[col].corr(params_df[target_metric])
                correlations[col] = corr
        
        # Sort by absolute correlation
        sorted_correlations = sorted(correlations.items(), key=lambda x: abs(x[1]), reverse=True)
        
        return {
            'correlations': sorted_correlations,
            'data': params_df
        }
    
    def plot_parameter_importance(self, experiment_id, target_metric):
        """Plot parameter importance for target metric"""
        analysis = self.analyze_hyperparameter_impact(experiment_id, target_metric)
        
        if not analysis:
            print("No data available for analysis")
            return
        
        correlations = analysis['correlations']
        
        if not correlations:
            print("No numeric parameters found")
            return
        
        # Create bar plot
        params, corrs = zip(*correlations)
        
        plt.figure(figsize=(10, 6))
        colors = ['red' if c < 0 else 'blue' for c in corrs]
        plt.barh(range(len(params)), corrs, color=colors)
        plt.yticks(range(len(params)), params)
        plt.xlabel(f'Correlation with {target_metric}')
        plt.title(f'Parameter Impact on {target_metric}')
        plt.axvline(x=0, color='black', linestyle='-', alpha=0.3)
        plt.tight_layout()
        plt.show()
    
    def plot_metric_evolution(self, run_id, metric_names=None):
        """Plot metric evolution over time"""
        conn = sqlite3.connect(self.tracker.db_path)
        
        if metric_names:
            metric_filter = "AND metric_name IN ({})".format(','.join(['?' for _ in metric_names]))
            params = [run_id] + metric_names
        else:
            metric_filter = ""
            params = [run_id]
        
        query = f'''
            SELECT metric_name, metric_value, step, timestamp
            FROM metrics_history 
            WHERE run_id = ? {metric_filter}
            ORDER BY metric_name, step
        '''
        
        df = pd.read_sql_query(query, conn, params=params)
        conn.close()
        
        if df.empty:
            print("No metric history found")
            return
        
        # Plot metrics
        fig, axes = plt.subplots(len(df['metric_name'].unique()), 1, 
                                figsize=(12, 4 * len(df['metric_name'].unique())))
        
        if len(df['metric_name'].unique()) == 1:
            axes = [axes]
        
        for i, metric in enumerate(df['metric_name'].unique()):
            metric_data = df[df['metric_name'] == metric]
            axes[i].plot(metric_data['step'], metric_data['metric_value'], marker='o')
            axes[i].set_title(f'{metric} Evolution')
            axes[i].set_xlabel('Step')
            axes[i].set_ylabel(metric)
            axes[i].grid(True)
        
        plt.tight_layout()
        plt.show()
    
    def compare_experiments(self, experiment_ids, metric_name):
        """Compare multiple experiments"""
        all_runs = []
        
        for exp_id in experiment_ids:
            runs_df = self.tracker.get_experiment_runs(exp_id)
            runs_df['experiment_id'] = exp_id
            all_runs.append(runs_df)
        
        combined_df = pd.concat(all_runs, ignore_index=True)
        
        # Extract metric values
        metric_values = []
        experiment_labels = []
        
        for _, run in combined_df.iterrows():
            if run['metrics']:
                metrics = json.loads(run['metrics'])
                if metric_name in metrics:
                    metric_values.append(metrics[metric_name])
                    experiment_labels.append(f"Exp_{run['experiment_id']}")
        
        if not metric_values:
            print(f"No {metric_name} values found")
            return
        
        # Create comparison plot
        plt.figure(figsize=(10, 6))
        
        # Box plot
        data_by_exp = {}
        for exp_id in experiment_ids:
            exp_values = [v for v, l in zip(metric_values, experiment_labels) 
                         if l == f"Exp_{exp_id}"]
            data_by_exp[f"Exp_{exp_id}"] = exp_values
        
        plt.boxplot(data_by_exp.values(), labels=data_by_exp.keys())
        plt.ylabel(metric_name)
        plt.title(f'{metric_name} Comparison Across Experiments')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.show()
        
        return data_by_exp
    
    def generate_experiment_report(self, experiment_id):
        """Generate comprehensive experiment report"""
        runs_df = self.tracker.get_experiment_runs(experiment_id)
        
        report = {
            'experiment_id': experiment_id,
            'total_runs': len(runs_df),
            'successful_runs': len(runs_df[runs_df['status'] == 'completed']),
            'failed_runs': len(runs_df[runs_df['status'] == 'failed']),
            'average_duration': runs_df['duration_seconds'].mean(),
            'metrics_summary': {}
        }
        
        # Analyze metrics across all runs
        all_metrics = {}
        for _, run in runs_df.iterrows():
            if run['metrics']:
                metrics = json.loads(run['metrics'])
                for metric_name, value in metrics.items():
                    if metric_name not in all_metrics:
                        all_metrics[metric_name] = []
                    all_metrics[metric_name].append(value)
        
        # Calculate statistics for each metric
        for metric_name, values in all_metrics.items():
            report['metrics_summary'][metric_name] = {
                'count': len(values),
                'mean': np.mean(values),
                'std': np.std(values),
                'min': np.min(values),
                'max': np.max(values),
                'median': np.median(values)
            }
        
        return report
```

## Automated Experiment Management

### Experiment Automation
```python
# experiment_automation.py
import itertools
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

class ExperimentAutomation:
    def __init__(self, experiment_tracker):
        self.tracker = experiment_tracker
    
    def grid_search_experiments(self, experiment_name, param_grid, train_func, max_workers=4):
        """Run grid search experiments"""
        experiment_id = self.tracker.create_experiment(
            name=experiment_name,
            description=f"Grid search with {len(param_grid)} parameters"
        )
        
        # Generate all parameter combinations
        param_names = list(param_grid.keys())
        param_values = list(param_grid.values())
        param_combinations = list(itertools.product(*param_values))
        
        print(f"Running {len(param_combinations)} experiments...")
        
        def run_single_experiment(params):
            param_dict = dict(zip(param_names, params))
            
            run_id = self.tracker.start_run(
                experiment_id=experiment_id,
                run_name=f"grid_search_{hash(str(param_dict))}",
                parameters=param_dict
            )
            
            try:
                # Run training function
                results = train_func(param_dict)
                
                # Log results
                if 'metrics' in results:
                    self.tracker.log_metrics(run_id, results['metrics'])
                
                if 'model' in results:
                    self.tracker.log_model(run_id, results['model'])
                
                self.tracker.finish_run(run_id, 'completed')
                
                return {
                    'run_id': run_id,
                    'params': param_dict,
                    'results': results,
                    'status': 'completed'
                }
                
            except Exception as e:
                self.tracker.finish_run(run_id, 'failed')
                return {
                    'run_id': run_id,
                    'params': param_dict,
                    'error': str(e),
                    'status': 'failed'
                }
        
        # Run experiments in parallel
        results = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_params = {
                executor.submit(run_single_experiment, params): params 
                for params in param_combinations
            }
            
            for future in as_completed(future_to_params):
                result = future.result()
                results.append(result)
                print(f"Completed experiment {len(results)}/{len(param_combinations)}")
        
        return {
            'experiment_id': experiment_id,
            'results': results,
            'total_runs': len(param_combinations),
            'successful_runs': len([r for r in results if r['status'] == 'completed'])
        }
    
    def random_search_experiments(self, experiment_name, param_distributions, 
                                 train_func, n_iter=50, max_workers=4):
        """Run random search experiments"""
        experiment_id = self.tracker.create_experiment(
            name=experiment_name,
            description=f"Random search with {n_iter} iterations"
        )
        
        def sample_parameters():
            """Sample parameters from distributions"""
            params = {}
            for param_name, distribution in param_distributions.items():
                if hasattr(distribution, 'rvs'):  # scipy distribution
                    params[param_name] = distribution.rvs()
                elif callable(distribution):  # custom function
                    params[param_name] = distribution()
                elif isinstance(distribution, list):  # choice from list
                    params[param_name] = np.random.choice(distribution)
            return params
        
        # Generate parameter samples
        param_samples = [sample_parameters() for _ in range(n_iter)]
        
        def run_single_experiment(params):
            run_id = self.tracker.start_run(
                experiment_id=experiment_id,
                run_name=f"random_search_{hash(str(params))}",
                parameters=params
            )
            
            try:
                results = train_func(params)
                
                if 'metrics' in results:
                    self.tracker.log_metrics(run_id, results['metrics'])
                
                if 'model' in results:
                    self.tracker.log_model(run_id, results['model'])
                
                self.tracker.finish_run(run_id, 'completed')
                
                return {
                    'run_id': run_id,
                    'params': params,
                    'results': results,
                    'status': 'completed'
                }
                
            except Exception as e:
                self.tracker.finish_run(run_id, 'failed')
                return {
                    'run_id': run_id,
                    'params': params,
                    'error': str(e),
                    'status': 'failed'
                }
        
        # Run experiments
        results = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_params = {
                executor.submit(run_single_experiment, params): params 
                for params in param_samples
            }
            
            for future in as_completed(future_to_params):
                result = future.result()
                results.append(result)
                print(f"Completed experiment {len(results)}/{n_iter}")
        
        return {
            'experiment_id': experiment_id,
            'results': results,
            'total_runs': n_iter,
            'successful_runs': len([r for r in results if r['status'] == 'completed'])
        }
    
    def bayesian_optimization_experiments(self, experiment_name, param_space, 
                                        train_func, n_iter=50):
        """Run Bayesian optimization experiments"""
        try:
            from skopt import gp_minimize
            from skopt.space import Real, Integer, Categorical
        except ImportError:
            raise ImportError("scikit-optimize required for Bayesian optimization")
        
        experiment_id = self.tracker.create_experiment(
            name=experiment_name,
            description=f"Bayesian optimization with {n_iter} iterations"
        )
        
        # Convert parameter space to skopt format
        dimensions = []
        param_names = []
        
        for param_name, param_config in param_space.items():
            param_names.append(param_name)
            
            if param_config['type'] == 'real':
                dimensions.append(Real(param_config['low'], param_config['high']))
            elif param_config['type'] == 'integer':
                dimensions.append(Integer(param_config['low'], param_config['high']))
            elif param_config['type'] == 'categorical':
                dimensions.append(Categorical(param_config['categories']))
        
        def objective(params):
            param_dict = dict(zip(param_names, params))
            
            run_id = self.tracker.start_run(
                experiment_id=experiment_id,
                run_name=f"bayesian_opt_{hash(str(param_dict))}",
                parameters=param_dict
            )
            
            try:
                results = train_func(param_dict)
                
                if 'metrics' in results:
                    self.tracker.log_metrics(run_id, results['metrics'])
                
                if 'model' in results:
                    self.tracker.log_model(run_id, results['model'])
                
                self.tracker.finish_run(run_id, 'completed')
                
                # Return negative value for minimization (assuming we want to maximize)
                target_metric = results['metrics'].get('accuracy', 0)
                return -target_metric
                
            except Exception as e:
                self.tracker.finish_run(run_id, 'failed')
                return 1.0  # High penalty for failed runs
        
        # Run Bayesian optimization
        result = gp_minimize(
            func=objective,
            dimensions=dimensions,
            n_calls=n_iter,
            random_state=42
        )
        
        return {
            'experiment_id': experiment_id,
            'best_params': dict(zip(param_names, result.x)),
            'best_score': -result.fun,
            'total_runs': n_iter
        }
```

## Best Practices

1. **Comprehensive Logging**: Log parameters, metrics, artifacts, and metadata
2. **Reproducibility**: Ensure experiments can be reproduced with same results
3. **Organization**: Use clear naming conventions and experiment organization
4. **Comparison**: Enable easy comparison between experiments and runs
5. **Automation**: Automate hyperparameter search and experiment management
6. **Visualization**: Create clear visualizations of experiment results
7. **Storage**: Efficiently store and manage experiment artifacts
8. **Documentation**: Document experiment goals and findings

## Conclusion

Effective experiment tracking is essential for systematic ML development. It enables reproducibility, facilitates comparison, and accelerates model improvement through organized experimentation and analysis.