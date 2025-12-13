# Serverless Microservices Architecture

## Overview

Serverless microservices combine the benefits of microservices architecture with serverless computing, enabling highly scalable, loosely coupled services that automatically scale based on demand.

## Core Principles

### 1. Service Independence
- Each service owns its data and business logic
- Independent deployment and scaling
- Technology stack flexibility per service
- Fault isolation between services

### 2. Event-Driven Communication
- Asynchronous messaging between services
- Event sourcing and CQRS patterns
- Loose coupling through events
- Eventual consistency models

## Architecture Patterns

### API Gateway Pattern
```yaml
# serverless.yml - API Gateway service
service: user-service

provider:
  name: aws
  runtime: nodejs18.x

functions:
  getUser:
    handler: handlers/users.get
    events:
      - http:
          path: /users/{id}
          method: get
          cors: true
  
  createUser:
    handler: handlers/users.create
    events:
      - http:
          path: /users
          method: post
          cors: true

  updateUser:
    handler: handlers/users.update
    events:
      - http:
          path: /users/{id}
          method: put
          cors: true
```

### Event-Driven Services
```javascript
// Order service - publishes events
const AWS = require('aws-sdk');
const sns = new AWS.SNS();

exports.createOrder = async (event) => {
  try {
    const order = JSON.parse(event.body);
    
    // Save order to database
    const savedOrder = await saveOrder(order);
    
    // Publish order created event
    await sns.publish({
      TopicArn: process.env.ORDER_EVENTS_TOPIC,
      Message: JSON.stringify({
        eventType: 'OrderCreated',
        orderId: savedOrder.id,
        customerId: savedOrder.customerId,
        amount: savedOrder.amount,
        timestamp: new Date().toISOString()
      })
    }).promise();
    
    return {
      statusCode: 201,
      body: JSON.stringify(savedOrder)
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};

// Inventory service - consumes events
exports.handleOrderCreated = async (event) => {
  for (const record of event.Records) {
    const message = JSON.parse(record.Sns.Message);
    
    if (message.eventType === 'OrderCreated') {
      await updateInventory(message.orderId);
      
      // Publish inventory updated event
      await sns.publish({
        TopicArn: process.env.INVENTORY_EVENTS_TOPIC,
        Message: JSON.stringify({
          eventType: 'InventoryUpdated',
          orderId: message.orderId,
          timestamp: new Date().toISOString()
        })
      }).promise();
    }
  }
};
```

## Service Communication Patterns

### Synchronous Communication
```javascript
// Service-to-service HTTP calls
const axios = require('axios');

exports.getUserProfile = async (event) => {
  const userId = event.pathParameters.id;
  
  try {
    // Call user service
    const userResponse = await axios.get(`${process.env.USER_SERVICE_URL}/users/${userId}`);
    
    // Call preferences service
    const preferencesResponse = await axios.get(`${process.env.PREFERENCES_SERVICE_URL}/preferences/${userId}`);
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        user: userResponse.data,
        preferences: preferencesResponse.data
      })
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to fetch user profile' })
    };
  }
};
```

### Asynchronous Communication
```python
# Event-driven communication with SQS
import json
import boto3

sqs = boto3.client('sqs')
sns = boto3.client('sns')

def process_payment(event, context):
    for record in event['Records']:
        try:
            # Parse order event
            order_data = json.loads(record['body'])
            
            # Process payment
            payment_result = process_payment_logic(order_data)
            
            # Send result to payment events queue
            event_data = {
                'eventType': 'PaymentProcessed',
                'orderId': order_data['orderId'],
                'status': payment_result['status'],
                'transactionId': payment_result['transactionId']
            }
            
            sqs.send_message(
                QueueUrl=os.environ['PAYMENT_EVENTS_QUEUE'],
                MessageBody=json.dumps(event_data)
            )
            
        except Exception as e:
            # Send to DLQ for retry
            print(f"Payment processing failed: {e}")
            raise

def process_payment_logic(order_data):
    # Payment processing implementation
    return {
        'status': 'completed',
        'transactionId': 'txn_123456'
    }
```

## Data Management Patterns

### Database per Service
```yaml
# Each service has its own database
resources:
  Resources:
    UserTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:service}-users-${opt:stage}
        AttributeDefinitions:
          - AttributeName: userId
            AttributeType: S
        KeySchema:
          - AttributeName: userId
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

    OrderTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:service}-orders-${opt:stage}
        AttributeDefinitions:
          - AttributeName: orderId
            AttributeType: S
        KeySchema:
          - AttributeName: orderId
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST
```

### Event Sourcing Pattern
```javascript
// Event store implementation
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

class EventStore {
  constructor(tableName) {
    this.tableName = tableName;
  }
  
  async saveEvent(aggregateId, event) {
    const eventRecord = {
      aggregateId,
      eventId: generateUUID(),
      eventType: event.type,
      eventData: event.data,
      timestamp: new Date().toISOString(),
      version: await this.getNextVersion(aggregateId)
    };
    
    await dynamodb.put({
      TableName: this.tableName,
      Item: eventRecord
    }).promise();
    
    return eventRecord;
  }
  
  async getEvents(aggregateId) {
    const result = await dynamodb.query({
      TableName: this.tableName,
      KeyConditionExpression: 'aggregateId = :id',
      ExpressionAttributeValues: {
        ':id': aggregateId
      },
      ScanIndexForward: true
    }).promise();
    
    return result.Items;
  }
  
  async getNextVersion(aggregateId) {
    const events = await this.getEvents(aggregateId);
    return events.length + 1;
  }
}

// Usage in order service
exports.createOrder = async (event) => {
  const eventStore = new EventStore(process.env.EVENT_STORE_TABLE);
  const orderData = JSON.parse(event.body);
  
  const orderEvent = {
    type: 'OrderCreated',
    data: {
      orderId: generateUUID(),
      customerId: orderData.customerId,
      items: orderData.items,
      amount: orderData.amount
    }
  };
  
  await eventStore.saveEvent(orderEvent.data.orderId, orderEvent);
  
  return {
    statusCode: 201,
    body: JSON.stringify(orderEvent.data)
  };
};
```

## Service Discovery and Configuration

### AWS Systems Manager Parameter Store
```javascript
// Service configuration management
const AWS = require('aws-sdk');
const ssm = new AWS.SSM();

class ConfigService {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 5 * 60 * 1000; // 5 minutes
  }
  
  async getConfig(parameterName) {
    const cacheKey = parameterName;
    const cached = this.cache.get(cacheKey);
    
    if (cached && (Date.now() - cached.timestamp) < this.cacheTimeout) {
      return cached.value;
    }
    
    try {
      const result = await ssm.getParameter({
        Name: parameterName,
        WithDecryption: true
      }).promise();
      
      const value = result.Parameter.Value;
      this.cache.set(cacheKey, {
        value,
        timestamp: Date.now()
      });
      
      return value;
    } catch (error) {
      console.error(`Failed to get parameter ${parameterName}:`, error);
      throw error;
    }
  }
}

// Usage
const configService = new ConfigService();

exports.handler = async (event) => {
  const databaseUrl = await configService.getConfig('/myapp/database/url');
  const apiKey = await configService.getConfig('/myapp/external-api/key');
  
  // Use configuration values
};
```

### Service Registry Pattern
```python
# Service registry with DynamoDB
import boto3
import json
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['SERVICE_REGISTRY_TABLE'])

def register_service(event, context):
    service_info = json.loads(event['body'])
    
    # Register service instance
    table.put_item(
        Item={
            'serviceName': service_info['name'],
            'instanceId': service_info['instanceId'],
            'endpoint': service_info['endpoint'],
            'version': service_info['version'],
            'status': 'healthy',
            'lastHeartbeat': int(time.time()),
            'metadata': service_info.get('metadata', {})
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Service registered successfully'})
    }

def discover_service(event, context):
    service_name = event['pathParameters']['serviceName']
    
    # Get healthy service instances
    response = table.query(
        KeyConditionExpression='serviceName = :name',
        FilterExpression='#status = :status',
        ExpressionAttributeNames={'#status': 'status'},
        ExpressionAttributeValues={
            ':name': service_name,
            ':status': 'healthy'
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }
```

## Security Patterns

### JWT Token Validation
```javascript
// JWT authorizer function
const jwt = require('jsonwebtoken');

exports.authorize = async (event) => {
  try {
    const token = event.authorizationToken.replace('Bearer ', '');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    return {
      principalId: decoded.sub,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Allow',
            Resource: event.methodArn
          }
        ]
      },
      context: {
        userId: decoded.sub,
        email: decoded.email,
        roles: JSON.stringify(decoded.roles || [])
      }
    };
  } catch (error) {
    throw new Error('Unauthorized');
  }
};
```

### Service-to-Service Authentication
```python
# Service authentication with API keys
import boto3
import hashlib
import hmac
import base64

def authenticate_service_request(event, context):
    # Extract headers
    api_key = event['headers'].get('X-API-Key')
    signature = event['headers'].get('X-Signature')
    timestamp = event['headers'].get('X-Timestamp')
    
    if not all([api_key, signature, timestamp]):
        return generate_policy('Deny')
    
    # Validate timestamp (prevent replay attacks)
    current_time = int(time.time())
    request_time = int(timestamp)
    if abs(current_time - request_time) > 300:  # 5 minutes
        return generate_policy('Deny')
    
    # Verify signature
    secret = get_service_secret(api_key)
    if not secret:
        return generate_policy('Deny')
    
    expected_signature = generate_signature(event['body'], secret, timestamp)
    if not hmac.compare_digest(signature, expected_signature):
        return generate_policy('Deny')
    
    return generate_policy('Allow')

def generate_signature(body, secret, timestamp):
    message = f"{body}{timestamp}"
    signature = hmac.new(
        secret.encode('utf-8'),
        message.encode('utf-8'),
        hashlib.sha256
    ).digest()
    return base64.b64encode(signature).decode('utf-8')
```

## Monitoring and Observability

### Distributed Tracing
```javascript
// AWS X-Ray tracing
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

exports.processOrder = async (event) => {
  const segment = AWSXRay.getSegment();
  
  // Create subsegment for external service call
  const subsegment = segment.addNewSubsegment('payment-service');
  
  try {
    subsegment.addAnnotation('orderId', event.orderId);
    subsegment.addMetadata('orderData', event);
    
    const paymentResult = await callPaymentService(event);
    
    subsegment.addAnnotation('paymentStatus', paymentResult.status);
    subsegment.close();
    
    return paymentResult;
  } catch (error) {
    subsegment.addError(error);
    subsegment.close();
    throw error;
  }
};
```

### Centralized Logging
```python
# Structured logging for microservices
import json
import logging
import uuid
from datetime import datetime

class StructuredLogger:
    def __init__(self, service_name):
        self.service_name = service_name
        self.logger = logging.getLogger(service_name)
        
    def log(self, level, message, **kwargs):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'service': self.service_name,
            'level': level,
            'message': message,
            'correlation_id': kwargs.get('correlation_id'),
            'user_id': kwargs.get('user_id'),
            'request_id': kwargs.get('request_id'),
            'extra': {k: v for k, v in kwargs.items() 
                     if k not in ['correlation_id', 'user_id', 'request_id']}
        }
        
        self.logger.info(json.dumps(log_entry))

# Usage
logger = StructuredLogger('order-service')

def lambda_handler(event, context):
    correlation_id = event.get('headers', {}).get('X-Correlation-ID', str(uuid.uuid4()))
    
    logger.log('INFO', 'Processing order', 
               correlation_id=correlation_id,
               order_id=event.get('orderId'))
```

## Testing Strategies

### Unit Testing
```javascript
// Jest tests for microservice functions
const { processOrder } = require('../src/orderService');

jest.mock('aws-sdk');

describe('Order Service', () => {
  test('should process valid order', async () => {
    const mockEvent = {
      body: JSON.stringify({
        customerId: '123',
        items: [{ id: 'item1', quantity: 2 }],
        amount: 100
      })
    };
    
    const result = await processOrder(mockEvent);
    
    expect(result.statusCode).toBe(201);
    expect(JSON.parse(result.body)).toHaveProperty('orderId');
  });
  
  test('should handle invalid order data', async () => {
    const mockEvent = {
      body: JSON.stringify({})
    };
    
    const result = await processOrder(mockEvent);
    
    expect(result.statusCode).toBe(400);
  });
});
```

### Integration Testing
```python
# Integration tests with localstack
import boto3
import pytest
import json
from moto import mock_dynamodb, mock_sns

@mock_dynamodb
@mock_sns
def test_order_workflow():
    # Setup mock AWS services
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    sns = boto3.client('sns', region_name='us-east-1')
    
    # Create test table
    table = dynamodb.create_table(
        TableName='orders',
        KeySchema=[{'AttributeName': 'orderId', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'orderId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    # Test order creation
    from src.order_service import create_order
    
    event = {
        'body': json.dumps({
            'customerId': 'test-customer',
            'items': [{'id': 'item1', 'quantity': 1}],
            'amount': 50
        })
    }
    
    result = create_order(event, {})
    
    assert result['statusCode'] == 201
    order_data = json.loads(result['body'])
    assert 'orderId' in order_data
```

## Best Practices

### 1. Service Design
- Single responsibility per service
- Domain-driven design principles
- API versioning strategy
- Backward compatibility

### 2. Communication Patterns
- Prefer asynchronous communication
- Implement circuit breakers
- Use idempotent operations
- Handle partial failures gracefully

### 3. Data Management
- Database per service
- Event sourcing for audit trails
- CQRS for read/write separation
- Eventual consistency acceptance

### 4. Security
- Zero-trust architecture
- Service-to-service authentication
- Input validation and sanitization
- Secrets management

### 5. Operational Excellence
- Comprehensive monitoring
- Distributed tracing
- Centralized logging
- Automated testing and deployment