# Serverless Security Best Practices

## Overview

Serverless security requires a comprehensive approach covering function-level security, data protection, access control, and infrastructure security across the entire serverless stack.

## Security Principles

### 1. Principle of Least Privilege
- Grant minimal necessary permissions
- Use function-specific IAM roles
- Implement time-bound access tokens
- Regular permission audits

### 2. Defense in Depth
- Multiple security layers
- Input validation at all levels
- Network segmentation
- Encryption at rest and in transit

### 3. Zero Trust Architecture
- Verify every request
- Authenticate and authorize all access
- Monitor all activities
- Assume breach mentality

## Identity and Access Management (IAM)

### Function-Specific IAM Roles
```yaml
# serverless.yml with least privilege IAM
service: secure-serverless-app

provider:
  name: aws
  runtime: nodejs18.x
  
functions:
  readUser:
    handler: handlers/users.read
    role: ReadUserRole
    events:
      - http:
          path: /users/{id}
          method: get
  
  writeUser:
    handler: handlers/users.write
    role: WriteUserRole
    events:
      - http:
          path: /users
          method: post

resources:
  Resources:
    ReadUserRole:
      Type: AWS::IAM::Role
      Properties:
        AssumeRolePolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Principal:
                Service: lambda.amazonaws.com
              Action: sts:AssumeRole
        ManagedPolicyArns:
          - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        Policies:
          - PolicyName: ReadUserPolicy
            PolicyDocument:
              Version: '2012-10-17'
              Statement:
                - Effect: Allow
                  Action:
                    - dynamodb:GetItem
                    - dynamodb:Query
                  Resource: 
                    - !GetAtt UsersTable.Arn
                    - !Sub "${UsersTable.Arn}/index/*"

    WriteUserRole:
      Type: AWS::IAM::Role
      Properties:
        AssumeRolePolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Principal:
                Service: lambda.amazonaws.com
              Action: sts:AssumeRole
        ManagedPolicyArns:
          - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        Policies:
          - PolicyName: WriteUserPolicy
            PolicyDocument:
              Version: '2012-10-17'
              Statement:
                - Effect: Allow
                  Action:
                    - dynamodb:PutItem
                    - dynamodb:UpdateItem
                  Resource: !GetAtt UsersTable.Arn
```

### Resource-Based Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificAccountAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:my-function",
      "Condition": {
        "StringEquals": {
          "lambda:FunctionArn": "arn:aws:lambda:us-east-1:123456789012:function:my-function"
        }
      }
    }
  ]
}
```

## Authentication and Authorization

### JWT Token Validation
```javascript
// JWT authorizer with proper validation
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: process.env.JWKS_URI,
  cache: true,
  cacheMaxEntries: 5,
  cacheMaxAge: 600000 // 10 minutes
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    if (err) {
      callback(err);
      return;
    }
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

exports.authorize = async (event) => {
  try {
    const token = extractToken(event.authorizationToken);
    
    if (!token) {
      throw new Error('No token provided');
    }
    
    // Verify token
    const decoded = await new Promise((resolve, reject) => {
      jwt.verify(token, getKey, {
        audience: process.env.JWT_AUDIENCE,
        issuer: process.env.JWT_ISSUER,
        algorithms: ['RS256']
      }, (err, decoded) => {
        if (err) reject(err);
        else resolve(decoded);
      });
    });
    
    // Additional validation
    if (!decoded.sub || !decoded.email) {
      throw new Error('Invalid token payload');
    }
    
    // Check token expiration with buffer
    const now = Math.floor(Date.now() / 1000);
    if (decoded.exp - now < 60) { // 1 minute buffer
      throw new Error('Token expires too soon');
    }
    
    return generatePolicy('Allow', event.methodArn, {
      userId: decoded.sub,
      email: decoded.email,
      roles: JSON.stringify(decoded.roles || [])
    });
    
  } catch (error) {
    console.error('Authorization failed:', error.message);
    throw new Error('Unauthorized');
  }
};

function extractToken(authorizationToken) {
  if (!authorizationToken) return null;
  
  const parts = authorizationToken.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return null;
  }
  
  return parts[1];
}

function generatePolicy(effect, resource, context = {}) {
  return {
    principalId: context.userId || 'unknown',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [{
        Action: 'execute-api:Invoke',
        Effect: effect,
        Resource: resource
      }]
    },
    context: context
  };
}
```

### API Key Authentication
```python
import hashlib
import hmac
import time
import base64
import json

def authenticate_api_request(event, context):
    """
    Validates API requests using HMAC signature
    """
    try:
        # Extract headers
        headers = event.get('headers', {})
        api_key = headers.get('X-API-Key')
        signature = headers.get('X-Signature')
        timestamp = headers.get('X-Timestamp')
        
        if not all([api_key, signature, timestamp]):
            return generate_policy('Deny')
        
        # Validate timestamp (prevent replay attacks)
        current_time = int(time.time())
        request_time = int(timestamp)
        
        if abs(current_time - request_time) > 300:  # 5 minutes window
            return generate_policy('Deny')
        
        # Get API secret from secure storage
        secret = get_api_secret(api_key)
        if not secret:
            return generate_policy('Deny')
        
        # Verify signature
        expected_signature = generate_signature(
            event.get('body', ''),
            secret,
            timestamp
        )
        
        if not hmac.compare_digest(signature, expected_signature):
            return generate_policy('Deny')
        
        return generate_policy('Allow')
        
    except Exception as e:
        print(f"Authentication error: {e}")
        return generate_policy('Deny')

def generate_signature(body, secret, timestamp):
    """
    Generate HMAC signature for request validation
    """
    message = f"{body}{timestamp}"
    signature = hmac.new(
        secret.encode('utf-8'),
        message.encode('utf-8'),
        hashlib.sha256
    ).digest()
    return base64.b64encode(signature).decode('utf-8')

def get_api_secret(api_key):
    """
    Retrieve API secret from AWS Systems Manager Parameter Store
    """
    import boto3
    
    ssm = boto3.client('ssm')
    
    try:
        response = ssm.get_parameter(
            Name=f'/api-keys/{api_key}',
            WithDecryption=True
        )
        return response['Parameter']['Value']
    except Exception:
        return None

def generate_policy(effect):
    return {
        'principalId': 'api-client',
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': '*'
            }]
        }
    }
```

## Input Validation and Sanitization

### Comprehensive Input Validation
```javascript
// Input validation middleware
const Joi = require('joi');
const DOMPurify = require('isomorphic-dompurify');

const schemas = {
  createUser: Joi.object({
    email: Joi.string().email().required().max(255),
    name: Joi.string().required().min(2).max(100).pattern(/^[a-zA-Z\s]+$/),
    age: Joi.number().integer().min(18).max(120),
    phone: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/),
    address: Joi.object({
      street: Joi.string().required().max(200),
      city: Joi.string().required().max(100),
      zipCode: Joi.string().required().pattern(/^\d{5}(-\d{4})?$/)
    })
  }),
  
  updateUser: Joi.object({
    name: Joi.string().min(2).max(100).pattern(/^[a-zA-Z\s]+$/),
    age: Joi.number().integer().min(18).max(120),
    phone: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/)
  })
};

function validateInput(schema, data) {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
    convert: true
  });
  
  if (error) {
    const details = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    }));
    
    throw new ValidationError('Input validation failed', details);
  }
  
  return value;
}

function sanitizeInput(data) {
  if (typeof data === 'string') {
    // Remove potential XSS
    return DOMPurify.sanitize(data);
  }
  
  if (Array.isArray(data)) {
    return data.map(sanitizeInput);
  }
  
  if (typeof data === 'object' && data !== null) {
    const sanitized = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeInput(value);
    }
    return sanitized;
  }
  
  return data;
}

exports.createUser = async (event) => {
  try {
    // Parse and validate input
    const rawData = JSON.parse(event.body);
    const validatedData = validateInput(schemas.createUser, rawData);
    const sanitizedData = sanitizeInput(validatedData);
    
    // Process the request
    const user = await createUserInDatabase(sanitizedData);
    
    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block'
      },
      body: JSON.stringify({
        id: user.id,
        email: user.email,
        name: user.name
      })
    };
    
  } catch (error) {
    if (error instanceof ValidationError) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: 'Validation failed',
          details: error.details
        })
      };
    }
    
    console.error('Error creating user:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};

class ValidationError extends Error {
  constructor(message, details) {
    super(message);
    this.name = 'ValidationError';
    this.details = details;
  }
}
```

### SQL Injection Prevention
```python
import boto3
from boto3.dynamodb.conditions import Key, Attr
import re

def secure_database_query(event, context):
    """
    Secure database operations with parameterized queries
    """
    try:
        # Input validation
        user_id = event.get('pathParameters', {}).get('id')
        if not user_id or not re.match(r'^[a-zA-Z0-9-]+$', user_id):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid user ID format'})
            }
        
        # Use parameterized DynamoDB query
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('users')
        
        response = table.get_item(
            Key={'userId': user_id}
        )
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'User not found'})
            }
        
        # Sanitize output
        user_data = sanitize_output(response['Item'])
        
        return {
            'statusCode': 200,
            'body': json.dumps(user_data)
        }
        
    except Exception as e:
        print(f"Database query error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }

def sanitize_output(data):
    """
    Remove sensitive fields from output
    """
    sensitive_fields = ['password', 'ssn', 'credit_card']
    
    if isinstance(data, dict):
        return {k: sanitize_output(v) for k, v in data.items() 
                if k not in sensitive_fields}
    elif isinstance(data, list):
        return [sanitize_output(item) for item in data]
    else:
        return data
```

## Secrets Management

### AWS Secrets Manager Integration
```javascript
// Secure secrets management
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

class SecretsManager {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 5 * 60 * 1000; // 5 minutes
  }
  
  async getSecret(secretName) {
    const cacheKey = secretName;
    const cached = this.cache.get(cacheKey);
    
    // Check cache first
    if (cached && (Date.now() - cached.timestamp) < this.cacheTimeout) {
      return cached.value;
    }
    
    try {
      const result = await secretsManager.getSecretValue({
        SecretId: secretName,
        VersionStage: 'AWSCURRENT'
      }).promise();
      
      let secret;
      if (result.SecretString) {
        secret = JSON.parse(result.SecretString);
      } else {
        secret = Buffer.from(result.SecretBinary, 'base64').toString('ascii');
      }
      
      // Cache the secret
      this.cache.set(cacheKey, {
        value: secret,
        timestamp: Date.now()
      });
      
      return secret;
      
    } catch (error) {
      console.error(`Failed to retrieve secret ${secretName}:`, error);
      throw new Error('Failed to retrieve secret');
    }
  }
  
  clearCache() {
    this.cache.clear();
  }
}

const secrets = new SecretsManager();

exports.handler = async (event) => {
  try {
    // Retrieve database credentials
    const dbCredentials = await secrets.getSecret('prod/database/credentials');
    
    // Retrieve API keys
    const apiKeys = await secrets.getSecret('prod/external-apis/keys');
    
    // Use secrets securely
    const result = await processWithSecrets(dbCredentials, apiKeys);
    
    return {
      statusCode: 200,
      body: JSON.stringify(result)
    };
    
  } catch (error) {
    console.error('Error processing request:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};

// Clear cache on container reuse
process.on('SIGTERM', () => {
  secrets.clearCache();
});
```

### Environment Variable Security
```yaml
# serverless.yml with encrypted environment variables
provider:
  environment:
    # Non-sensitive configuration
    LOG_LEVEL: INFO
    REGION: ${opt:region, 'us-east-1'}
    
    # Encrypted sensitive data
    DB_PASSWORD: ${ssm:/myapp/${opt:stage}/db/password~true}
    API_KEY: ${ssm:/myapp/${opt:stage}/external-api/key~true}
    JWT_SECRET: ${ssm:/myapp/${opt:stage}/jwt/secret~true}
  
  # KMS key for encryption
  kmsKeyArn: arn:aws:kms:${opt:region}:${aws:accountId}:key/your-kms-key-id
```

## Data Protection

### Encryption at Rest
```python
import boto3
import json
from cryptography.fernet import Fernet
import base64

class DataEncryption:
    def __init__(self):
        self.kms = boto3.client('kms')
        self.key_id = os.environ['KMS_KEY_ID']
    
    def encrypt_sensitive_data(self, data):
        """
        Encrypt sensitive data using AWS KMS
        """
        try:
            # Generate data key
            response = self.kms.generate_data_key(
                KeyId=self.key_id,
                KeySpec='AES_256'
            )
            
            # Use plaintext key for encryption
            plaintext_key = response['Plaintext']
            encrypted_key = response['CiphertextBlob']
            
            # Encrypt data
            fernet = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
            encrypted_data = fernet.encrypt(json.dumps(data).encode())
            
            return {
                'encrypted_data': base64.b64encode(encrypted_data).decode(),
                'encrypted_key': base64.b64encode(encrypted_key).decode()
            }
            
        except Exception as e:
            print(f"Encryption error: {e}")
            raise
    
    def decrypt_sensitive_data(self, encrypted_package):
        """
        Decrypt sensitive data using AWS KMS
        """
        try:
            # Decrypt the data key
            encrypted_key = base64.b64decode(encrypted_package['encrypted_key'])
            response = self.kms.decrypt(CiphertextBlob=encrypted_key)
            plaintext_key = response['Plaintext']
            
            # Decrypt data
            fernet = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
            encrypted_data = base64.b64decode(encrypted_package['encrypted_data'])
            decrypted_data = fernet.decrypt(encrypted_data)
            
            return json.loads(decrypted_data.decode())
            
        except Exception as e:
            print(f"Decryption error: {e}")
            raise

# Usage
encryption = DataEncryption()

def lambda_handler(event, context):
    sensitive_data = {
        'ssn': '123-45-6789',
        'credit_card': '4111-1111-1111-1111'
    }
    
    # Encrypt before storing
    encrypted_package = encryption.encrypt_sensitive_data(sensitive_data)
    
    # Store encrypted data
    store_in_database(encrypted_package)
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Data stored securely'})
    }
```

### Encryption in Transit
```javascript
// HTTPS enforcement and certificate pinning
const https = require('https');
const crypto = require('crypto');

const EXPECTED_CERT_FINGERPRINT = process.env.CERT_FINGERPRINT;

function makeSecureRequest(hostname, path, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: hostname,
      port: 443,
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'User-Agent': 'MyApp/1.0'
      },
      // Certificate validation
      checkServerIdentity: (host, cert) => {
        const fingerprint = crypto
          .createHash('sha256')
          .update(cert.raw)
          .digest('hex');
        
        if (fingerprint !== EXPECTED_CERT_FINGERPRINT) {
          throw new Error('Certificate fingerprint mismatch');
        }
      }
    };
    
    const req = https.request(options, (res) => {
      // Validate response headers
      if (!res.headers['strict-transport-security']) {
        console.warn('Missing HSTS header');
      }
      
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          resolve(response);
        } catch (error) {
          reject(new Error('Invalid JSON response'));
        }
      });
    });
    
    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}
```

## Network Security

### VPC Configuration
```yaml
# serverless.yml with VPC configuration
provider:
  vpc:
    securityGroupIds:
      - sg-12345678  # Lambda security group
    subnetIds:
      - subnet-12345678  # Private subnet 1
      - subnet-87654321  # Private subnet 2

resources:
  Resources:
    LambdaSecurityGroup:
      Type: AWS::EC2::SecurityGroup
      Properties:
        GroupDescription: Security group for Lambda functions
        VpcId: vpc-12345678
        SecurityGroupEgress:
          # Allow HTTPS outbound only
          - IpProtocol: tcp
            FromPort: 443
            ToPort: 443
            CidrIp: 0.0.0.0/0
          # Allow database access
          - IpProtocol: tcp
            FromPort: 5432
            ToPort: 5432
            SourceSecurityGroupId: !Ref DatabaseSecurityGroup
        Tags:
          - Key: Name
            Value: lambda-security-group

    DatabaseSecurityGroup:
      Type: AWS::EC2::SecurityGroup
      Properties:
        GroupDescription: Security group for RDS database
        VpcId: vpc-12345678
        SecurityGroupIngress:
          # Allow access from Lambda only
          - IpProtocol: tcp
            FromPort: 5432
            ToPort: 5432
            SourceSecurityGroupId: !Ref LambdaSecurityGroup
```

### API Gateway Security
```yaml
# API Gateway with security configurations
resources:
  Resources:
    ApiGatewayRestApi:
      Type: AWS::ApiGateway::RestApi
      Properties:
        Name: secure-api
        Policy:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Principal: '*'
              Action: execute-api:Invoke
              Resource: '*'
              Condition:
                IpAddress:
                  aws:SourceIp:
                    - 203.0.113.0/24  # Allowed IP range
        EndpointConfiguration:
          Types:
            - REGIONAL
    
    # WAF for API Gateway
    WebACL:
      Type: AWS::WAFv2::WebACL
      Properties:
        Name: api-protection
        Scope: REGIONAL
        DefaultAction:
          Allow: {}
        Rules:
          - Name: RateLimitRule
            Priority: 1
            Statement:
              RateBasedStatement:
                Limit: 1000
                AggregateKeyType: IP
            Action:
              Block: {}
          - Name: SQLInjectionRule
            Priority: 2
            Statement:
              SqliMatchStatement:
                FieldToMatch:
                  Body: {}
                TextTransformations:
                  - Priority: 0
                    Type: URL_DECODE
            Action:
              Block: {}
```

## Security Monitoring and Incident Response

### Security Event Logging
```python
import json
import boto3
from datetime import datetime

class SecurityLogger:
    def __init__(self):
        self.cloudwatch = boto3.client('logs')
        self.log_group = '/aws/lambda/security-events'
    
    def log_security_event(self, event_type, details, severity='INFO'):
        """
        Log security events for monitoring and alerting
        """
        log_entry = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'event_type': event_type,
            'severity': severity,
            'source': 'lambda-function',
            'details': details,
            'aws_request_id': details.get('aws_request_id'),
            'source_ip': details.get('source_ip'),
            'user_agent': details.get('user_agent')
        }
        
        try:
            self.cloudwatch.put_log_events(
                logGroupName=self.log_group,
                logStreamName=f"security-{datetime.now().strftime('%Y-%m-%d')}",
                logEvents=[{
                    'timestamp': int(datetime.now().timestamp() * 1000),
                    'message': json.dumps(log_entry)
                }]
            )
        except Exception as e:
            print(f"Failed to log security event: {e}")

security_logger = SecurityLogger()

def lambda_handler(event, context):
    try:
        # Extract request details
        source_ip = event.get('requestContext', {}).get('identity', {}).get('sourceIp')
        user_agent = event.get('headers', {}).get('User-Agent')
        
        # Validate authentication
        auth_result = validate_authentication(event)
        
        if not auth_result['valid']:
            # Log failed authentication
            security_logger.log_security_event(
                'AUTHENTICATION_FAILED',
                {
                    'aws_request_id': context.aws_request_id,
                    'source_ip': source_ip,
                    'user_agent': user_agent,
                    'reason': auth_result['reason']
                },
                'WARNING'
            )
            
            return {
                'statusCode': 401,
                'body': json.dumps({'error': 'Unauthorized'})
            }
        
        # Log successful authentication
        security_logger.log_security_event(
            'AUTHENTICATION_SUCCESS',
            {
                'aws_request_id': context.aws_request_id,
                'source_ip': source_ip,
                'user_id': auth_result['user_id']
            }
        )
        
        # Process request
        result = process_request(event, auth_result['user_id'])
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
        
    except Exception as e:
        # Log security exception
        security_logger.log_security_event(
            'SECURITY_EXCEPTION',
            {
                'aws_request_id': context.aws_request_id,
                'error': str(e),
                'source_ip': source_ip
            },
            'ERROR'
        )
        raise
```

### Automated Incident Response
```yaml
# CloudWatch alarm for security events
Resources:
  SecurityAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: security-events-high
      AlarmDescription: High number of security events detected
      MetricName: SecurityEvents
      Namespace: Custom/Security
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 2
      Threshold: 10
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref SecurityResponseTopic

  SecurityResponseTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: security-incident-response
      Subscription:
        - Protocol: lambda
          Endpoint: !GetAtt IncidentResponseFunction.Arn
        - Protocol: email
          Endpoint: security-team@company.com

  IncidentResponseFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: security-incident-response
      Runtime: python3.9
      Handler: index.handler
      Code:
        ZipFile: |
          import json
          import boto3
          
          def handler(event, context):
              # Parse alarm
              message = json.loads(event['Records'][0]['Sns']['Message'])
              
              # Automated response actions
              if message['NewStateValue'] == 'ALARM':
                  # Block suspicious IPs
                  block_suspicious_ips()
                  
                  # Rotate API keys
                  rotate_compromised_keys()
                  
                  # Send detailed alert
                  send_security_alert(message)
              
              return {'statusCode': 200}
```

## Best Practices Summary

### 1. Function Security
- Use least privilege IAM roles
- Implement proper input validation
- Sanitize all outputs
- Handle errors securely

### 2. Data Protection
- Encrypt sensitive data at rest and in transit
- Use AWS KMS for key management
- Implement proper secrets management
- Regular key rotation

### 3. Network Security
- Use VPC for network isolation
- Implement proper security groups
- Enable WAF for API protection
- Monitor network traffic

### 4. Monitoring and Response
- Log all security events
- Implement real-time alerting
- Automated incident response
- Regular security audits

### 5. Compliance
- Follow industry standards (SOC 2, PCI DSS)
- Implement audit trails
- Data retention policies
- Regular penetration testing