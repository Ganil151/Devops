"""
Example usage of the Resilient HTTP Client

Demonstrates various features:
- Basic GET/POST requests
- Custom headers
- Error handling
- Metrics tracking
- Circuit breaker behavior
"""

import time
import logging
from resilient_client import ResilientClient, CircuitBreakerError, MaxRetriesExceeded

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def example_1_basic_get():
    """Example 1: Simple GET request"""
    print("\n=== Example 1: Basic GET Request ===")
    
    client = ResilientClient(
        base_url='http://localhost:8080',
        max_retries=3,
        timeout=5.0
    )
    
    try:
        response = client.get('/api/health')
        print(f"Response: {response.json()}")
    except Exception as e:
        logger.error(f"Request failed: {e}")


def example_2_post_with_json():
    """Example 2: POST request with JSON payload"""
    print("\n=== Example 2: POST Request ===")
    
    client = ResilientClient(base_url='http://localhost:8080')
    
    order_data = {
        'product_id': 'ABC123',
        'quantity': 5,
        'user_id': 'user-456'
    }
    
    try:
        response = client.post('/api/orders', json=order_data)
        print(f"Response: {response.json()}")
    except Exception as e:
        logger.error(f"Request failed: {e}")


def example_3_custom_headers():
    """Example 3: Request with custom headers"""
    print("\n=== Example 3: Request with Custom Headers ===")
    
    client = ResilientClient(base_url='http://localhost:8080')
    
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'X-Request-ID': 'req-789',
        'X-Tenant-ID': 'tenant-001'
    }
    
    payment_data = {
        'amount': 99.99,
        'currency': 'USD'
    }
    
    try:
        response = client.post('/api/payments', json=payment_data, headers=headers)
        print(f"Response: {response.json()}")
    except Exception as e:
        logger.error(f"Request failed: {e}")


def example_4_error_handling():
    """Example 4: Error handling with fallback"""
    print("\n=== Example 4: Error Handling ===")
    
    client = ResilientClient(
        base_url='http://localhost:8080',
        circuit_breaker=True,
        cb_fail_max=3
    )
    
    def get_user_data(user_id: str):
        """Get user data with fallback"""
        try:
            response = client.get(f'/api/users/{user_id}')
            return response.json()
        except CircuitBreakerError:
            logger.warning("Circuit breaker is open, using cached data")
            return {'user_id': user_id, 'name': 'Cached User', 'cached': True}
        except MaxRetriesExceeded:
            logger.error("Service unavailable after retries")
            return None
    
    # Try to get user data
    user = get_user_data('user-123')
    print(f"User data: {user}")


def example_5_metrics_tracking():
    """Example 5: Metrics tracking"""
    print("\n=== Example 5: Metrics Tracking ===")
    
    client = ResilientClient(base_url='http://localhost:8080')
    
    # Make several requests
    endpoints = ['/api/health', '/api/users', '/api/products', '/api/orders']
    
    for endpoint in endpoints:
        try:
            client.get(endpoint)
        except Exception as e:
            logger.error(f"Request to {endpoint} failed: {e}")
    
    # Display metrics
    metrics = client.get_metrics()
    print(f"\nClient Metrics:")
    print(f"  Total Requests:      {metrics['total_requests']}")
    print(f"  Successful Requests: {metrics['successful_requests']}")
    print(f"  Failed Requests:     {metrics['failed_requests']}")
    print(f"  Circuit Open Count:  {metrics['circuit_open_count']}")
    print(f"  Retry Count:         {metrics['retry_count']}")
    print(f"  Success Rate:        {metrics['success_rate']:.2f}%")
    print(f"  Avg Duration:        {metrics['avg_duration_ms']:.2f}ms")


def example_6_circuit_breaker_behavior():
    """Example 6: Demonstrating circuit breaker behavior"""
    print("\n=== Example 6: Circuit Breaker Behavior ===")
    
    client = ResilientClient(
        base_url='http://localhost:8080',
        circuit_breaker=True,
        cb_fail_max=5,
        cb_reset_timeout=10,
        max_retries=1  # Fail fast for this demo
    )
    
    print("Sending requests to a failing endpoint...")
    
    for i in range(15):
        try:
            response = client.get('/api/failing-endpoint')
            print(f"Request {i+1}: Success")
        except CircuitBreakerError:
            print(f"Request {i+1}: Circuit breaker is OPEN (failing fast)")
        except Exception as e:
            print(f"Request {i+1}: Failed - {type(e).__name__}")
        
        time.sleep(0.2)
    
    # Display final metrics
    print("\n=== Final Metrics ===")
    metrics = client.get_metrics()
    print(f"Total Requests:      {metrics['total_requests']}")
    print(f"Successful Requests: {metrics['successful_requests']}")
    print(f"Failed Requests:     {metrics['failed_requests']}")
    print(f"Circuit Open Count:  {metrics['circuit_open_count']}")


def example_7_context_manager():
    """Example 7: Using client as context manager"""
    print("\n=== Example 7: Context Manager ===")
    
    with ResilientClient(base_url='http://localhost:8080') as client:
        try:
            response = client.get('/api/health')
            print(f"Health check: {response.json()}")
        except Exception as e:
            logger.error(f"Request failed: {e}")
    
    print("Session automatically closed")


def example_8_real_world_scenario():
    """Example 8: Real-world scenario - Order processing"""
    print("\n=== Example 8: Real-World Order Processing ===")
    
    inventory_client = ResilientClient(
        base_url='http://inventory-service:8080',
        max_retries=3,
        timeout=2.0,
        circuit_breaker=True
    )
    
    payment_client = ResilientClient(
        base_url='http://payment-service:8080',
        max_retries=5,  # More retries for critical payment
        timeout=10.0,
        circuit_breaker=True
    )
    
    def process_order(order_id: str, items: list):
        """Process an order with multiple service calls"""
        print(f"\nProcessing order: {order_id}")
        
        # Step 1: Reserve inventory
        try:
            inventory_response = inventory_client.post(
                '/api/reserve',
                json={'order_id': order_id, 'items': items}
            )
            print(f"✓ Inventory reserved: {inventory_response.json()}")
        except Exception as e:
            logger.error(f"✗ Inventory reservation failed: {e}")
            return False
        
        # Step 2: Process payment
        try:
            payment_response = payment_client.post(
                '/api/charge',
                json={'order_id': order_id, 'amount': 99.99}
            )
            print(f"✓ Payment processed: {payment_response.json()}")
        except Exception as e:
            logger.error(f"✗ Payment failed: {e}")
            
            # Compensate: Release inventory
            print("↺ Rolling back inventory reservation...")
            try:
                inventory_client.post(
                    '/api/release',
                    json={'order_id': order_id}
                )
                print("✓ Inventory released (compensated)")
            except Exception as rollback_error:
                logger.error(f"✗ Rollback failed: {rollback_error}")
            
            return False
        
        print(f"✓ Order {order_id} processed successfully")
        return True
    
    # Process sample order
    order_items = [
        {'product_id': 'ABC123', 'quantity': 2},
        {'product_id': 'XYZ789', 'quantity': 1}
    ]
    
    success = process_order('ORD-2026-001', order_items)
    print(f"\nOrder processing result: {'SUCCESS' if success else 'FAILED'}")


if __name__ == '__main__':
    print("=" * 80)
    print("Resilient HTTP Client - Examples")
    print("=" * 80)
    
    # Run examples
    # Note: These examples assume a local server running on localhost:8080
    # You can use a mock server or comment out examples as needed
    
    example_1_basic_get()
    example_2_post_with_json()
    example_3_custom_headers()
    example_4_error_handling()
    example_5_metrics_tracking()
    example_6_circuit_breaker_behavior()
    example_7_context_manager()
    example_8_real_world_scenario()
    
    print("\n" + "=" * 80)
    print("Examples completed!")
    print("=" * 80)
