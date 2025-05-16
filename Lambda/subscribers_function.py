import json
import boto3
import re

sns = boto3.client('sns')
TOPIC_ARN = "PUT YOUR SNS TOPIC HERE"

def lambda_handler(event, context):
    try:
        # Parse the incoming event
        if isinstance(event, dict):
            # Handle both direct invocation and API Gateway formats
            if 'body' in event:
                if event['body'] is None:
                    return {
                        "statusCode": 400,
                        "body": json.dumps({"error": "Request body is empty"})
                    }
                try:
                    body = json.loads(event['body'])
                except json.JSONDecodeError:
                    return {
                        "statusCode": 400,
                        "body": json.dumps({"error": "Invalid JSON format"})
                    }
            else:
                body = event
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Invalid request format"})
            }

        # Validate email exists
        if 'email' not in body or not body['email']:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Email is required"})
            }

        email = body['email']
        
        # Basic email validation
        if not re.match(r'^[^@]+@[^@]+\.[^@]+$', email):
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Invalid email format"})
            }

        # Subscribe to SNS topic
        response = sns.subscribe(
            TopicArn=TOPIC_ARN,
            Protocol='email',
            Endpoint=email
        )
        
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": "Subscription successful! Please check your email to confirm.",
                "email": email
            })
        }
        
    except Exception as e:
        # Log the full error for debugging
        print(f"Error processing subscription: {str(e)}")
        
        # Return a generic error message to the client
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": "Internal server error"})
        }