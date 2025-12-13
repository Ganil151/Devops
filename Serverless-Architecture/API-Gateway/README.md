# API Gateway for Serverless Architecture

## Overview
API Gateway serves as the front door for serverless applications, providing a unified entry point for client requests and routing them to appropriate backend services. It handles authentication, rate limiting, request/response transformation, and monitoring.

## AWS API Gateway

### REST API Configuration
```yaml
# serverless.yml for API Gateway REST API
service: serverless-api

provider:
  name: aws
  runtime: python3.9
  region: us-east-1

functions:
  getUsers:
    handler: handlers/users.get_users
    events:
      - http:
          path: /users
          method: get
          cors: true
          authorizer:
            name: customAuthorizer
            type: request
  
  createUser:
    handler: handlers/users.create_user
    events:
      - http:
          path: /users
          method: post
          cors: true
          request:
            schema:
              application/json: ${file(schemas/user-schema.json)}
  
  getUserById:
    handler: handlers/users.get_user_by_id
    events:
      - http:
          path: /users/{id}
          method: get
          cors: true
          request:
            parameters:
              paths:
                id: true
  
  customAuthorizer:
    handler: handlers/auth.authorize

resources:
  Resources:
    # API Gateway configuration
    ApiGatewayRestApi:
      Type: AWS::ApiGateway::RestApi
      Properties:
        Name: ${self:service}-${self:provider.stage}
        Description: Serverless API Gateway
        EndpointConfiguration:
          Types:
            - REGIONAL
        Policy:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Principal: '*'
              Action: execute-api:Invoke
              Resource: '*'
    
    # Request/Response models
    UserModel:
      Type: AWS::ApiGateway::Model
      Properties:
        RestApiId: !Ref ApiGatewayRestApi
        ContentType: application/json
        Schema:
          $schema: http://json-schema.org/draft-04/schema#
          type: object
          properties:
            name:
              type: string
            email:
              type: string
              format: email
            age:
              type: integer
              minimum: 0
          required:
            - name
            - email
```

### HTTP API (API Gateway v2)
```yaml
# HTTP API configuration (faster and cheaper)
service: serverless-http-api

provider:
  name: aws
  runtime: python3.9
  httpApi:
    cors:
      allowedOrigins:
        - https://mydomain.com
        - http://localhost:3000
      allowedHeaders:
        - Content-Type
        - Authorization
      allowedMethods:
        - GET
        - POST
        - PUT
        - DELETE
      allowCredentials: true
    
    authorizers:
      jwtAuthorizer:
        type: jwt
        identitySource: $request.header.Authorization
        issuerUrl: https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XXXXXXXXX
        audience:
          - your-client-id

functions:
  api:
    handler: handler.main
    events:
      - httpApi:
          path: /{proxy+}
          method: '*'
          authorizer:
            name: jwtAuthorizer
```

### Custom Authorizer
```python
# Custom Lambda authorizer
import json
import jwt
from jwt.exceptions import InvalidTokenError

def authorize(event, context):
    """
    Custom authorizer for API Gateway
    """
    
    try:
        # Extract token from Authorization header
        token = event['authorizationToken'].replace('Bearer ', '')
        
        # Validate JWT token
        decoded_token = jwt.decode(
            token,
            'your-secret-key',
            algorithms=['HS256']
        )
        
        # Extract user information
        user_id = decoded_token['sub']
        user_role = decoded_token.get('role', 'user')
        
        # Generate policy
        policy = generate_policy(user_id, 'Allow', event['methodArn'], user_role)
        
        return policy
        
    except InvalidTokenError:
        # Invalid token
        raise Exception('Unauthorized')
    except Exception as e:
        # Other errors
        print(f"Authorization error: {str(e)}")
        raise Exception('Unauthorized')

def generate_policy(principal_id, effect, resource, user_role=None):
    """Generate IAM policy for API Gateway"""
    
    policy = {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        },
        'context': {
            'userId': principal_id,
            'userRole': user_role or 'user'
        }
    }
    
    return policy

# Usage in Lambda function
def get_users(event, context):
    """Get users with authorization context"""
    
    # Access authorization context
    user_id = event['requestContext']['authorizer']['userId']
    user_role = event['requestContext']['authorizer']['userRole']
    
    # Apply role-based filtering
    if user_role == 'admin':
        users = get_all_users()
    else:
        users = get_user_data(user_id)
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(users)
    }
```

### Rate Limiting and Throttling
```yaml
# API Gateway usage plans and API keys
resources:
  Resources:
    # Usage Plan
    ApiUsagePlan:
      Type: AWS::ApiGateway::UsagePlan
      Properties:
        UsagePlanName: ${self:service}-usage-plan
        Description: Usage plan for API rate limiting
        Throttle:
          RateLimit: 1000    # requests per second
          BurstLimit: 2000   # burst capacity
        Quota:
          Limit: 10000       # requests per period
          Period: DAY        # DAY, WEEK, MONTH
        ApiStages:
          - ApiId: !Ref ApiGatewayRestApi
            Stage: ${self:provider.stage}
    
    # API Key
    ApiKey:
      Type: AWS::ApiGateway::ApiKey
      Properties:
        Name: ${self:service}-api-key
        Description: API Key for rate limiting
        Enabled: true
    
    # Link API Key to Usage Plan
    ApiUsagePlanKey:
      Type: AWS::ApiGateway::UsagePlanKey
      Properties:
        KeyId: !Ref ApiKey
        KeyType: API_KEY
        UsagePlanId: !Ref ApiUsagePlan

# Function with API key requirement
functions:
  protectedEndpoint:
    handler: handlers/protected.handler
    events:
      - http:
          path: /protected
          method: get
          private: true  # Requires API key
```

## Azure API Management

### API Management Configuration
```yaml
# Azure API Management with ARM template
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "apiManagementServiceName": {
      "type": "string",
      "defaultValue": "my-apim-service"
    }
  },
  "resources": [
    {
      "type": "Microsoft.ApiManagement/service",
      "apiVersion": "2021-08-01",
      "name": "[parameters('apiManagementServiceName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "Developer",
        "capacity": 1
      },
      "properties": {
        "publisherEmail": "admin@example.com",
        "publisherName": "API Publisher"
      }
    },
    {
      "type": "Microsoft.ApiManagement/service/apis",
      "apiVersion": "2021-08-01",
      "name": "[concat(parameters('apiManagementServiceName'), '/users-api')]",
      "dependsOn": [
        "[resourceId('Microsoft.ApiManagement/service', parameters('apiManagementServiceName'))]"
      ],
      "properties": {
        "displayName": "Users API",
        "description": "API for user management",
        "serviceUrl": "https://my-function-app.azurewebsites.net/api",
        "path": "users",
        "protocols": ["https"],
        "subscriptionRequired": true
      }
    }
  ]
}
```

### Azure Functions with API Management
```python
# Azure Function with API Management integration
import azure.functions as func
import json
import logging

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function integrated with API Management
    """
    
    logging.info('Processing request through API Management')
    
    try:
        # Get subscription key from headers (set by APIM)
        subscription_key = req.headers.get('Ocp-Apim-Subscription-Key')
        
        # Get user context from APIM headers
        user_id = req.headers.get('X-User-Id')
        user_role = req.headers.get('X-User-Role')
        
        # Process request based on method
        method = req.method
        
        if method == 'GET':
            return handle_get_request(req, user_id, user_role)
        elif method == 'POST':
            return handle_post_request(req, user_id, user_role)
        else:
            return func.HttpResponse(
                json.dumps({'error': 'Method not allowed'}),
                status_code=405,
                headers={'Content-Type': 'application/json'}
            )
    
    except Exception as e:
        logging.error(f'Error processing request: {str(e)}')
        return func.HttpResponse(
            json.dumps({'error': 'Internal server error'}),
            status_code=500,
            headers={'Content-Type': 'application/json'}
        )

def handle_get_request(req, user_id, user_role):
    """Handle GET request"""
    
    # Apply role-based access control
    if user_role == 'admin':
        data = get_all_users()
    elif user_role == 'user':
        data = get_user_data(user_id)
    else:
        return func.HttpResponse(
            json.dumps({'error': 'Insufficient permissions'}),
            status_code=403,
            headers={'Content-Type': 'application/json'}
        )
    
    return func.HttpResponse(
        json.dumps(data),
        status_code=200,
        headers={'Content-Type': 'application/json'}
    )
```

### API Management Policies
```xml
<!-- Inbound policy for rate limiting and authentication -->
<policies>
    <inbound>
        <!-- Rate limiting -->
        <rate-limit calls="100" renewal-period="60" />
        
        <!-- Validate JWT token -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/common/.well-known/openid_configuration" />
            <required-claims>
                <claim name="aud" match="all">
                    <value>your-client-id</value>
                </claim>
            </required-claims>
        </validate-jwt>
        
        <!-- Set backend URL -->
        <set-backend-service base-url="https://my-function-app.azurewebsites.net/api" />
        
        <!-- Add user context headers -->
        <set-header name="X-User-Id" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Authorization","").AsJwt()?.Claims.GetValueOrDefault("sub", ""))</value>
        </set-header>
        
        <set-header name="X-User-Role" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Authorization","").AsJwt()?.Claims.GetValueOrDefault("role", "user"))</value>
        </set-header>
    </inbound>
    
    <backend>
        <base />
    </backend>
    
    <outbound>
        <!-- Remove sensitive headers -->
        <set-header name="X-Powered-By" exists-action="delete" />
        <set-header name="Server" exists-action="delete" />
        
        <!-- Add CORS headers -->
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>https://mydomain.com</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
                <method>PUT</method>
                <method>DELETE</method>
            </allowed-methods>
            <allowed-headers>
                <header>Content-Type</header>
                <header>Authorization</header>
            </allowed-headers>
        </cors>
    </outbound>
    
    <on-error>
        <!-- Error handling -->
        <set-body>@{
            return new JObject(
                new JProperty("error", context.LastError.Message),
                new JProperty("timestamp", DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"))
            ).ToString();
        }</set-body>
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
    </on-error>
</policies>
```

## Google Cloud Endpoints

### OpenAPI Specification
```yaml
# openapi.yaml for Google Cloud Endpoints
swagger: '2.0'
info:
  title: Users API
  description: API for user management
  version: 1.0.0
host: my-project.appspot.com
schemes:
  - https
produces:
  - application/json

securityDefinitions:
  api_key:
    type: apiKey
    name: key
    in: query
  firebase_auth:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://securetoken.google.com/YOUR_PROJECT_ID"
    x-google-jwks_uri: "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
    x-google-audiences: "YOUR_PROJECT_ID"

paths:
  /users:
    get:
      summary: Get all users
      operationId: getUsers
      security:
        - firebase_auth: []
      x-google-backend:
        address: https://us-central1-my-project.cloudfunctions.net/getUsers
      responses:
        200:
          description: List of users
          schema:
            type: array
            items:
              $ref: '#/definitions/User'
        401:
          description: Unauthorized
    
    post:
      summary: Create a new user
      operationId: createUser
      security:
        - api_key: []
      x-google-backend:
        address: https://us-central1-my-project.cloudfunctions.net/createUser
      parameters:
        - name: user
          in: body
          required: true
          schema:
            $ref: '#/definitions/User'
      responses:
        201:
          description: User created
          schema:
            $ref: '#/definitions/User'
        400:
          description: Bad request

  /users/{userId}:
    get:
      summary: Get user by ID
      operationId: getUserById
      security:
        - firebase_auth: []
      x-google-backend:
        address: https://us-central1-my-project.cloudfunctions.net/getUserById
      parameters:
        - name: userId
          in: path
          required: true
          type: string
      responses:
        200:
          description: User details
          schema:
            $ref: '#/definitions/User'
        404:
          description: User not found

definitions:
  User:
    type: object
    required:
      - name
      - email
    properties:
      id:
        type: string
      name:
        type: string
      email:
        type: string
        format: email
      createdAt:
        type: string
        format: date-time
```

### Cloud Functions with Endpoints
```python
# Google Cloud Function with authentication
import functions_framework
import json
from google.auth.transport import requests
from google.oauth2 import id_token

@functions_framework.http
def get_users(request):
    """
    Get users with Firebase authentication
    """
    
    try:
        # Verify Firebase ID token
        id_info = verify_firebase_token(request)
        
        if not id_info:
            return json.dumps({'error': 'Unauthorized'}), 401
        
        user_id = id_info['sub']
        user_role = id_info.get('role', 'user')
        
        # Apply role-based access control
        if user_role == 'admin':
            users = get_all_users()
        else:
            users = get_user_data(user_id)
        
        return json.dumps(users), 200, {'Content-Type': 'application/json'}
    
    except Exception as e:
        return json.dumps({'error': str(e)}), 500

def verify_firebase_token(request):
    """Verify Firebase ID token"""
    
    # Get token from Authorization header
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    
    token = auth_header.split('Bearer ')[1]
    
    try:
        # Verify the token
        id_info = id_token.verify_oauth2_token(
            token, 
            requests.Request(), 
            'YOUR_PROJECT_ID'
        )
        
        return id_info
    
    except ValueError:
        return None

@functions_framework.http
def create_user(request):
    """
    Create user with API key authentication
    """
    
    # Verify API key
    api_key = request.args.get('key')
    if not verify_api_key(api_key):
        return json.dumps({'error': 'Invalid API key'}), 401
    
    try:
        # Parse request body
        request_json = request.get_json()
        
        # Validate required fields
        if not request_json or 'name' not in request_json or 'email' not in request_json:
            return json.dumps({'error': 'Missing required fields'}), 400
        
        # Create user
        user = create_new_user(request_json)
        
        return json.dumps(user), 201, {'Content-Type': 'application/json'}
    
    except Exception as e:
        return json.dumps({'error': str(e)}), 500

def verify_api_key(api_key):
    """Verify API key"""
    # In production, verify against a secure store
    valid_keys = ['your-api-key-1', 'your-api-key-2']
    return api_key in valid_keys
```

## API Gateway Best Practices

### Request/Response Transformation
```python
# Request transformation middleware
def transform_request(event, context):
    """Transform incoming requests"""
    
    # Parse the request
    body = json.loads(event.get('body', '{}'))
    headers = event.get('headers', {})
    query_params = event.get('queryStringParameters', {})
    
    # Transform request format
    transformed_request = {
        'data': body,
        'metadata': {
            'timestamp': datetime.utcnow().isoformat(),
            'source': headers.get('User-Agent', 'unknown'),
            'requestId': context.aws_request_id
        },
        'filters': query_params
    }
    
    # Call downstream service
    result = process_transformed_request(transformed_request)
    
    # Transform response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'X-Request-ID': context.aws_request_id
        },
        'body': json.dumps({
            'data': result,
            'meta': {
                'timestamp': datetime.utcnow().isoformat(),
                'version': '1.0'
            }
        })
    }
    
    return response
```

### Error Handling and Validation
```python
# Comprehensive error handling
from jsonschema import validate, ValidationError

def api_handler(event, context):
    """API handler with comprehensive error handling"""
    
    try:
        # Validate request schema
        request_body = json.loads(event.get('body', '{}'))
        validate_request_schema(request_body)
        
        # Process request
        result = process_request(request_body)
        
        return create_success_response(result)
    
    except ValidationError as e:
        return create_error_response(400, 'VALIDATION_ERROR', str(e))
    
    except AuthenticationError as e:
        return create_error_response(401, 'AUTHENTICATION_ERROR', 'Invalid credentials')
    
    except AuthorizationError as e:
        return create_error_response(403, 'AUTHORIZATION_ERROR', 'Insufficient permissions')
    
    except NotFoundError as e:
        return create_error_response(404, 'NOT_FOUND', 'Resource not found')
    
    except RateLimitError as e:
        return create_error_response(429, 'RATE_LIMIT_EXCEEDED', 'Too many requests')
    
    except Exception as e:
        # Log unexpected errors
        print(f"Unexpected error: {str(e)}")
        return create_error_response(500, 'INTERNAL_ERROR', 'Internal server error')

def validate_request_schema(data):
    """Validate request against JSON schema"""
    schema = {
        "type": "object",
        "properties": {
            "name": {"type": "string", "minLength": 1},
            "email": {"type": "string", "format": "email"},
            "age": {"type": "integer", "minimum": 0}
        },
        "required": ["name", "email"]
    }
    
    validate(data, schema)

def create_success_response(data):
    """Create standardized success response"""
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': True,
            'data': data,
            'timestamp': datetime.utcnow().isoformat()
        })
    }

def create_error_response(status_code, error_code, message):
    """Create standardized error response"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': False,
            'error': {
                'code': error_code,
                'message': message,
                'timestamp': datetime.utcnow().isoformat()
            }
        })
    }
```

### Monitoring and Logging
```python
# API Gateway monitoring and logging
import boto3
import json
from datetime import datetime

def monitored_api_handler(event, context):
    """API handler with comprehensive monitoring"""
    
    # Initialize CloudWatch client
    cloudwatch = boto3.client('cloudwatch')
    
    start_time = datetime.utcnow()
    
    try:
        # Log request details
        log_request(event, context)
        
        # Process request
        result = process_request(event)
        
        # Log successful response
        log_response(result, context)
        
        # Send success metrics
        send_metric(cloudwatch, 'APISuccess', 1)
        
        return create_success_response(result)
    
    except Exception as e:
        # Log error
        log_error(e, event, context)
        
        # Send error metrics
        send_metric(cloudwatch, 'APIError', 1)
        
        return create_error_response(500, 'INTERNAL_ERROR', 'Internal server error')
    
    finally:
        # Calculate and log duration
        duration = (datetime.utcnow() - start_time).total_seconds() * 1000
        send_metric(cloudwatch, 'APILatency', duration, 'Milliseconds')

def log_request(event, context):
    """Log incoming request"""
    log_data = {
        'requestId': context.aws_request_id,
        'method': event.get('httpMethod'),
        'path': event.get('path'),
        'userAgent': event.get('headers', {}).get('User-Agent'),
        'sourceIP': event.get('requestContext', {}).get('identity', {}).get('sourceIp'),
        'timestamp': datetime.utcnow().isoformat()
    }
    
    print(f"REQUEST: {json.dumps(log_data)}")

def log_response(result, context):
    """Log response"""
    log_data = {
        'requestId': context.aws_request_id,
        'responseSize': len(json.dumps(result)),
        'timestamp': datetime.utcnow().isoformat()
    }
    
    print(f"RESPONSE: {json.dumps(log_data)}")

def log_error(error, event, context):
    """Log error details"""
    log_data = {
        'requestId': context.aws_request_id,
        'error': str(error),
        'method': event.get('httpMethod'),
        'path': event.get('path'),
        'timestamp': datetime.utcnow().isoformat()
    }
    
    print(f"ERROR: {json.dumps(log_data)}")

def send_metric(cloudwatch, metric_name, value, unit='Count'):
    """Send custom metric to CloudWatch"""
    try:
        cloudwatch.put_metric_data(
            Namespace='ServerlessAPI',
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit,
                    'Timestamp': datetime.utcnow()
                }
            ]
        )
    except Exception as e:
        print(f"Failed to send metric {metric_name}: {str(e)}")
```

This comprehensive API Gateway guide covers the essential aspects of implementing and managing API gateways in serverless architectures across major cloud providers.