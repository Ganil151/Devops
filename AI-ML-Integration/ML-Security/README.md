# ML Security

## Overview

ML Security encompasses protecting machine learning systems, data, models, and infrastructure from threats while ensuring privacy, compliance, and ethical AI practices.

## Data Security

### Data Encryption
```python
# data_encryption.py
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os

class MLDataEncryption:
    def __init__(self, password=None):
        if password:
            self.key = self.derive_key_from_password(password)
        else:
            self.key = Fernet.generate_key()
        self.cipher_suite = Fernet(self.key)
    
    def derive_key_from_password(self, password):
        """Derive encryption key from password"""
        salt = os.urandom(16)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key
    
    def encrypt_data(self, data):
        """Encrypt sensitive data"""
        if isinstance(data, str):
            data = data.encode()
        return self.cipher_suite.encrypt(data)
    
    def decrypt_data(self, encrypted_data):
        """Decrypt sensitive data"""
        return self.cipher_suite.decrypt(encrypted_data)
    
    def encrypt_dataframe(self, df, sensitive_columns):
        """Encrypt sensitive columns in DataFrame"""
        df_encrypted = df.copy()
        
        for column in sensitive_columns:
            if column in df.columns:
                df_encrypted[column] = df[column].apply(
                    lambda x: self.encrypt_data(str(x)) if pd.notna(x) else x
                )
        
        return df_encrypted
```

### Data Anonymization
```python
# data_anonymization.py
import pandas as pd
import numpy as np
import hashlib
from faker import Faker

class DataAnonymizer:
    def __init__(self):
        self.fake = Faker()
        self.mapping_cache = {}
    
    def k_anonymity(self, df, quasi_identifiers, k=5):
        """Implement k-anonymity"""
        # Group by quasi-identifiers
        grouped = df.groupby(quasi_identifiers)
        
        # Filter groups with at least k records
        valid_groups = grouped.filter(lambda x: len(x) >= k)
        
        return valid_groups
    
    def l_diversity(self, df, quasi_identifiers, sensitive_attribute, l=2):
        """Implement l-diversity"""
        grouped = df.groupby(quasi_identifiers)
        
        def check_l_diversity(group):
            unique_sensitive = group[sensitive_attribute].nunique()
            return unique_sensitive >= l
        
        valid_groups = grouped.filter(check_l_diversity)
        return valid_groups
    
    def generalize_numerical(self, series, bins=5):
        """Generalize numerical data into ranges"""
        return pd.cut(series, bins=bins, labels=False)
    
    def generalize_categorical(self, series, hierarchy_map):
        """Generalize categorical data using hierarchy"""
        return series.map(hierarchy_map)
    
    def suppress_data(self, df, columns, suppression_rate=0.1):
        """Randomly suppress data in specified columns"""
        df_suppressed = df.copy()
        
        for column in columns:
            if column in df.columns:
                n_suppress = int(len(df) * suppression_rate)
                suppress_indices = np.random.choice(df.index, n_suppress, replace=False)
                df_suppressed.loc[suppress_indices, column] = '*'
        
        return df_suppressed
    
    def pseudonymize_identifiers(self, df, identifier_columns):
        """Replace identifiers with pseudonyms"""
        df_pseudo = df.copy()
        
        for column in identifier_columns:
            if column in df.columns:
                if column not in self.mapping_cache:
                    unique_values = df[column].unique()
                    self.mapping_cache[column] = {
                        val: self.generate_pseudonym(val) for val in unique_values
                    }
                
                df_pseudo[column] = df[column].map(self.mapping_cache[column])
        
        return df_pseudo
    
    def generate_pseudonym(self, original_value):
        """Generate consistent pseudonym for a value"""
        hash_object = hashlib.sha256(str(original_value).encode())
        return hash_object.hexdigest()[:10]
    
    def differential_privacy_noise(self, df, columns, epsilon=1.0):
        """Add differential privacy noise to numerical columns"""
        df_noisy = df.copy()
        
        for column in columns:
            if column in df.columns and df[column].dtype in ['int64', 'float64']:
                sensitivity = df[column].max() - df[column].min()
                noise_scale = sensitivity / epsilon
                noise = np.random.laplace(0, noise_scale, len(df))
                df_noisy[column] = df[column] + noise
        
        return df_noisy
```

## Model Security

### Model Encryption and Protection
```python
# model_security.py
import joblib
import pickle
import hashlib
from cryptography.fernet import Fernet
import hmac

class ModelSecurity:
    def __init__(self, encryption_key=None):
        self.encryption_key = encryption_key or Fernet.generate_key()
        self.cipher_suite = Fernet(self.encryption_key)
    
    def encrypt_model(self, model, model_path):
        """Encrypt and save model"""
        # Serialize model
        model_bytes = pickle.dumps(model)
        
        # Encrypt model
        encrypted_model = self.cipher_suite.encrypt(model_bytes)
        
        # Save encrypted model
        with open(model_path, 'wb') as f:
            f.write(encrypted_model)
        
        # Generate integrity hash
        model_hash = hashlib.sha256(encrypted_model).hexdigest()
        
        return model_hash
    
    def decrypt_model(self, model_path, expected_hash=None):
        """Decrypt and load model"""
        # Load encrypted model
        with open(model_path, 'rb') as f:
            encrypted_model = f.read()
        
        # Verify integrity if hash provided
        if expected_hash:
            actual_hash = hashlib.sha256(encrypted_model).hexdigest()
            if actual_hash != expected_hash:
                raise ValueError("Model integrity check failed")
        
        # Decrypt model
        model_bytes = self.cipher_suite.decrypt(encrypted_model)
        
        # Deserialize model
        model = pickle.loads(model_bytes)
        
        return model
    
    def sign_model(self, model, secret_key):
        """Create digital signature for model"""
        model_bytes = pickle.dumps(model)
        signature = hmac.new(
            secret_key.encode(),
            model_bytes,
            hashlib.sha256
        ).hexdigest()
        
        return signature
    
    def verify_model_signature(self, model, signature, secret_key):
        """Verify model digital signature"""
        model_bytes = pickle.dumps(model)
        expected_signature = hmac.new(
            secret_key.encode(),
            model_bytes,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(signature, expected_signature)
```

### Adversarial Attack Detection
```python
# adversarial_detection.py
import numpy as np
from sklearn.metrics import accuracy_score
import tensorflow as tf

class AdversarialDetector:
    def __init__(self, model, threshold=0.1):
        self.model = model
        self.threshold = threshold
        self.baseline_predictions = {}
    
    def detect_fgsm_attack(self, X, y, epsilon=0.1):
        """Detect Fast Gradient Sign Method attacks"""
        if hasattr(self.model, 'predict_proba'):
            original_probs = self.model.predict_proba(X)
        else:
            original_probs = self.model.predict(X)
        
        # Generate adversarial examples using FGSM
        adversarial_X = self.generate_fgsm_examples(X, y, epsilon)
        
        if hasattr(self.model, 'predict_proba'):
            adversarial_probs = self.model.predict_proba(adversarial_X)
        else:
            adversarial_probs = self.model.predict(adversarial_X)
        
        # Calculate prediction differences
        prob_differences = np.abs(original_probs - adversarial_probs)
        max_differences = np.max(prob_differences, axis=1)
        
        # Detect attacks based on threshold
        attack_detected = max_differences > self.threshold
        
        return {
            'attack_detected': attack_detected,
            'confidence_drops': max_differences,
            'affected_samples': np.where(attack_detected)[0]
        }
    
    def generate_fgsm_examples(self, X, y, epsilon):
        """Generate FGSM adversarial examples"""
        # This is a simplified version - in practice, you'd use the actual gradients
        noise = np.random.normal(0, epsilon, X.shape)
        return X + noise
    
    def detect_input_anomalies(self, X, reference_X):
        """Detect anomalous inputs that might be adversarial"""
        from sklearn.ensemble import IsolationForest
        
        # Train anomaly detector on reference data
        anomaly_detector = IsolationForest(contamination=0.1, random_state=42)
        anomaly_detector.fit(reference_X)
        
        # Detect anomalies in input data
        anomaly_scores = anomaly_detector.decision_function(X)
        anomalies = anomaly_detector.predict(X) == -1
        
        return {
            'anomalies_detected': anomalies,
            'anomaly_scores': anomaly_scores,
            'anomalous_indices': np.where(anomalies)[0]
        }
    
    def monitor_prediction_confidence(self, X, confidence_threshold=0.8):
        """Monitor prediction confidence for potential attacks"""
        if hasattr(self.model, 'predict_proba'):
            probabilities = self.model.predict_proba(X)
            max_confidences = np.max(probabilities, axis=1)
        else:
            # For models without probability output, use distance-based confidence
            predictions = self.model.predict(X)
            max_confidences = np.ones(len(X))  # Simplified
        
        low_confidence = max_confidences < confidence_threshold
        
        return {
            'low_confidence_detected': low_confidence,
            'confidences': max_confidences,
            'suspicious_indices': np.where(low_confidence)[0]
        }
```

## Infrastructure Security

### Secure ML Infrastructure
```python
# infrastructure_security.py
import boto3
import json
from datetime import datetime

class MLInfrastructureSecurity:
    def __init__(self):
        self.iam_client = boto3.client('iam')
        self.ec2_client = boto3.client('ec2')
        self.vpc_client = boto3.client('ec2')
    
    def create_secure_vpc(self, vpc_name, cidr_block='10.0.0.0/16'):
        """Create secure VPC for ML workloads"""
        # Create VPC
        vpc_response = self.vpc_client.create_vpc(
            CidrBlock=cidr_block,
            TagSpecifications=[
                {
                    'ResourceType': 'vpc',
                    'Tags': [
                        {'Key': 'Name', 'Value': vpc_name},
                        {'Key': 'Purpose', 'Value': 'ML-Workloads'}
                    ]
                }
            ]
        )
        
        vpc_id = vpc_response['Vpc']['VpcId']
        
        # Create private subnets
        private_subnet = self.vpc_client.create_subnet(
            VpcId=vpc_id,
            CidrBlock='10.0.1.0/24',
            TagSpecifications=[
                {
                    'ResourceType': 'subnet',
                    'Tags': [{'Key': 'Name', 'Value': f'{vpc_name}-private'}]
                }
            ]
        )
        
        # Create security group for ML workloads
        security_group = self.vpc_client.create_security_group(
            GroupName=f'{vpc_name}-ml-sg',
            Description='Security group for ML workloads',
            VpcId=vpc_id
        )
        
        # Configure security group rules (restrictive by default)
        self.vpc_client.authorize_security_group_ingress(
            GroupId=security_group['GroupId'],
            IpPermissions=[
                {
                    'IpProtocol': 'tcp',
                    'FromPort': 443,
                    'ToPort': 443,
                    'IpRanges': [{'CidrIp': '10.0.0.0/16'}]  # Only internal traffic
                }
            ]
        )
        
        return {
            'vpc_id': vpc_id,
            'private_subnet_id': private_subnet['Subnet']['SubnetId'],
            'security_group_id': security_group['GroupId']
        }
    
    def create_ml_execution_role(self, role_name):
        """Create least-privilege IAM role for ML services"""
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": ["sagemaker.amazonaws.com"]
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {
                        "StringEquals": {
                            "aws:RequestedRegion": ["us-east-1", "us-west-2"]
                        }
                    }
                }
            ]
        }
        
        # Create role
        role_response = self.iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy),
            MaxSessionDuration=3600  # 1 hour max session
        )
        
        # Create custom policy with minimal permissions
        policy_document = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetObject",
                        "s3:PutObject"
                    ],
                    "Resource": "arn:aws:s3:::ml-data-bucket/*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "arn:aws:logs:*:*:*"
                }
            ]
        }
        
        # Create and attach policy
        policy_response = self.iam_client.create_policy(
            PolicyName=f'{role_name}-policy',
            PolicyDocument=json.dumps(policy_document)
        )
        
        self.iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_response['Policy']['Arn']
        )
        
        return role_response['Role']['Arn']
    
    def enable_cloudtrail_logging(self, trail_name, s3_bucket):
        """Enable CloudTrail for ML resource auditing"""
        cloudtrail = boto3.client('cloudtrail')
        
        trail_response = cloudtrail.create_trail(
            Name=trail_name,
            S3BucketName=s3_bucket,
            IncludeGlobalServiceEvents=True,
            IsMultiRegionTrail=True,
            EnableLogFileValidation=True
        )
        
        # Start logging
        cloudtrail.start_logging(Name=trail_name)
        
        return trail_response['TrailARN']
```

## Access Control and Authentication

### ML API Security
```python
# api_security.py
from flask import Flask, request, jsonify
import jwt
import functools
import time
import hashlib
from datetime import datetime, timedelta

class MLAPISecurityManager:
    def __init__(self, secret_key, rate_limit=100):
        self.secret_key = secret_key
        self.rate_limit = rate_limit
        self.request_counts = {}
        self.blocked_ips = set()
    
    def generate_token(self, user_id, permissions, expiry_hours=24):
        """Generate JWT token for API access"""
        payload = {
            'user_id': user_id,
            'permissions': permissions,
            'exp': datetime.utcnow() + timedelta(hours=expiry_hours),
            'iat': datetime.utcnow()
        }
        
        token = jwt.encode(payload, self.secret_key, algorithm='HS256')
        return token
    
    def verify_token(self, token):
        """Verify JWT token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
    
    def require_auth(self, required_permission=None):
        """Decorator for API authentication"""
        def decorator(f):
            @functools.wraps(f)
            def decorated_function(*args, **kwargs):
                # Check for authorization header
                auth_header = request.headers.get('Authorization')
                if not auth_header or not auth_header.startswith('Bearer '):
                    return jsonify({'error': 'Missing or invalid authorization header'}), 401
                
                # Extract and verify token
                token = auth_header.split(' ')[1]
                payload = self.verify_token(token)
                
                if not payload:
                    return jsonify({'error': 'Invalid or expired token'}), 401
                
                # Check permissions
                if required_permission and required_permission not in payload.get('permissions', []):
                    return jsonify({'error': 'Insufficient permissions'}), 403
                
                # Add user info to request context
                request.user_id = payload['user_id']
                request.permissions = payload['permissions']
                
                return f(*args, **kwargs)
            return decorated_function
        return decorator
    
    def rate_limit_check(self, client_ip):
        """Check rate limiting for client IP"""
        current_time = time.time()
        hour_window = int(current_time // 3600)
        
        # Clean old entries
        self.request_counts = {
            key: count for key, count in self.request_counts.items()
            if key[1] >= hour_window
        }
        
        # Check current count
        key = (client_ip, hour_window)
        current_count = self.request_counts.get(key, 0)
        
        if current_count >= self.rate_limit:
            self.blocked_ips.add(client_ip)
            return False
        
        # Increment count
        self.request_counts[key] = current_count + 1
        return True
    
    def validate_input(self, data, schema):
        """Validate input data against schema"""
        required_fields = schema.get('required', [])
        field_types = schema.get('types', {})
        field_ranges = schema.get('ranges', {})
        
        # Check required fields
        for field in required_fields:
            if field not in data:
                return False, f"Missing required field: {field}"
        
        # Check field types
        for field, expected_type in field_types.items():
            if field in data:
                if not isinstance(data[field], expected_type):
                    return False, f"Invalid type for field {field}"
        
        # Check field ranges
        for field, (min_val, max_val) in field_ranges.items():
            if field in data:
                if not (min_val <= data[field] <= max_val):
                    return False, f"Value for field {field} out of range"
        
        return True, "Valid"
    
    def log_security_event(self, event_type, details, client_ip):
        """Log security events for monitoring"""
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'client_ip': client_ip,
            'details': details
        }
        
        # In practice, send to security monitoring system
        print(f"SECURITY EVENT: {log_entry}")
```

## Privacy-Preserving ML

### Federated Learning Security
```python
# federated_learning_security.py
import numpy as np
import hashlib
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import rsa, padding

class FederatedLearningSecurityManager:
    def __init__(self):
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        self.public_key = self.private_key.public_key()
    
    def secure_aggregation(self, model_updates, client_keys):
        """Perform secure aggregation of model updates"""
        # Verify signatures from all clients
        verified_updates = []
        
        for update, client_public_key in zip(model_updates, client_keys):
            if self.verify_model_update(update, client_public_key):
                verified_updates.append(update['weights'])
            else:
                print(f"Warning: Invalid signature from client")
        
        if len(verified_updates) == 0:
            raise ValueError("No valid updates received")
        
        # Aggregate verified updates
        aggregated_weights = np.mean(verified_updates, axis=0)
        
        # Add differential privacy noise
        noise_scale = 0.1
        noise = np.random.laplace(0, noise_scale, aggregated_weights.shape)
        private_weights = aggregated_weights + noise
        
        return private_weights
    
    def sign_model_update(self, model_weights):
        """Sign model update with private key"""
        # Serialize weights
        weights_bytes = model_weights.tobytes()
        
        # Create signature
        signature = self.private_key.sign(
            weights_bytes,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        
        return {
            'weights': model_weights,
            'signature': signature,
            'public_key': self.public_key
        }
    
    def verify_model_update(self, signed_update, client_public_key):
        """Verify signed model update"""
        try:
            weights_bytes = signed_update['weights'].tobytes()
            
            client_public_key.verify(
                signed_update['signature'],
                weights_bytes,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
            return True
        except:
            return False
    
    def homomorphic_encryption_aggregate(self, encrypted_updates):
        """Aggregate encrypted model updates (simplified)"""
        # This is a simplified version - real implementation would use
        # libraries like PySEAL or TenSEAL
        
        # Simulate homomorphic addition
        aggregated_encrypted = encrypted_updates[0]
        
        for update in encrypted_updates[1:]:
            # In real implementation, this would be homomorphic addition
            aggregated_encrypted = self.homomorphic_add(aggregated_encrypted, update)
        
        return aggregated_encrypted
    
    def homomorphic_add(self, encrypted_a, encrypted_b):
        """Simulate homomorphic addition (placeholder)"""
        # Real implementation would use actual homomorphic encryption
        return encrypted_a  # Placeholder
```

## Compliance and Auditing

### ML Compliance Framework
```python
# ml_compliance.py
import json
from datetime import datetime
import pandas as pd

class MLComplianceManager:
    def __init__(self):
        self.audit_log = []
        self.compliance_rules = {}
    
    def register_compliance_rule(self, rule_name, rule_function, severity='medium'):
        """Register compliance rule"""
        self.compliance_rules[rule_name] = {
            'function': rule_function,
            'severity': severity,
            'last_checked': None
        }
    
    def check_gdpr_compliance(self, data_processing_record):
        """Check GDPR compliance"""
        compliance_issues = []
        
        # Check for explicit consent
        if not data_processing_record.get('explicit_consent', False):
            compliance_issues.append({
                'rule': 'GDPR Article 6',
                'issue': 'Missing explicit consent for data processing',
                'severity': 'high'
            })
        
        # Check for data minimization
        if data_processing_record.get('data_fields_count', 0) > 20:
            compliance_issues.append({
                'rule': 'GDPR Article 5(1)(c)',
                'issue': 'Potential data minimization violation - too many fields',
                'severity': 'medium'
            })
        
        # Check for retention period
        if not data_processing_record.get('retention_period'):
            compliance_issues.append({
                'rule': 'GDPR Article 5(1)(e)',
                'issue': 'Missing data retention period specification',
                'severity': 'medium'
            })
        
        return compliance_issues
    
    def check_model_fairness(self, predictions, protected_attributes, threshold=0.1):
        """Check model fairness compliance"""
        fairness_issues = []
        
        # Check demographic parity
        groups = np.unique(protected_attributes)
        positive_rates = {}
        
        for group in groups:
            group_mask = protected_attributes == group
            positive_rate = np.mean(predictions[group_mask] == 1)
            positive_rates[group] = positive_rate
        
        # Calculate maximum difference
        rates = list(positive_rates.values())
        max_diff = max(rates) - min(rates)
        
        if max_diff > threshold:
            fairness_issues.append({
                'rule': 'Demographic Parity',
                'issue': f'Demographic parity difference: {max_diff:.3f} > {threshold}',
                'severity': 'high',
                'group_rates': positive_rates
            })
        
        return fairness_issues
    
    def audit_model_decision(self, model_input, model_output, user_id, model_version):
        """Audit individual model decision"""
        audit_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'user_id': user_id,
            'model_version': model_version,
            'input_hash': hashlib.sha256(str(model_input).encode()).hexdigest(),
            'output': model_output,
            'compliance_checks': []
        }
        
        # Run compliance checks
        for rule_name, rule_config in self.compliance_rules.items():
            try:
                result = rule_config['function'](model_input, model_output)
                audit_entry['compliance_checks'].append({
                    'rule': rule_name,
                    'result': result,
                    'severity': rule_config['severity']
                })
            except Exception as e:
                audit_entry['compliance_checks'].append({
                    'rule': rule_name,
                    'result': f'Error: {str(e)}',
                    'severity': 'error'
                })
        
        self.audit_log.append(audit_entry)
        return audit_entry
    
    def generate_compliance_report(self, start_date, end_date):
        """Generate compliance report for specified period"""
        # Filter audit log by date range
        filtered_logs = [
            log for log in self.audit_log
            if start_date <= datetime.fromisoformat(log['timestamp']) <= end_date
        ]
        
        # Aggregate compliance issues
        issue_summary = {}
        for log in filtered_logs:
            for check in log['compliance_checks']:
                rule = check['rule']
                if rule not in issue_summary:
                    issue_summary[rule] = {'passed': 0, 'failed': 0, 'errors': 0}
                
                if check['result'] == 'passed':
                    issue_summary[rule]['passed'] += 1
                elif 'Error:' in str(check['result']):
                    issue_summary[rule]['errors'] += 1
                else:
                    issue_summary[rule]['failed'] += 1
        
        report = {
            'report_period': {
                'start_date': start_date.isoformat(),
                'end_date': end_date.isoformat()
            },
            'total_decisions_audited': len(filtered_logs),
            'compliance_summary': issue_summary,
            'high_risk_decisions': [
                log for log in filtered_logs
                if any(check['severity'] == 'high' and check['result'] != 'passed'
                      for check in log['compliance_checks'])
            ]
        }
        
        return report
    
    def export_audit_trail(self, output_file):
        """Export audit trail for regulatory compliance"""
        df = pd.DataFrame(self.audit_log)
        df.to_csv(output_file, index=False)
        
        # Create summary statistics
        summary = {
            'total_entries': len(self.audit_log),
            'date_range': {
                'earliest': min(log['timestamp'] for log in self.audit_log) if self.audit_log else None,
                'latest': max(log['timestamp'] for log in self.audit_log) if self.audit_log else None
            },
            'unique_users': len(set(log['user_id'] for log in self.audit_log)),
            'unique_models': len(set(log['model_version'] for log in self.audit_log))
        }
        
        with open(f"{output_file}.summary.json", 'w') as f:
            json.dump(summary, f, indent=2)
        
        return summary
```

## Security Monitoring

### ML Security Monitoring
```python
# security_monitoring.py
import time
from collections import defaultdict, deque
from datetime import datetime, timedelta

class MLSecurityMonitor:
    def __init__(self):
        self.security_events = deque(maxlen=10000)
        self.threat_indicators = defaultdict(int)
        self.alert_thresholds = {
            'failed_auth_attempts': 5,
            'unusual_prediction_patterns': 10,
            'data_access_violations': 3,
            'model_tampering_attempts': 1
        }
    
    def log_security_event(self, event_type, source_ip, user_id, details):
        """Log security event"""
        event = {
            'timestamp': datetime.utcnow(),
            'event_type': event_type,
            'source_ip': source_ip,
            'user_id': user_id,
            'details': details
        }
        
        self.security_events.append(event)
        self.analyze_threat_patterns(event)
    
    def analyze_threat_patterns(self, event):
        """Analyze patterns for potential threats"""
        # Check for brute force attacks
        if event['event_type'] == 'failed_authentication':
            recent_failures = sum(
                1 for e in self.security_events
                if (e['event_type'] == 'failed_authentication' and
                    e['source_ip'] == event['source_ip'] and
                    datetime.utcnow() - e['timestamp'] < timedelta(minutes=15))
            )
            
            if recent_failures >= self.alert_thresholds['failed_auth_attempts']:
                self.trigger_security_alert('brute_force_attack', event)
        
        # Check for unusual prediction patterns
        elif event['event_type'] == 'prediction_request':
            recent_requests = sum(
                1 for e in self.security_events
                if (e['event_type'] == 'prediction_request' and
                    e['user_id'] == event['user_id'] and
                    datetime.utcnow() - e['timestamp'] < timedelta(minutes=5))
            )
            
            if recent_requests >= self.alert_thresholds['unusual_prediction_patterns']:
                self.trigger_security_alert('unusual_activity', event)
        
        # Check for data access violations
        elif event['event_type'] == 'unauthorized_data_access':
            self.trigger_security_alert('data_breach_attempt', event)
    
    def trigger_security_alert(self, alert_type, triggering_event):
        """Trigger security alert"""
        alert = {
            'alert_id': f"alert_{int(time.time())}",
            'alert_type': alert_type,
            'severity': self.get_alert_severity(alert_type),
            'timestamp': datetime.utcnow(),
            'triggering_event': triggering_event,
            'recommended_actions': self.get_recommended_actions(alert_type)
        }
        
        # Log alert
        print(f"SECURITY ALERT: {alert}")
        
        # Take automated actions if configured
        self.take_automated_action(alert)
        
        return alert
    
    def get_alert_severity(self, alert_type):
        """Get alert severity level"""
        severity_map = {
            'brute_force_attack': 'high',
            'unusual_activity': 'medium',
            'data_breach_attempt': 'critical',
            'model_tampering': 'critical'
        }
        return severity_map.get(alert_type, 'medium')
    
    def get_recommended_actions(self, alert_type):
        """Get recommended actions for alert type"""
        actions_map = {
            'brute_force_attack': [
                'Block source IP temporarily',
                'Require additional authentication',
                'Review user account security'
            ],
            'unusual_activity': [
                'Monitor user activity closely',
                'Review prediction patterns',
                'Check for automated requests'
            ],
            'data_breach_attempt': [
                'Immediately block access',
                'Conduct security investigation',
                'Review access logs',
                'Notify security team'
            ]
        }
        return actions_map.get(alert_type, ['Investigate further'])
    
    def take_automated_action(self, alert):
        """Take automated security actions"""
        if alert['alert_type'] == 'brute_force_attack':
            # Temporarily block IP
            self.block_ip_temporarily(alert['triggering_event']['source_ip'])
        
        elif alert['severity'] == 'critical':
            # Disable user account temporarily
            self.disable_user_temporarily(alert['triggering_event']['user_id'])
    
    def block_ip_temporarily(self, ip_address, duration_minutes=30):
        """Temporarily block IP address"""
        # Implementation would integrate with firewall/load balancer
        print(f"Blocking IP {ip_address} for {duration_minutes} minutes")
    
    def disable_user_temporarily(self, user_id, duration_minutes=60):
        """Temporarily disable user account"""
        # Implementation would integrate with authentication system
        print(f"Disabling user {user_id} for {duration_minutes} minutes")
    
    def generate_security_report(self, hours=24):
        """Generate security report for specified period"""
        cutoff_time = datetime.utcnow() - timedelta(hours=hours)
        
        recent_events = [
            event for event in self.security_events
            if event['timestamp'] >= cutoff_time
        ]
        
        # Aggregate statistics
        event_counts = defaultdict(int)
        ip_counts = defaultdict(int)
        user_counts = defaultdict(int)
        
        for event in recent_events:
            event_counts[event['event_type']] += 1
            ip_counts[event['source_ip']] += 1
            user_counts[event['user_id']] += 1
        
        report = {
            'report_period_hours': hours,
            'total_events': len(recent_events),
            'event_breakdown': dict(event_counts),
            'top_source_ips': dict(sorted(ip_counts.items(), key=lambda x: x[1], reverse=True)[:10]),
            'top_users': dict(sorted(user_counts.items(), key=lambda x: x[1], reverse=True)[:10]),
            'security_recommendations': self.generate_security_recommendations(recent_events)
        }
        
        return report
    
    def generate_security_recommendations(self, events):
        """Generate security recommendations based on events"""
        recommendations = []
        
        # Check for high-frequency events
        event_counts = defaultdict(int)
        for event in events:
            event_counts[event['event_type']] += 1
        
        if event_counts['failed_authentication'] > 50:
            recommendations.append("Consider implementing CAPTCHA or account lockout policies")
        
        if event_counts['prediction_request'] > 1000:
            recommendations.append("Review API rate limiting policies")
        
        # Check for geographic anomalies
        unique_ips = set(event['source_ip'] for event in events)
        if len(unique_ips) > 100:
            recommendations.append("Consider implementing geographic access restrictions")
        
        return recommendations
```

## Best Practices

1. **Defense in Depth**: Implement multiple layers of security
2. **Least Privilege**: Grant minimum necessary permissions
3. **Encryption**: Encrypt data at rest and in transit
4. **Monitoring**: Continuous security monitoring and alerting
5. **Compliance**: Regular compliance audits and documentation
6. **Privacy**: Implement privacy-preserving techniques
7. **Testing**: Regular security testing and vulnerability assessments
8. **Training**: Security awareness training for ML teams

## Conclusion

ML Security requires a comprehensive approach covering data protection, model security, infrastructure hardening, access controls, privacy preservation, and continuous monitoring. Success depends on implementing security by design and maintaining vigilance throughout the ML lifecycle.