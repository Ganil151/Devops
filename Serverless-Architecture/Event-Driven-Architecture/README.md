# Event-Driven Architecture

## Overview
Event-driven architecture (EDA) is a software design pattern where components communicate through the production and consumption of events. In serverless computing, this pattern enables loose coupling, scalability, and real-time processing capabilities.

## Core Concepts

### Events
Events are immutable records of something that happened in the system:
```json
{
  "eventId": "12345",
  "eventType": "UserRegistered",
  "timestamp": "2024-01-15T10:30:00Z",
  "source": "user-service",
  "data": {
    "userId": "user-123",
    "email": "user@example.com",
    "registrationDate": "2024-01-15T10:30:00Z"
  },
  "metadata": {
    "version": "1.0",
    "correlationId": "corr-456"
  }
}
```

### Event Producers
Components that generate and publish events:
```python
# Event producer example
import json
import boto3
from datetime import datetime

class EventProducer:
    def __init__(self):
        self.eventbridge = boto3.client('events')
    
    def publish_event(self, event_type, source, data):
        event = {
            'Source': source,
            'DetailType': event_type,
            'Detail': json.dumps(data),
            'Time': datetime.utcnow()
        }
        
        response = self.eventbridge.put_events(
            Entries=[event]
        )
        
        return response

# Usage
producer = EventProducer()
producer.publish_event(
    event_type='UserRegistered',
    source='user-service',
    data={'userId': 'user-123', 'email': 'user@example.com'}
)
```

### Event Consumers
Components that subscribe to and process events:
```python
# Event consumer example
def user_registered_handler(event, context):
    """Handle UserRegistered events"""
    
    for record in event['Records']:
        # Parse the event
        event_data = json.loads(record['body'])
        user_data = json.loads(event_data['Detail'])
        
        # Process the event
        send_welcome_email(user_data['email'])
        create_user_profile(user_data['userId'])
        update_analytics(user_data)
        
        print(f"Processed UserRegistered event for user {user_data['userId']}")

def send_welcome_email(email):
    # Send welcome email logic
    pass

def create_user_profile(user_id):
    # Create user profile logic
    pass

def update_analytics(user_data):
    # Update analytics logic
    pass
```

## Event Patterns

### Pub/Sub Pattern
```python
# Publisher
import boto3

def publish_order_event(order_data):
    sns = boto3.client('sns')
    
    message = {
        'eventType': 'OrderPlaced',
        'orderId': order_data['orderId'],
        'customerId': order_data['customerId'],
        'amount': order_data['amount'],
        'timestamp': datetime.utcnow().isoformat()
    }
    
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:order-events',
        Message=json.dumps(message),
        MessageAttributes={
            'eventType': {
                'DataType': 'String',
                'StringValue': 'OrderPlaced'
            }
        }
    )

# Subscribers
def inventory_handler(event, context):
    """Update inventory when order is placed"""
    for record in event['Records']:
        message = json.loads(record['Sns']['Message'])
        update_inventory(message['orderId'])

def billing_handler(event, context):
    """Process billing when order is placed"""
    for record in event['Records']:
        message = json.loads(record['Sns']['Message'])
        process_payment(message['orderId'], message['amount'])

def notification_handler(event, context):
    """Send notifications when order is placed"""
    for record in event['Records']:
        message = json.loads(record['Sns']['Message'])
        send_order_confirmation(message['customerId'], message['orderId'])
```

### Event Sourcing Pattern
```python
# Event store implementation
class EventStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('event-store')
    
    def append_event(self, aggregate_id, event_type, event_data, expected_version=None):
        """Append event to the event store"""
        
        # Get current version
        current_version = self.get_current_version(aggregate_id)
        
        # Check optimistic concurrency
        if expected_version is not None and current_version != expected_version:
            raise ConcurrencyException(f"Expected version {expected_version}, got {current_version}")
        
        # Create event record
        event_record = {
            'aggregateId': aggregate_id,
            'version': current_version + 1,
            'eventType': event_type,
            'eventData': event_data,
            'timestamp': datetime.utcnow().isoformat(),
            'eventId': str(uuid.uuid4())
        }
        
        # Store event
        self.table.put_item(Item=event_record)
        
        # Publish event for projections
        self.publish_event(event_record)
        
        return event_record
    
    def get_events(self, aggregate_id, from_version=0):
        """Get events for an aggregate"""
        response = self.table.query(
            KeyConditionExpression=Key('aggregateId').eq(aggregate_id) & 
                                 Key('version').gte(from_version),
            ScanIndexForward=True
        )
        return response['Items']
    
    def get_current_version(self, aggregate_id):
        """Get current version of aggregate"""
        response = self.table.query(
            KeyConditionExpression=Key('aggregateId').eq(aggregate_id),
            ScanIndexForward=False,
            Limit=1
        )
        
        if response['Items']:
            return response['Items'][0]['version']
        return 0

# Aggregate example
class Order:
    def __init__(self, order_id):
        self.order_id = order_id
        self.status = 'pending'
        self.items = []
        self.total = 0
        self.version = 0
        self.uncommitted_events = []
    
    def add_item(self, item_id, quantity, price):
        """Add item to order"""
        event_data = {
            'itemId': item_id,
            'quantity': quantity,
            'price': price
        }
        
        self.apply_event('ItemAdded', event_data)
        self.uncommitted_events.append(('ItemAdded', event_data))
    
    def confirm_order(self):
        """Confirm the order"""
        if self.status != 'pending':
            raise InvalidOperationException("Order is not in pending status")
        
        event_data = {
            'orderId': self.order_id,
            'total': self.total,
            'confirmedAt': datetime.utcnow().isoformat()
        }
        
        self.apply_event('OrderConfirmed', event_data)
        self.uncommitted_events.append(('OrderConfirmed', event_data))
    
    def apply_event(self, event_type, event_data):
        """Apply event to aggregate state"""
        if event_type == 'ItemAdded':
            self.items.append({
                'itemId': event_data['itemId'],
                'quantity': event_data['quantity'],
                'price': event_data['price']
            })
            self.total += event_data['quantity'] * event_data['price']
        
        elif event_type == 'OrderConfirmed':
            self.status = 'confirmed'
        
        self.version += 1
    
    def save(self, event_store):
        """Save uncommitted events"""
        for event_type, event_data in self.uncommitted_events:
            event_store.append_event(
                self.order_id, 
                event_type, 
                event_data, 
                self.version - 1
            )
        
        self.uncommitted_events = []
    
    @classmethod
    def from_events(cls, order_id, events):
        """Rebuild aggregate from events"""
        order = cls(order_id)
        
        for event in events:
            order.apply_event(event['eventType'], event['eventData'])
        
        return order
```

### CQRS (Command Query Responsibility Segregation)
```python
# Command side
class OrderCommandHandler:
    def __init__(self, event_store):
        self.event_store = event_store
    
    def handle_create_order(self, command):
        """Handle CreateOrder command"""
        order = Order(command['orderId'])
        
        for item in command['items']:
            order.add_item(item['itemId'], item['quantity'], item['price'])
        
        order.save(self.event_store)
        
        return {'orderId': order.order_id, 'status': 'created'}
    
    def handle_confirm_order(self, command):
        """Handle ConfirmOrder command"""
        # Load aggregate from events
        events = self.event_store.get_events(command['orderId'])
        order = Order.from_events(command['orderId'], events)
        
        # Execute command
        order.confirm_order()
        order.save(self.event_store)
        
        return {'orderId': order.order_id, 'status': 'confirmed'}

# Query side - Read models
class OrderProjection:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('order-projections')
    
    def handle_item_added(self, event):
        """Update projection when item is added"""
        order_id = event['aggregateId']
        
        # Update or create order projection
        response = self.table.update_item(
            Key={'orderId': order_id},
            UpdateExpression='ADD itemCount :inc, totalAmount :amount',
            ExpressionAttributeValues={
                ':inc': 1,
                ':amount': event['eventData']['quantity'] * event['eventData']['price']
            },
            ReturnValues='ALL_NEW'
        )
    
    def handle_order_confirmed(self, event):
        """Update projection when order is confirmed"""
        order_id = event['aggregateId']
        
        self.table.update_item(
            Key={'orderId': order_id},
            UpdateExpression='SET orderStatus = :status, confirmedAt = :timestamp',
            ExpressionAttributeValues={
                ':status': 'confirmed',
                ':timestamp': event['eventData']['confirmedAt']
            }
        )
    
    def get_order_summary(self, order_id):
        """Get order summary from read model"""
        response = self.table.get_item(Key={'orderId': order_id})
        return response.get('Item')

# Event handler for projections
def projection_handler(event, context):
    """Handle events for read model projections"""
    projection = OrderProjection()
    
    for record in event['Records']:
        event_data = json.loads(record['body'])
        event_type = event_data['eventType']
        
        if event_type == 'ItemAdded':
            projection.handle_item_added(event_data)
        elif event_type == 'OrderConfirmed':
            projection.handle_order_confirmed(event_data)
```

## Messaging Patterns

### Message Queues
```python
# SQS message processing
def sqs_handler(event, context):
    """Process SQS messages"""
    
    for record in event['Records']:
        try:
            # Parse message
            message_body = json.loads(record['body'])
            
            # Process message
            result = process_message(message_body)
            
            # Message processed successfully
            print(f"Processed message: {record['messageId']}")
            
        except Exception as e:
            # Handle processing error
            print(f"Error processing message {record['messageId']}: {str(e)}")
            
            # Send to DLQ if needed
            send_to_dlq(record)
            raise e

def process_message(message):
    """Process individual message"""
    message_type = message.get('type')
    
    if message_type == 'user_registration':
        return process_user_registration(message['data'])
    elif message_type == 'order_placed':
        return process_order_placed(message['data'])
    else:
        raise ValueError(f"Unknown message type: {message_type}")

# Dead Letter Queue handler
def dlq_handler(event, context):
    """Handle messages from Dead Letter Queue"""
    
    for record in event['Records']:
        message = json.loads(record['body'])
        
        # Log failed message for investigation
        log_failed_message(message)
        
        # Attempt manual processing or alert operations team
        alert_operations_team(message)
```

### Event Streaming
```python
# Kinesis stream processing
def kinesis_handler(event, context):
    """Process Kinesis stream records"""
    
    processed_records = []
    
    for record in event['Records']:
        try:
            # Decode record data
            payload = base64.b64decode(record['kinesis']['data'])
            data = json.loads(payload)
            
            # Process the record
            result = process_stream_record(data)
            
            processed_records.append({
                'recordId': record['recordId'],
                'result': 'Ok'
            })
            
        except Exception as e:
            print(f"Error processing record {record['recordId']}: {str(e)}")
            
            processed_records.append({
                'recordId': record['recordId'],
                'result': 'ProcessingFailed'
            })
    
    return {'records': processed_records}

def process_stream_record(data):
    """Process individual stream record"""
    
    # Real-time analytics
    update_real_time_metrics(data)
    
    # Store in data lake
    store_in_data_lake(data)
    
    # Trigger downstream processing
    if should_trigger_downstream(data):
        trigger_downstream_processing(data)
    
    return {'status': 'processed'}

# Kinesis Analytics
def kinesis_analytics_handler(event, context):
    """Process Kinesis Analytics output"""
    
    for record in event['records']:
        # Decode analytics result
        payload = base64.b64decode(record['data'])
        analytics_result = json.loads(payload)
        
        # Process analytics result
        if analytics_result['anomaly_score'] > 0.8:
            trigger_alert(analytics_result)
        
        # Store aggregated data
        store_analytics_result(analytics_result)
```

## Event Choreography vs Orchestration

### Choreography Pattern
```python
# Decentralized event choreography
def order_placed_handler(event, context):
    """Handle OrderPlaced event - choreography style"""
    
    order_data = json.loads(event['Records'][0]['body'])
    
    # Each service handles its own responsibility
    # No central coordinator
    
    # Inventory service publishes InventoryReserved
    reserve_inventory(order_data)
    
    # Payment service publishes PaymentProcessed
    process_payment(order_data)
    
    # Shipping service publishes ShippingScheduled
    schedule_shipping(order_data)

def inventory_reserved_handler(event, context):
    """Handle InventoryReserved event"""
    
    inventory_data = json.loads(event['Records'][0]['body'])
    
    if inventory_data['status'] == 'reserved':
        # Continue with next step
        publish_event('InventoryConfirmed', inventory_data)
    else:
        # Handle inventory shortage
        publish_event('InventoryShortage', inventory_data)

def payment_processed_handler(event, context):
    """Handle PaymentProcessed event"""
    
    payment_data = json.loads(event['Records'][0]['body'])
    
    if payment_data['status'] == 'success':
        publish_event('PaymentConfirmed', payment_data)
    else:
        publish_event('PaymentFailed', payment_data)
        # Trigger compensation
        compensate_inventory(payment_data['orderId'])
```

### Orchestration Pattern
```python
# Centralized orchestration with Step Functions
import boto3

def order_orchestrator(event, context):
    """Central orchestrator for order processing"""
    
    stepfunctions = boto3.client('stepfunctions')
    
    # Start Step Functions workflow
    response = stepfunctions.start_execution(
        stateMachineArn='arn:aws:states:us-east-1:123456789012:stateMachine:OrderProcessing',
        input=json.dumps(event)
    )
    
    return {
        'executionArn': response['executionArn'],
        'status': 'started'
    }

# Step Functions state machine definition
step_functions_definition = {
    "Comment": "Order processing workflow",
    "StartAt": "ReserveInventory",
    "States": {
        "ReserveInventory": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ReserveInventory",
            "Next": "ProcessPayment",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "HandleInventoryFailure"
            }]
        },
        "ProcessPayment": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ProcessPayment",
            "Next": "ScheduleShipping",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "CompensateInventory"
            }]
        },
        "ScheduleShipping": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ScheduleShipping",
            "Next": "OrderCompleted",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "CompensatePayment"
            }]
        },
        "OrderCompleted": {
            "Type": "Succeed"
        },
        "HandleInventoryFailure": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:HandleInventoryFailure",
            "End": true
        },
        "CompensateInventory": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:CompensateInventory",
            "Next": "OrderFailed"
        },
        "CompensatePayment": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:CompensatePayment",
            "Next": "CompensateInventory"
        },
        "OrderFailed": {
            "Type": "Fail",
            "Cause": "Order processing failed"
        }
    }
}
```

## Best Practices

### Event Design
- **Immutable Events**: Events should never be modified
- **Self-Contained**: Include all necessary data in the event
- **Versioned**: Support event schema evolution
- **Timestamped**: Include event creation timestamp
- **Idempotent**: Handle duplicate events gracefully

### Error Handling
- **Retry Logic**: Implement exponential backoff
- **Dead Letter Queues**: Handle failed messages
- **Circuit Breakers**: Prevent cascade failures
- **Compensation**: Implement saga patterns for distributed transactions

### Performance
- **Batch Processing**: Process multiple events together
- **Parallel Processing**: Use concurrent processing where possible
- **Caching**: Cache frequently accessed data
- **Connection Pooling**: Reuse database connections

This comprehensive guide covers the essential patterns and practices for implementing event-driven architecture in serverless environments.