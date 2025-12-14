# Cloud ML Services

## Overview

Cloud ML services provide managed machine learning platforms that simplify model development, training, deployment, and management across major cloud providers.

## AWS ML Services

### Amazon SageMaker
```python
# sagemaker_training.py
import boto3
import sagemaker
from sagemaker.sklearn.estimator import SKLearn

class SageMakerMLOps:
    def __init__(self, role_arn, bucket_name):
        self.sagemaker_session = sagemaker.Session()
        self.role = role_arn
        self.bucket = bucket_name
        self.sm_client = boto3.client('sagemaker')
    
    def create_training_job(self, script_path, train_data_path, output_path):
        """Create SageMaker training job"""
        estimator = SKLearn(
            entry_point=script_path,
            role=self.role,
            instance_type='ml.m5.large',
            framework_version='0.23-1',
            py_version='py3',
            output_path=output_path
        )
        
        estimator.fit({'train': train_data_path})
        return estimator
    
    def deploy_model(self, estimator, endpoint_name):
        """Deploy model to SageMaker endpoint"""
        predictor = estimator.deploy(
            initial_instance_count=1,
            instance_type='ml.m5.large',
            endpoint_name=endpoint_name
        )
        return predictor
    
    def create_model_package(self, model_data, inference_image):
        """Create model package for registry"""
        model_package_input_dict = {
            "ModelPackageGroupName": "ml-model-group",
            "ModelPackageDescription": "ML model package",
            "InferenceSpecification": {
                "Containers": [
                    {
                        "Image": inference_image,
                        "ModelDataUrl": model_data
                    }
                ],
                "SupportedContentTypes": ["application/json"],
                "SupportedResponseMIMETypes": ["application/json"]
            }
        }
        
        response = self.sm_client.create_model_package(**model_package_input_dict)
        return response['ModelPackageArn']
```

### AWS Lambda for ML
```python
# lambda_ml_inference.py
import json
import boto3
import joblib
import numpy as np
from io import BytesIO

def lambda_handler(event, context):
    """AWS Lambda function for ML inference"""
    
    # Load model from S3
    s3 = boto3.client('s3')
    bucket = 'ml-models-bucket'
    key = 'models/latest/model.pkl'
    
    try:
        # Download model
        obj = s3.get_object(Bucket=bucket, Key=key)
        model_bytes = obj['Body'].read()
        model = joblib.load(BytesIO(model_bytes))
        
        # Parse input
        input_data = json.loads(event['body'])
        features = np.array(input_data['features']).reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(features)
        probability = model.predict_proba(features) if hasattr(model, 'predict_proba') else None
        
        response = {
            'prediction': prediction.tolist(),
            'probability': probability.tolist() if probability is not None else None
        }
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(response)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

### AWS Batch for ML Training
```python
# batch_training.py
import boto3

class AWSBatchMLTraining:
    def __init__(self):
        self.batch_client = boto3.client('batch')
        self.ecs_client = boto3.client('ecs')
    
    def create_job_definition(self, job_name, image_uri, vcpus=2, memory=4096):
        """Create Batch job definition for ML training"""
        job_definition = {
            'jobDefinitionName': job_name,
            'type': 'container',
            'containerProperties': {
                'image': image_uri,
                'vcpus': vcpus,
                'memory': memory,
                'jobRoleArn': 'arn:aws:iam::account:role/BatchExecutionRole',
                'environment': [
                    {'name': 'AWS_DEFAULT_REGION', 'value': 'us-east-1'}
                ]
            }
        }
        
        response = self.batch_client.register_job_definition(**job_definition)
        return response['jobDefinitionArn']
    
    def submit_training_job(self, job_name, job_definition, job_queue, parameters=None):
        """Submit ML training job to Batch"""
        job_params = {
            'jobName': job_name,
            'jobQueue': job_queue,
            'jobDefinition': job_definition
        }
        
        if parameters:
            job_params['parameters'] = parameters
        
        response = self.batch_client.submit_job(**job_params)
        return response['jobId']
```

## Azure ML Services

### Azure Machine Learning
```python
# azure_ml_service.py
from azureml.core import Workspace, Experiment, Environment, ScriptRunConfig
from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core.model import Model

class AzureMLService:
    def __init__(self, subscription_id, resource_group, workspace_name):
        self.ws = Workspace(subscription_id, resource_group, workspace_name)
    
    def create_compute_cluster(self, cluster_name, vm_size='Standard_D2_v2', max_nodes=4):
        """Create Azure ML compute cluster"""
        try:
            compute_target = ComputeTarget(workspace=self.ws, name=cluster_name)
        except:
            compute_config = AmlCompute.provisioning_configuration(
                vm_size=vm_size,
                max_nodes=max_nodes,
                min_nodes=0,
                idle_seconds_before_scaledown=300
            )
            compute_target = ComputeTarget.create(self.ws, cluster_name, compute_config)
            compute_target.wait_for_completion(show_output=True)
        
        return compute_target
    
    def submit_training_run(self, script_path, compute_target, environment_name):
        """Submit training run to Azure ML"""
        # Create environment
        env = Environment.get(workspace=self.ws, name=environment_name)
        
        # Create script run config
        src = ScriptRunConfig(
            source_directory='.',
            script=script_path,
            compute_target=compute_target,
            environment=env
        )
        
        # Submit experiment
        experiment = Experiment(workspace=self.ws, name='ml-training')
        run = experiment.submit(config=src)
        
        return run
    
    def register_model(self, model_path, model_name, description):
        """Register model in Azure ML"""
        model = Model.register(
            workspace=self.ws,
            model_path=model_path,
            model_name=model_name,
            description=description
        )
        return model
    
    def deploy_web_service(self, model, service_name, cpu_cores=1, memory_gb=1):
        """Deploy model as web service"""
        from azureml.core.webservice import AciWebservice
        from azureml.core.model import InferenceConfig
        
        # Inference configuration
        inference_config = InferenceConfig(
            entry_script='score.py',
            environment=Environment.get(workspace=self.ws, name='inference-env')
        )
        
        # Deployment configuration
        deployment_config = AciWebservice.deploy_configuration(
            cpu_cores=cpu_cores,
            memory_gb=memory_gb
        )
        
        # Deploy service
        service = Model.deploy(
            workspace=self.ws,
            name=service_name,
            models=[model],
            inference_config=inference_config,
            deployment_config=deployment_config
        )
        
        service.wait_for_deployment(show_output=True)
        return service
```

### Azure Functions for ML
```python
# azure_function_ml.py
import azure.functions as func
import json
import joblib
import numpy as np
from azure.storage.blob import BlobServiceClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    """Azure Function for ML inference"""
    
    try:
        # Get model from blob storage
        blob_service_client = BlobServiceClient.from_connection_string("connection_string")
        blob_client = blob_service_client.get_blob_client(
            container="models", 
            blob="latest/model.pkl"
        )
        
        model_data = blob_client.download_blob().readall()
        model = joblib.loads(model_data)
        
        # Parse request
        req_body = req.get_json()
        features = np.array(req_body['features']).reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(features)
        
        return func.HttpResponse(
            json.dumps({'prediction': prediction.tolist()}),
            mimetype="application/json"
        )
        
    except Exception as e:
        return func.HttpResponse(
            json.dumps({'error': str(e)}),
            status_code=500
        )
```

## Google Cloud ML Services

### Vertex AI
```python
# vertex_ai_service.py
from google.cloud import aiplatform
from google.cloud.aiplatform import gapic as aip

class VertexAIService:
    def __init__(self, project_id, location):
        aiplatform.init(project=project_id, location=location)
        self.project_id = project_id
        self.location = location
    
    def create_custom_training_job(self, display_name, container_image_uri, machine_type='n1-standard-4'):
        """Create custom training job in Vertex AI"""
        job = aiplatform.CustomContainerTrainingJob(
            display_name=display_name,
            container_uri=container_image_uri,
            model_serving_container_image_uri=container_image_uri
        )
        
        model = job.run(
            machine_type=machine_type,
            replica_count=1,
            sync=True
        )
        
        return model
    
    def deploy_model_to_endpoint(self, model, endpoint_display_name, machine_type='n1-standard-2'):
        """Deploy model to Vertex AI endpoint"""
        endpoint = aiplatform.Endpoint.create(display_name=endpoint_display_name)
        
        deployed_model = model.deploy(
            endpoint=endpoint,
            machine_type=machine_type,
            min_replica_count=1,
            max_replica_count=3
        )
        
        return endpoint
    
    def batch_predict(self, model, input_data_uri, output_data_uri):
        """Run batch prediction job"""
        batch_prediction_job = model.batch_predict(
            job_display_name='batch-prediction-job',
            gcs_source=input_data_uri,
            gcs_destination_prefix=output_data_uri,
            machine_type='n1-standard-4',
            sync=True
        )
        
        return batch_prediction_job
```

### Google Cloud Functions for ML
```python
# gcp_function_ml.py
import functions_framework
import json
import joblib
import numpy as np
from google.cloud import storage

@functions_framework.http
def ml_predict(request):
    """Google Cloud Function for ML inference"""
    
    try:
        # Download model from Cloud Storage
        client = storage.Client()
        bucket = client.bucket('ml-models-bucket')
        blob = bucket.blob('models/latest/model.pkl')
        
        model_bytes = blob.download_as_bytes()
        model = joblib.loads(model_bytes)
        
        # Parse request
        request_json = request.get_json()
        features = np.array(request_json['features']).reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(features)
        
        return json.dumps({'prediction': prediction.tolist()})
        
    except Exception as e:
        return json.dumps({'error': str(e)}), 500
```

## Multi-Cloud ML Deployment

### Cloud-Agnostic ML Pipeline
```python
# multi_cloud_ml.py
from abc import ABC, abstractmethod
import boto3
from azure.identity import DefaultAzureCredential
from azure.mgmt.machinelearningservices import MachineLearningServicesMgmtClient
from google.cloud import aiplatform

class CloudMLProvider(ABC):
    @abstractmethod
    def deploy_model(self, model_config):
        pass
    
    @abstractmethod
    def create_endpoint(self, endpoint_config):
        pass
    
    @abstractmethod
    def monitor_model(self, model_id):
        pass

class AWSMLProvider(CloudMLProvider):
    def __init__(self, region='us-east-1'):
        self.sagemaker = boto3.client('sagemaker', region_name=region)
    
    def deploy_model(self, model_config):
        response = self.sagemaker.create_model(**model_config)
        return response['ModelArn']
    
    def create_endpoint(self, endpoint_config):
        # Create endpoint configuration
        self.sagemaker.create_endpoint_config(**endpoint_config)
        
        # Create endpoint
        endpoint_response = self.sagemaker.create_endpoint(
            EndpointName=endpoint_config['EndpointConfigName'],
            EndpointConfigName=endpoint_config['EndpointConfigName']
        )
        return endpoint_response['EndpointArn']
    
    def monitor_model(self, model_id):
        response = self.sagemaker.describe_endpoint(EndpointName=model_id)
        return response['EndpointStatus']

class AzureMLProvider(CloudMLProvider):
    def __init__(self, subscription_id, resource_group):
        credential = DefaultAzureCredential()
        self.ml_client = MachineLearningServicesMgmtClient(credential, subscription_id)
        self.resource_group = resource_group
    
    def deploy_model(self, model_config):
        # Azure ML deployment logic
        pass
    
    def create_endpoint(self, endpoint_config):
        # Azure ML endpoint creation logic
        pass
    
    def monitor_model(self, model_id):
        # Azure ML monitoring logic
        pass

class GCPMLProvider(CloudMLProvider):
    def __init__(self, project_id, location):
        aiplatform.init(project=project_id, location=location)
        self.project_id = project_id
        self.location = location
    
    def deploy_model(self, model_config):
        # Vertex AI deployment logic
        pass
    
    def create_endpoint(self, endpoint_config):
        # Vertex AI endpoint creation logic
        pass
    
    def monitor_model(self, model_id):
        # Vertex AI monitoring logic
        pass

class MultiCloudMLManager:
    def __init__(self):
        self.providers = {}
    
    def register_provider(self, name, provider):
        self.providers[name] = provider
    
    def deploy_to_multiple_clouds(self, model_config, cloud_list):
        deployment_results = {}
        
        for cloud in cloud_list:
            if cloud in self.providers:
                try:
                    result = self.providers[cloud].deploy_model(model_config[cloud])
                    deployment_results[cloud] = {'status': 'success', 'result': result}
                except Exception as e:
                    deployment_results[cloud] = {'status': 'failed', 'error': str(e)}
        
        return deployment_results
```

## Serverless ML Architectures

### Event-Driven ML Pipeline
```python
# serverless_ml_pipeline.py
import json
import boto3
from datetime import datetime

class ServerlessMLPipeline:
    def __init__(self):
        self.lambda_client = boto3.client('lambda')
        self.s3_client = boto3.client('s3')
        self.sns_client = boto3.client('sns')
    
    def trigger_data_processing(self, s3_event):
        """Lambda function triggered by S3 data upload"""
        bucket = s3_event['Records'][0]['s3']['bucket']['name']
        key = s3_event['Records'][0]['s3']['object']['key']
        
        # Invoke data processing function
        payload = {
            'bucket': bucket,
            'key': key,
            'timestamp': datetime.now().isoformat()
        }
        
        response = self.lambda_client.invoke(
            FunctionName='data-processing-function',
            InvocationType='Event',
            Payload=json.dumps(payload)
        )
        
        return response
    
    def process_data(self, event):
        """Data processing Lambda function"""
        bucket = event['bucket']
        key = event['key']
        
        # Download and process data
        obj = self.s3_client.get_object(Bucket=bucket, Key=key)
        data = obj['Body'].read()
        
        # Process data (feature engineering, validation, etc.)
        processed_data = self.transform_data(data)
        
        # Save processed data
        processed_key = f"processed/{key}"
        self.s3_client.put_object(
            Bucket=bucket,
            Key=processed_key,
            Body=processed_data
        )
        
        # Trigger model training if enough data
        if self.should_trigger_training():
            self.trigger_model_training(bucket, processed_key)
        
        return {'status': 'success', 'processed_key': processed_key}
    
    def trigger_model_training(self, bucket, data_key):
        """Trigger model training function"""
        payload = {
            'training_data': f"s3://{bucket}/{data_key}",
            'timestamp': datetime.now().isoformat()
        }
        
        response = self.lambda_client.invoke(
            FunctionName='model-training-function',
            InvocationType='Event',
            Payload=json.dumps(payload)
        )
        
        return response
    
    def train_model(self, event):
        """Model training Lambda function"""
        training_data_uri = event['training_data']
        
        # Start SageMaker training job
        sagemaker = boto3.client('sagemaker')
        
        training_job_config = {
            'TrainingJobName': f"training-job-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
            'AlgorithmSpecification': {
                'TrainingImage': 'your-training-image-uri',
                'TrainingInputMode': 'File'
            },
            'RoleArn': 'your-sagemaker-role-arn',
            'InputDataConfig': [
                {
                    'ChannelName': 'training',
                    'DataSource': {
                        'S3DataSource': {
                            'S3DataType': 'S3Prefix',
                            'S3Uri': training_data_uri,
                            'S3DataDistributionType': 'FullyReplicated'
                        }
                    }
                }
            ],
            'OutputDataConfig': {
                'S3OutputPath': 's3://your-model-bucket/models/'
            },
            'ResourceConfig': {
                'InstanceType': 'ml.m5.large',
                'InstanceCount': 1,
                'VolumeSizeInGB': 30
            },
            'StoppingCondition': {
                'MaxRuntimeInSeconds': 3600
            }
        }
        
        response = sagemaker.create_training_job(**training_job_config)
        
        return {'training_job_arn': response['TrainingJobArn']}
```

## Cost Optimization Strategies

### Cloud Cost Management
```python
# cost_optimization.py
import boto3
from datetime import datetime, timedelta

class CloudCostOptimizer:
    def __init__(self):
        self.ce_client = boto3.client('ce')  # Cost Explorer
        self.ec2_client = boto3.client('ec2')
        self.sagemaker_client = boto3.client('sagemaker')
    
    def analyze_ml_costs(self, start_date, end_date):
        """Analyze ML service costs"""
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['BlendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'}
            ],
            Filter={
                'Dimensions': {
                    'Key': 'SERVICE',
                    'Values': ['Amazon SageMaker', 'AWS Lambda', 'Amazon EC2']
                }
            }
        )
        
        return response['ResultsByTime']
    
    def optimize_sagemaker_endpoints(self):
        """Optimize SageMaker endpoint costs"""
        endpoints = self.sagemaker_client.list_endpoints()
        
        optimization_recommendations = []
        
        for endpoint in endpoints['Endpoints']:
            endpoint_name = endpoint['EndpointName']
            
            # Get endpoint configuration
            config = self.sagemaker_client.describe_endpoint_config(
                EndpointConfigName=endpoint['EndpointConfigName']
            )
            
            # Check utilization (simplified)
            utilization = self.get_endpoint_utilization(endpoint_name)
            
            if utilization < 0.3:  # Less than 30% utilization
                optimization_recommendations.append({
                    'endpoint': endpoint_name,
                    'recommendation': 'Consider using smaller instance type or auto-scaling',
                    'current_utilization': utilization
                })
        
        return optimization_recommendations
    
    def recommend_spot_instances(self):
        """Recommend spot instances for training jobs"""
        # Get recent training jobs
        training_jobs = self.sagemaker_client.list_training_jobs(
            MaxResults=50,
            StatusEquals='Completed'
        )
        
        spot_recommendations = []
        
        for job in training_jobs['TrainingJobSummaries']:
            job_details = self.sagemaker_client.describe_training_job(
                TrainingJobName=job['TrainingJobName']
            )
            
            # Check if job used on-demand instances
            if not job_details.get('EnableManagedSpotTraining', False):
                duration = (job_details['TrainingEndTime'] - job_details['TrainingStartTime']).total_seconds()
                
                if duration > 3600:  # Jobs longer than 1 hour
                    spot_recommendations.append({
                        'job_name': job['TrainingJobName'],
                        'duration_hours': duration / 3600,
                        'potential_savings': '60-90%'
                    })
        
        return spot_recommendations
    
    def get_endpoint_utilization(self, endpoint_name):
        """Get endpoint utilization metrics (simplified)"""
        # In practice, you would use CloudWatch metrics
        # This is a simplified placeholder
        return 0.25  # 25% utilization
```

## Security and Compliance

### ML Security Framework
```python
# ml_security.py
import boto3
import json
from cryptography.fernet import Fernet

class MLSecurityManager:
    def __init__(self):
        self.kms_client = boto3.client('kms')
        self.iam_client = boto3.client('iam')
        self.secrets_client = boto3.client('secretsmanager')
    
    def encrypt_model_data(self, model_data, kms_key_id):
        """Encrypt model data using AWS KMS"""
        response = self.kms_client.encrypt(
            KeyId=kms_key_id,
            Plaintext=model_data
        )
        return response['CiphertextBlob']
    
    def create_ml_execution_role(self, role_name, policies):
        """Create IAM role for ML services"""
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": ["sagemaker.amazonaws.com", "lambda.amazonaws.com"]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        
        # Create role
        role_response = self.iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy)
        )
        
        # Attach policies
        for policy_arn in policies:
            self.iam_client.attach_role_policy(
                RoleName=role_name,
                PolicyArn=policy_arn
            )
        
        return role_response['Role']['Arn']
    
    def store_model_credentials(self, secret_name, credentials):
        """Store model credentials in AWS Secrets Manager"""
        response = self.secrets_client.create_secret(
            Name=secret_name,
            SecretString=json.dumps(credentials)
        )
        return response['ARN']
    
    def audit_ml_access(self, resource_arn):
        """Audit access to ML resources"""
        # Use AWS CloudTrail to audit access
        cloudtrail = boto3.client('cloudtrail')
        
        events = cloudtrail.lookup_events(
            LookupAttributes=[
                {
                    'AttributeKey': 'ResourceName',
                    'AttributeValue': resource_arn
                }
            ]
        )
        
        return events['Events']
```

## Best Practices

1. **Multi-Cloud Strategy**: Avoid vendor lock-in with cloud-agnostic designs
2. **Cost Optimization**: Use spot instances, auto-scaling, and right-sizing
3. **Security**: Implement encryption, access controls, and audit logging
4. **Monitoring**: Comprehensive monitoring across all cloud services
5. **Automation**: Automate deployment and management tasks
6. **Compliance**: Ensure regulatory compliance across all clouds
7. **Disaster Recovery**: Implement cross-region backup and recovery
8. **Performance**: Optimize for latency and throughput requirements

## Conclusion

Cloud ML services provide powerful platforms for implementing MLOps at scale. Success requires understanding each provider's strengths, implementing proper security and cost controls, and designing for portability and resilience across cloud environments.