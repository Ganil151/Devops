# Model Monitoring

## Overview

Model monitoring involves tracking ML model performance, data quality, and system health in production to ensure models continue to deliver accurate predictions and business value.

## Monitoring Dimensions

### 1. Model Performance Monitoring
```python
# model_performance_monitor.py
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import logging

class ModelPerformanceMonitor:
    def __init__(self, model_name, baseline_metrics):
        self.model_name = model_name
        self.baseline_metrics = baseline_metrics
        self.performance_log = []
        self.logger = logging.getLogger(__name__)
    
    def log_prediction(self, prediction, actual=None, features=None, timestamp=None):
        """Log individual prediction for monitoring"""
        if timestamp is None:
            timestamp = datetime.now()
        
        log_entry = {
            'timestamp': timestamp,
            'prediction': prediction,
            'actual': actual,
            'features': features
        }
        
        self.performance_log.append(log_entry)
        
        # Check performance if actual value is available
        if actual is not None:
            self.check_prediction_accuracy(prediction, actual)
    
    def calculate_current_metrics(self, window_hours=24):
        """Calculate current performance metrics"""
        cutoff_time = datetime.now() - timedelta(hours=window_hours)
        
        recent_logs = [
            log for log in self.performance_log 
            if log['timestamp'] >= cutoff_time and log['actual'] is not None
        ]
        
        if len(recent_logs) < 10:  # Need minimum samples
            return None
        
        predictions = [log['prediction'] for log in recent_logs]
        actuals = [log['actual'] for log in recent_logs]
        
        # Calculate metrics
        accuracy = np.mean(np.array(predictions) == np.array(actuals))
        mae = np.mean(np.abs(np.array(predictions) - np.array(actuals)))
        mse = np.mean((np.array(predictions) - np.array(actuals)) ** 2)
        
        return {
            'accuracy': accuracy,
            'mae': mae,
            'mse': mse,
            'sample_count': len(recent_logs),
            'timestamp': datetime.now()
        }
    
    def check_performance_degradation(self, threshold=0.05):
        """Check if model performance has degraded"""
        current_metrics = self.calculate_current_metrics()
        
        if current_metrics is None:
            return False
        
        # Compare with baseline
        accuracy_drop = self.baseline_metrics['accuracy'] - current_metrics['accuracy']
        
        if accuracy_drop > threshold:
            self.logger.warning(
                f"Performance degradation detected for {self.model_name}: "
                f"Accuracy dropped by {accuracy_drop:.4f}"
            )
            self.trigger_alert('performance_degradation', current_metrics)
            return True
        
        return False
    
    def trigger_alert(self, alert_type, metrics):
        """Trigger alert for performance issues"""
        alert = {
            'model_name': self.model_name,
            'alert_type': alert_type,
            'metrics': metrics,
            'timestamp': datetime.now(),
            'severity': 'high' if alert_type == 'performance_degradation' else 'medium'
        }
        
        # Send alert (integrate with your alerting system)
        self.logger.critical(f"ALERT: {alert}")
```

### 2. Data Drift Detection
```python
# data_drift_monitor.py
from scipy import stats
import numpy as np
import pandas as pd
from sklearn.metrics import jensen_shannon_distance

class DataDriftMonitor:
    def __init__(self, reference_data, feature_columns):
        self.reference_data = reference_data
        self.feature_columns = feature_columns
        self.drift_history = []
    
    def detect_drift_ks_test(self, current_data, threshold=0.05):
        """Detect drift using Kolmogorov-Smirnov test"""
        drift_results = {}
        
        for feature in self.feature_columns:
            if feature in current_data.columns and feature in self.reference_data.columns:
                # Perform KS test
                ks_stat, p_value = stats.ks_2samp(
                    self.reference_data[feature].dropna(),
                    current_data[feature].dropna()
                )
                
                drift_detected = p_value < threshold
                
                drift_results[feature] = {
                    'drift_detected': drift_detected,
                    'p_value': p_value,
                    'ks_statistic': ks_stat,
                    'method': 'ks_test'
                }
        
        return drift_results
    
    def detect_drift_psi(self, current_data, threshold=0.2):
        """Detect drift using Population Stability Index (PSI)"""
        drift_results = {}
        
        for feature in self.feature_columns:
            if feature in current_data.columns and feature in self.reference_data.columns:
                psi_value = self.calculate_psi(
                    self.reference_data[feature].dropna(),
                    current_data[feature].dropna()
                )
                
                drift_detected = psi_value > threshold
                
                drift_results[feature] = {
                    'drift_detected': drift_detected,
                    'psi_value': psi_value,
                    'method': 'psi'
                }
        
        return drift_results
    
    def calculate_psi(self, reference, current, bins=10):
        """Calculate Population Stability Index"""
        # Create bins based on reference data
        _, bin_edges = np.histogram(reference, bins=bins)
        
        # Calculate distributions
        ref_counts, _ = np.histogram(reference, bins=bin_edges)
        cur_counts, _ = np.histogram(current, bins=bin_edges)
        
        # Convert to percentages
        ref_pct = ref_counts / len(reference)
        cur_pct = cur_counts / len(current)
        
        # Avoid division by zero
        ref_pct = np.where(ref_pct == 0, 0.0001, ref_pct)
        cur_pct = np.where(cur_pct == 0, 0.0001, cur_pct)
        
        # Calculate PSI
        psi = np.sum((cur_pct - ref_pct) * np.log(cur_pct / ref_pct))
        
        return psi
    
    def detect_drift_js_distance(self, current_data, threshold=0.1):
        """Detect drift using Jensen-Shannon distance"""
        drift_results = {}
        
        for feature in self.feature_columns:
            if feature in current_data.columns and feature in self.reference_data.columns:
                # Create histograms
                ref_hist, bin_edges = np.histogram(
                    self.reference_data[feature].dropna(), bins=50, density=True
                )
                cur_hist, _ = np.histogram(
                    current_data[feature].dropna(), bins=bin_edges, density=True
                )
                
                # Normalize to create probability distributions
                ref_dist = ref_hist / np.sum(ref_hist)
                cur_dist = cur_hist / np.sum(cur_hist)
                
                # Calculate JS distance
                js_distance = jensen_shannon_distance(ref_dist, cur_dist)
                
                drift_detected = js_distance > threshold
                
                drift_results[feature] = {
                    'drift_detected': drift_detected,
                    'js_distance': js_distance,
                    'method': 'jensen_shannon'
                }
        
        return drift_results
    
    def comprehensive_drift_check(self, current_data):
        """Perform comprehensive drift detection using multiple methods"""
        results = {
            'timestamp': datetime.now(),
            'ks_test': self.detect_drift_ks_test(current_data),
            'psi': self.detect_drift_psi(current_data),
            'js_distance': self.detect_drift_js_distance(current_data)
        }
        
        # Aggregate results
        drift_features = set()
        for method_results in results.values():
            if isinstance(method_results, dict):
                for feature, result in method_results.items():
                    if result.get('drift_detected', False):
                        drift_features.add(feature)
        
        results['summary'] = {
            'drift_detected': len(drift_features) > 0,
            'affected_features': list(drift_features),
            'drift_count': len(drift_features)
        }
        
        self.drift_history.append(results)
        
        return results
```

### 3. Model Bias Monitoring
```python
# bias_monitor.py
import pandas as pd
import numpy as np
from sklearn.metrics import confusion_matrix, accuracy_score

class ModelBiasMonitor:
    def __init__(self, protected_attributes):
        self.protected_attributes = protected_attributes
        self.bias_history = []
    
    def calculate_demographic_parity(self, predictions, protected_attr):
        """Calculate demographic parity difference"""
        groups = np.unique(protected_attr)
        positive_rates = {}
        
        for group in groups:
            group_mask = protected_attr == group
            group_predictions = predictions[group_mask]
            positive_rate = np.mean(group_predictions == 1)  # Assuming binary classification
            positive_rates[group] = positive_rate
        
        # Calculate maximum difference
        rates = list(positive_rates.values())
        demographic_parity_diff = max(rates) - min(rates)
        
        return {
            'demographic_parity_difference': demographic_parity_diff,
            'group_rates': positive_rates
        }
    
    def calculate_equalized_odds(self, predictions, actuals, protected_attr):
        """Calculate equalized odds difference"""
        groups = np.unique(protected_attr)
        tpr_by_group = {}
        fpr_by_group = {}
        
        for group in groups:
            group_mask = protected_attr == group
            group_predictions = predictions[group_mask]
            group_actuals = actuals[group_mask]
            
            # Calculate confusion matrix
            tn, fp, fn, tp = confusion_matrix(group_actuals, group_predictions).ravel()
            
            # Calculate TPR and FPR
            tpr = tp / (tp + fn) if (tp + fn) > 0 else 0
            fpr = fp / (fp + tn) if (fp + tn) > 0 else 0
            
            tpr_by_group[group] = tpr
            fpr_by_group[group] = fpr
        
        # Calculate differences
        tpr_values = list(tpr_by_group.values())
        fpr_values = list(fpr_by_group.values())
        
        tpr_diff = max(tpr_values) - min(tpr_values)
        fpr_diff = max(fpr_values) - min(fpr_values)
        
        return {
            'tpr_difference': tpr_diff,
            'fpr_difference': fpr_diff,
            'tpr_by_group': tpr_by_group,
            'fpr_by_group': fpr_by_group
        }
    
    def calculate_accuracy_parity(self, predictions, actuals, protected_attr):
        """Calculate accuracy parity across groups"""
        groups = np.unique(protected_attr)
        accuracy_by_group = {}
        
        for group in groups:
            group_mask = protected_attr == group
            group_predictions = predictions[group_mask]
            group_actuals = actuals[group_mask]
            
            accuracy = accuracy_score(group_actuals, group_predictions)
            accuracy_by_group[group] = accuracy
        
        # Calculate difference
        accuracies = list(accuracy_by_group.values())
        accuracy_diff = max(accuracies) - min(accuracies)
        
        return {
            'accuracy_difference': accuracy_diff,
            'accuracy_by_group': accuracy_by_group
        }
    
    def comprehensive_bias_check(self, predictions, actuals, protected_attributes_data):
        """Perform comprehensive bias analysis"""
        bias_results = {
            'timestamp': datetime.now(),
            'bias_metrics': {}
        }
        
        for attr_name in self.protected_attributes:
            if attr_name in protected_attributes_data.columns:
                attr_values = protected_attributes_data[attr_name]
                
                # Calculate various bias metrics
                demographic_parity = self.calculate_demographic_parity(predictions, attr_values)
                equalized_odds = self.calculate_equalized_odds(predictions, actuals, attr_values)
                accuracy_parity = self.calculate_accuracy_parity(predictions, actuals, attr_values)
                
                bias_results['bias_metrics'][attr_name] = {
                    'demographic_parity': demographic_parity,
                    'equalized_odds': equalized_odds,
                    'accuracy_parity': accuracy_parity
                }
        
        # Check for bias violations
        bias_violations = []
        for attr_name, metrics in bias_results['bias_metrics'].items():
            if metrics['demographic_parity']['demographic_parity_difference'] > 0.1:
                bias_violations.append(f"{attr_name}: demographic parity violation")
            
            if metrics['equalized_odds']['tpr_difference'] > 0.1:
                bias_violations.append(f"{attr_name}: TPR difference violation")
            
            if metrics['accuracy_parity']['accuracy_difference'] > 0.05:
                bias_violations.append(f"{attr_name}: accuracy parity violation")
        
        bias_results['violations'] = bias_violations
        bias_results['bias_detected'] = len(bias_violations) > 0
        
        self.bias_history.append(bias_results)
        
        return bias_results
```

## System Health Monitoring

### Infrastructure Monitoring
```python
# system_monitor.py
import psutil
import GPUtil
import time
from datetime import datetime

class SystemHealthMonitor:
    def __init__(self):
        self.metrics_history = []
    
    def collect_cpu_metrics(self):
        """Collect CPU metrics"""
        return {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'cpu_count': psutil.cpu_count(),
            'load_average': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else None
        }
    
    def collect_memory_metrics(self):
        """Collect memory metrics"""
        memory = psutil.virtual_memory()
        return {
            'memory_total': memory.total,
            'memory_available': memory.available,
            'memory_percent': memory.percent,
            'memory_used': memory.used
        }
    
    def collect_gpu_metrics(self):
        """Collect GPU metrics"""
        try:
            gpus = GPUtil.getGPUs()
            gpu_metrics = []
            
            for gpu in gpus:
                gpu_metrics.append({
                    'gpu_id': gpu.id,
                    'gpu_name': gpu.name,
                    'gpu_load': gpu.load * 100,
                    'gpu_memory_used': gpu.memoryUsed,
                    'gpu_memory_total': gpu.memoryTotal,
                    'gpu_memory_percent': (gpu.memoryUsed / gpu.memoryTotal) * 100,
                    'gpu_temperature': gpu.temperature
                })
            
            return gpu_metrics
        except:
            return []
    
    def collect_disk_metrics(self):
        """Collect disk metrics"""
        disk_usage = psutil.disk_usage('/')
        return {
            'disk_total': disk_usage.total,
            'disk_used': disk_usage.used,
            'disk_free': disk_usage.free,
            'disk_percent': (disk_usage.used / disk_usage.total) * 100
        }
    
    def collect_network_metrics(self):
        """Collect network metrics"""
        network = psutil.net_io_counters()
        return {
            'bytes_sent': network.bytes_sent,
            'bytes_recv': network.bytes_recv,
            'packets_sent': network.packets_sent,
            'packets_recv': network.packets_recv
        }
    
    def collect_all_metrics(self):
        """Collect comprehensive system metrics"""
        metrics = {
            'timestamp': datetime.now(),
            'cpu': self.collect_cpu_metrics(),
            'memory': self.collect_memory_metrics(),
            'gpu': self.collect_gpu_metrics(),
            'disk': self.collect_disk_metrics(),
            'network': self.collect_network_metrics()
        }
        
        self.metrics_history.append(metrics)
        
        return metrics
    
    def check_resource_thresholds(self, metrics, thresholds):
        """Check if resource usage exceeds thresholds"""
        alerts = []
        
        # CPU threshold
        if metrics['cpu']['cpu_percent'] > thresholds.get('cpu_percent', 80):
            alerts.append(f"High CPU usage: {metrics['cpu']['cpu_percent']:.1f}%")
        
        # Memory threshold
        if metrics['memory']['memory_percent'] > thresholds.get('memory_percent', 85):
            alerts.append(f"High memory usage: {metrics['memory']['memory_percent']:.1f}%")
        
        # GPU thresholds
        for gpu in metrics['gpu']:
            if gpu['gpu_load'] > thresholds.get('gpu_load', 90):
                alerts.append(f"High GPU {gpu['gpu_id']} load: {gpu['gpu_load']:.1f}%")
            
            if gpu['gpu_memory_percent'] > thresholds.get('gpu_memory_percent', 90):
                alerts.append(f"High GPU {gpu['gpu_id']} memory: {gpu['gpu_memory_percent']:.1f}%")
        
        # Disk threshold
        if metrics['disk']['disk_percent'] > thresholds.get('disk_percent', 85):
            alerts.append(f"High disk usage: {metrics['disk']['disk_percent']:.1f}%")
        
        return alerts
```

## Alerting System

### Alert Manager
```python
# alert_manager.py
import smtplib
import json
import requests
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class AlertManager:
    def __init__(self, config):
        self.config = config
        self.alert_history = []
    
    def send_email_alert(self, alert_data):
        """Send email alert"""
        try:
            msg = MIMEMultipart()
            msg['From'] = self.config['email']['from']
            msg['To'] = ', '.join(self.config['email']['to'])
            msg['Subject'] = f"ML Model Alert: {alert_data['alert_type']}"
            
            body = f"""
            Alert Type: {alert_data['alert_type']}
            Model: {alert_data.get('model_name', 'Unknown')}
            Timestamp: {alert_data['timestamp']}
            Severity: {alert_data.get('severity', 'Medium')}
            
            Details:
            {json.dumps(alert_data.get('details', {}), indent=2)}
            """
            
            msg.attach(MIMEText(body, 'plain'))
            
            server = smtplib.SMTP(self.config['email']['smtp_server'], self.config['email']['port'])
            server.starttls()
            server.login(self.config['email']['username'], self.config['email']['password'])
            server.send_message(msg)
            server.quit()
            
            return True
        except Exception as e:
            print(f"Failed to send email alert: {e}")
            return False
    
    def send_slack_alert(self, alert_data):
        """Send Slack alert"""
        try:
            webhook_url = self.config['slack']['webhook_url']
            
            message = {
                "text": f"ML Model Alert: {alert_data['alert_type']}",
                "attachments": [
                    {
                        "color": "danger" if alert_data.get('severity') == 'high' else "warning",
                        "fields": [
                            {"title": "Model", "value": alert_data.get('model_name', 'Unknown'), "short": True},
                            {"title": "Alert Type", "value": alert_data['alert_type'], "short": True},
                            {"title": "Severity", "value": alert_data.get('severity', 'Medium'), "short": True},
                            {"title": "Timestamp", "value": str(alert_data['timestamp']), "short": True}
                        ]
                    }
                ]
            }
            
            response = requests.post(webhook_url, json=message)
            return response.status_code == 200
        except Exception as e:
            print(f"Failed to send Slack alert: {e}")
            return False
    
    def trigger_alert(self, alert_data):
        """Trigger alert through configured channels"""
        alert_data['alert_id'] = f"alert_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Add to history
        self.alert_history.append(alert_data)
        
        # Send through configured channels
        if self.config.get('email', {}).get('enabled', False):
            self.send_email_alert(alert_data)
        
        if self.config.get('slack', {}).get('enabled', False):
            self.send_slack_alert(alert_data)
        
        # Log alert
        print(f"ALERT TRIGGERED: {alert_data}")
        
        return alert_data['alert_id']
```

## Monitoring Dashboard

### Metrics Collection for Visualization
```python
# metrics_collector.py
from prometheus_client import Counter, Histogram, Gauge, CollectorRegistry, push_to_gateway
import time

class MLMetricsCollector:
    def __init__(self, pushgateway_url=None):
        self.registry = CollectorRegistry()
        self.pushgateway_url = pushgateway_url
        
        # Define metrics
        self.prediction_counter = Counter(
            'ml_predictions_total',
            'Total number of predictions made',
            ['model_name', 'version'],
            registry=self.registry
        )
        
        self.prediction_latency = Histogram(
            'ml_prediction_duration_seconds',
            'Time spent on predictions',
            ['model_name', 'version'],
            registry=self.registry
        )
        
        self.model_accuracy = Gauge(
            'ml_model_accuracy',
            'Current model accuracy',
            ['model_name', 'version'],
            registry=self.registry
        )
        
        self.data_drift_score = Gauge(
            'ml_data_drift_score',
            'Data drift score',
            ['model_name', 'feature'],
            registry=self.registry
        )
        
        self.system_resource_usage = Gauge(
            'ml_system_resource_usage_percent',
            'System resource usage percentage',
            ['resource_type'],
            registry=self.registry
        )
    
    def record_prediction(self, model_name, version, duration):
        """Record a prediction event"""
        self.prediction_counter.labels(model_name=model_name, version=version).inc()
        self.prediction_latency.labels(model_name=model_name, version=version).observe(duration)
    
    def update_model_accuracy(self, model_name, version, accuracy):
        """Update model accuracy metric"""
        self.model_accuracy.labels(model_name=model_name, version=version).set(accuracy)
    
    def update_drift_score(self, model_name, feature, score):
        """Update data drift score"""
        self.data_drift_score.labels(model_name=model_name, feature=feature).set(score)
    
    def update_system_metrics(self, cpu_percent, memory_percent, gpu_percent=None):
        """Update system resource metrics"""
        self.system_resource_usage.labels(resource_type='cpu').set(cpu_percent)
        self.system_resource_usage.labels(resource_type='memory').set(memory_percent)
        
        if gpu_percent is not None:
            self.system_resource_usage.labels(resource_type='gpu').set(gpu_percent)
    
    def push_metrics(self, job_name):
        """Push metrics to Pushgateway"""
        if self.pushgateway_url:
            try:
                push_to_gateway(self.pushgateway_url, job=job_name, registry=self.registry)
            except Exception as e:
                print(f"Failed to push metrics: {e}")
```

## Automated Retraining Triggers

### Retraining Decision Engine
```python
# retraining_engine.py
from datetime import datetime, timedelta
import numpy as np

class RetrainingDecisionEngine:
    def __init__(self, config):
        self.config = config
        self.decision_history = []
    
    def should_retrain(self, performance_metrics, drift_metrics, bias_metrics, system_metrics):
        """Decide if model should be retrained"""
        decision_factors = {
            'performance_degradation': False,
            'data_drift': False,
            'bias_violation': False,
            'time_based': False,
            'data_volume': False
        }
        
        # Check performance degradation
        if performance_metrics:
            accuracy_drop = self.config['baseline_accuracy'] - performance_metrics.get('accuracy', 0)
            if accuracy_drop > self.config['performance_threshold']:
                decision_factors['performance_degradation'] = True
        
        # Check data drift
        if drift_metrics and drift_metrics.get('summary', {}).get('drift_detected', False):
            drift_count = drift_metrics['summary']['drift_count']
            if drift_count > self.config['drift_threshold']:
                decision_factors['data_drift'] = True
        
        # Check bias violations
        if bias_metrics and bias_metrics.get('bias_detected', False):
            decision_factors['bias_violation'] = True
        
        # Check time-based retraining
        last_training_time = self.config.get('last_training_time')
        if last_training_time:
            time_since_training = datetime.now() - last_training_time
            if time_since_training > timedelta(days=self.config['max_days_without_retraining']):
                decision_factors['time_based'] = True
        
        # Check data volume
        current_data_volume = system_metrics.get('data_volume', 0)
        if current_data_volume > self.config['retraining_data_threshold']:
            decision_factors['data_volume'] = True
        
        # Make decision
        should_retrain = any(decision_factors.values())
        
        decision = {
            'timestamp': datetime.now(),
            'should_retrain': should_retrain,
            'decision_factors': decision_factors,
            'metrics': {
                'performance': performance_metrics,
                'drift': drift_metrics,
                'bias': bias_metrics,
                'system': system_metrics
            }
        }
        
        self.decision_history.append(decision)
        
        return decision
    
    def trigger_retraining_pipeline(self, decision):
        """Trigger automated retraining pipeline"""
        if decision['should_retrain']:
            # Create retraining job configuration
            retraining_config = {
                'trigger_reason': [
                    factor for factor, triggered in decision['decision_factors'].items()
                    if triggered
                ],
                'timestamp': decision['timestamp'],
                'priority': self.calculate_priority(decision['decision_factors'])
            }
            
            # Trigger retraining (integrate with your ML pipeline)
            print(f"TRIGGERING RETRAINING: {retraining_config}")
            
            return retraining_config
        
        return None
    
    def calculate_priority(self, decision_factors):
        """Calculate retraining priority based on factors"""
        priority_weights = {
            'performance_degradation': 5,
            'bias_violation': 4,
            'data_drift': 3,
            'time_based': 2,
            'data_volume': 1
        }
        
        priority_score = sum(
            priority_weights.get(factor, 0)
            for factor, triggered in decision_factors.items()
            if triggered
        )
        
        if priority_score >= 5:
            return 'high'
        elif priority_score >= 3:
            return 'medium'
        else:
            return 'low'
```

## Best Practices

1. **Comprehensive Monitoring**: Monitor all aspects - performance, data, bias, system
2. **Automated Alerting**: Set up proactive alerts for critical issues
3. **Baseline Establishment**: Maintain clear baselines for comparison
4. **Regular Reviews**: Conduct regular monitoring reviews and updates
5. **Documentation**: Document monitoring procedures and thresholds
6. **Testing**: Test monitoring and alerting systems regularly
7. **Integration**: Integrate monitoring with CI/CD pipelines
8. **Scalability**: Design monitoring for scale and performance

## Conclusion

Effective model monitoring is essential for maintaining ML systems in production. It requires a comprehensive approach covering performance, data quality, bias, and system health, with automated alerting and retraining capabilities to ensure continued model effectiveness.