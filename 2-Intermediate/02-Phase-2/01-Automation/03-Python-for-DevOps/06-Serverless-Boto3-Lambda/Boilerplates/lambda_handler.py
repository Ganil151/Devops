import json
import logging
import os

# Configure logging at the root level so Lambda picks it up
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Standard Lambda Entry Point.
    
    Args:
        event (dict): Data passed to the function (API GW, S3, etc).
        context (object): Runtime information (timeout, memory, ARN).
    """
    try:
        logger.info("Lambda started.")
        logger.info(f"Received Event: {json.dumps(event)}")
        
        # 1. Parse Input
        # Example: Input from API Gateway
        body = event.get('body', '{}')
        if isinstance(body, str):
            body = json.loads(body)
            
        action = body.get('action', 'noop')
        
        # 2. Business Logic
        if action == "status":
            result = {"status": "operational", "region": os.environ.get("AWS_REGION")}
        else:
            result = {"status": "unknown_action", "received": action}
            
        # 3. Return Response (API Gateway Format)
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(result)
        }
        
    except Exception as e:
        logger.error(f"Handler Failed: {e}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
