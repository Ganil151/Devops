# Functions as a Service (FaaS)

## Overview
Functions as a Service (FaaS) is the core component of serverless computing, allowing developers to deploy individual functions that execute in response to events without managing the underlying infrastructure.

## AWS Lambda

### Lambda Function Structure
```python
# Basic Lambda function
import json
import boto3

def lambda_handler(event, context):
    """
    AWS Lambda function handler
    
    Args:
        event: Event data passed to the function
        context: Runtime information about the function
    
    Returns:
        Response object with statusCode and body
    """
    
    # Process the event
    try:
        # Your business logic here
        result = process_event(event)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(result)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def process_event(event):
    # Business logic implementation
    return {'message': 'Event processed successfully'}
```

### Lambda Configuration
```yaml
# serverless.yml for AWS Lambda
service: my-serverless-app

provider:
  name: aws
  runtime: python3.9
  region: us-east-1
  memorySize: 512
  timeout: 30
  environment:
    TABLE_NAME: ${self:service}-${self:provider.stage}-table
  
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/${self:provider.environment.TABLE_NAME}"

functions:
  api:
    handler: handler.lambda_handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true
      - schedule: rate(5 minutes)
  
  processor:
    handler: processor.handle
    events:
      - s3:
          bucket: my-upload-bucket
          event: s3:ObjectCreated:*
          rules:
            - prefix: uploads/
            - suffix: .json

resources:
  Resources:
    DynamoDbTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:provider.environment.TABLE_NAME}
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST
```

### Lambda Layers
```python
# Using Lambda Layers for shared code
# Layer structure:
# layer/
# └── python/
#     └── shared/
#         ├── __init__.py
#         ├── database.py
#         └── utils.py

# In your function code
import sys
sys.path.append('/opt/python')

from shared.database import get_connection
from shared.utils import validate_input

def lambda_handler(event, context):
    # Use shared utilities
    if not validate_input(event):
        return {'statusCode': 400, 'body': 'Invalid input'}
    
    # Use shared database connection
    conn = get_connection()
    # Process request...
```

## Azure Functions

### Azure Function Structure
```python
# Azure Functions with Python
import azure.functions as func
import json
import logging

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function HTTP trigger
    
    Args:
        req: HTTP request object
    
    Returns:
        HTTP response object
    """
    logging.info('Python HTTP trigger function processed a request.')
    
    try:
        # Get request data
        req_body = req.get_json()
        
        # Process the request
        result = process_request(req_body)
        
        return func.HttpResponse(
            json.dumps(result),
            status_code=200,
            headers={'Content-Type': 'application/json'}
        )
    
    except ValueError as e:
        return func.HttpResponse(
            json.dumps({'error': 'Invalid JSON'}),
            status_code=400
        )
    except Exception as e:
        logging.error(f'Error processing request: {str(e)}')
        return func.HttpResponse(
            json.dumps({'error': 'Internal server error'}),
            status_code=500
        )

def process_request(data):
    # Business logic implementation
    return {'message': 'Request processed successfully', 'data': data}
```

### Azure Functions Configuration
```json
// function.json
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ]
}
```

```json
// host.json
{
  "version": "2.0",
  "functionTimeout": "00:05:00",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[2.*, 3.0.0)"
  }
}
```

### Azure Functions with Cosmos DB
```python
# Azure Function with Cosmos DB binding
import azure.functions as func
import json

def main(req: func.HttpRequest, doc: func.DocumentList) -> func.HttpResponse:
    """
    Function with Cosmos DB input binding
    """
    
    # Read from Cosmos DB
    documents = []
    for item in doc:
        documents.append(item.to_dict())
    
    return func.HttpResponse(
        json.dumps(documents),
        status_code=200,
        headers={'Content-Type': 'application/json'}
    )

# Cosmos DB output binding
def cosmos_output(req: func.HttpRequest) -> func.Out[func.Document]:
    """
    Function with Cosmos DB output binding
    """
    req_body = req.get_json()
    
    # Create document for Cosmos DB
    document = func.Document.from_dict({
        'id': req_body.get('id'),
        'name': req_body.get('name'),
        'timestamp': req_body.get('timestamp')
    })
    
    return document
```

## Google Cloud Functions

### Cloud Functions Structure
```python
# Google Cloud Functions
import functions_framework
import json
from google.cloud import firestore

@functions_framework.http
def http_function(request):
    """
    HTTP Cloud Function
    
    Args:
        request: HTTP request object
    
    Returns:
        HTTP response
    """
    
    # Handle CORS
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    # Set CORS headers for main request
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        # Process request
        request_json = request.get_json(silent=True)
        
        if request_json and 'name' in request_json:
            name = request_json['name']
        else:
            name = 'World'
        
        result = {'message': f'Hello {name}!'}
        
        return (json.dumps(result), 200, headers)
    
    except Exception as e:
        error_response = {'error': str(e)}
        return (json.dumps(error_response), 500, headers)

@functions_framework.cloud_event
def event_function(cloud_event):
    """
    CloudEvent function for Pub/Sub, Storage, etc.
    
    Args:
        cloud_event: CloudEvent object
    """
    
    # Process the event
    event_data = cloud_event.data
    
    # Initialize Firestore client
    db = firestore.Client()
    
    # Store event data
    doc_ref = db.collection('events').document()
    doc_ref.set({
        'event_type': cloud_event.get_type(),
        'source': cloud_event.get_source(),
        'data': event_data,
        'timestamp': firestore.SERVER_TIMESTAMP
    })
    
    print(f'Processed event: {cloud_event.get_type()}')
```

### Cloud Functions Deployment
```yaml
# cloudbuild.yaml for CI/CD
steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - functions
      - deploy
      - my-function
      - --source=.
      - --trigger-http
      - --runtime=python39
      - --memory=512MB
      - --timeout=60s
      - --set-env-vars=PROJECT_ID=${PROJECT_ID}
      - --allow-unauthenticated

  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - functions
      - deploy
      - event-processor
      - --source=.
      - --trigger-topic=my-topic
      - --runtime=python39
      - --memory=256MB
```

## Function Development Best Practices

### Error Handling
```python
# Comprehensive error handling
import logging
import traceback
from functools import wraps

def error_handler(func):
    """Decorator for consistent error handling"""
    @wraps(func)
    def wrapper(event, context):
        try:
            return func(event, context)
        except ValueError as e:
            logging.error(f'Validation error: {str(e)}')
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid input'})
            }
        except Exception as e:
            logging.error(f'Unexpected error: {str(e)}')
            logging.error(traceback.format_exc())
            return {
                'statusCode': 500,
                'body': json.dumps({'error': 'Internal server error'})
            }
    return wrapper

@error_handler
def lambda_handler(event, context):
    # Your function logic here
    return process_event(event)
```

### Configuration Management
```python
# Environment-based configuration
import os
import json
from typing import Dict, Any

class Config:
    """Configuration management for serverless functions"""
    
    def __init__(self):
        self.environment = os.environ.get('ENVIRONMENT', 'dev')
        self.debug = os.environ.get('DEBUG', 'false').lower() == 'true'
        
        # Database configuration
        self.db_host = os.environ.get('DB_HOST')
        self.db_name = os.environ.get('DB_NAME')
        
        # API configuration
        self.api_key = os.environ.get('API_KEY')
        self.api_timeout = int(os.environ.get('API_TIMEOUT', '30'))
        
        # Feature flags
        self.feature_flags = self._load_feature_flags()
    
    def _load_feature_flags(self) -> Dict[str, bool]:
        """Load feature flags from environment"""
        flags_json = os.environ.get('FEATURE_FLAGS', '{}')
        try:
            return json.loads(flags_json)
        except json.JSONDecodeError:
            return {}
    
    def is_feature_enabled(self, feature_name: str) -> bool:
        """Check if a feature is enabled"""
        return self.feature_flags.get(feature_name, False)

# Usage in function
config = Config()

def lambda_handler(event, context):
    if config.is_feature_enabled('new_algorithm'):
        return new_algorithm_handler(event)
    else:
        return legacy_handler(event)
```

### Testing Strategies
```python
# Unit testing for serverless functions
import unittest
from unittest.mock import patch, MagicMock
import json

class TestLambdaFunction(unittest.TestCase):
    
    def setUp(self):
        """Set up test fixtures"""
        self.sample_event = {
            'httpMethod': 'POST',
            'path': '/api/users',
            'body': json.dumps({'name': 'John Doe', 'email': 'john@example.com'})
        }
        
        self.sample_context = MagicMock()
        self.sample_context.aws_request_id = 'test-request-id'
    
    @patch('boto3.resource')
    def test_successful_user_creation(self, mock_boto3):
        """Test successful user creation"""
        # Mock DynamoDB
        mock_table = MagicMock()
        mock_boto3.return_value.Table.return_value = mock_table
        
        # Execute function
        from handler import lambda_handler
        response = lambda_handler(self.sample_event, self.sample_context)
        
        # Assertions
        self.assertEqual(response['statusCode'], 201)
        mock_table.put_item.assert_called_once()
    
    def test_invalid_input(self):
        """Test handling of invalid input"""
        invalid_event = {
            'httpMethod': 'POST',
            'path': '/api/users',
            'body': json.dumps({'name': ''})  # Missing email
        }
        
        from handler import lambda_handler
        response = lambda_handler(invalid_event, self.sample_context)
        
        self.assertEqual(response['statusCode'], 400)
    
    @patch('boto3.resource')
    def test_database_error(self, mock_boto3):
        """Test database error handling"""
        # Mock database error
        mock_table = MagicMock()
        mock_table.put_item.side_effect = Exception('Database connection failed')
        mock_boto3.return_value.Table.return_value = mock_table
        
        from handler import lambda_handler
        response = lambda_handler(self.sample_event, self.sample_context)
        
        self.assertEqual(response['statusCode'], 500)

if __name__ == '__main__':
    unittest.main()
```

### Performance Optimization
```python
# Performance optimization techniques
import time
import functools
from concurrent.futures import ThreadPoolExecutor
import asyncio

# Connection pooling
class ConnectionPool:
    def __init__(self):
        self._connections = {}
    
    def get_connection(self, service_name):
        if service_name not in self._connections:
            self._connections[service_name] = create_connection(service_name)
        return self._connections[service_name]

# Global connection pool (survives warm starts)
connection_pool = ConnectionPool()

# Caching decorator
def cache_result(ttl_seconds=300):
    def decorator(func):
        cache = {}
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(sorted(kwargs.items()))
            now = time.time()
            
            if key in cache:
                result, timestamp = cache[key]
                if now - timestamp < ttl_seconds:
                    return result
            
            result = func(*args, **kwargs)
            cache[key] = (result, now)
            return result
        
        return wrapper
    return decorator

# Parallel processing
def process_items_parallel(items, max_workers=5):
    """Process items in parallel using ThreadPoolExecutor"""
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(process_item, item) for item in items]
        results = [future.result() for future in futures]
    return results

# Async processing
async def process_items_async(items):
    """Process items asynchronously"""
    tasks = [process_item_async(item) for item in items]
    results = await asyncio.gather(*tasks)
    return results

@cache_result(ttl_seconds=600)
def get_configuration():
    """Cached configuration retrieval"""
    # Expensive configuration lookup
    return fetch_from_parameter_store()

def optimized_handler(event, context):
    """Optimized function handler"""
    # Use cached configuration
    config = get_configuration()
    
    # Use connection pooling
    db_conn = connection_pool.get_connection('database')
    
    # Process items in parallel if needed
    items = event.get('items', [])
    if len(items) > 10:
        results = process_items_parallel(items)
    else:
        results = [process_item(item) for item in items]
    
    return {
        'statusCode': 200,
        'body': json.dumps({'results': results})
    }
```

This comprehensive guide covers the essential aspects of Functions as a Service across major cloud providers, providing practical examples and best practices for serverless function development.