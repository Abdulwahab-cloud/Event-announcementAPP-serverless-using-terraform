import json
import boto3
import uuid
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = "EVENTS_TABLE"
TOPIC_ARN = "PUT YOUT SNS TOPIC ARN HERE"

def lambda_handler(event, context):
    try:
        # Parse and validate input
        body = parse_input(event)
        
        # Generate unique ID and store event
        event_id = str(uuid.uuid4())
        store_event(body, event_id)
        
        # Format and send clean notification
        send_notification(body, event_id)
        
        return success_response(event_id)
        
    except ValueError as e:
        return bad_request_response(str(e))
    except Exception as e:
        print(f"Error: {str(e)}")
        return server_error_response()

def parse_input(event):
    """Parse and validate the input event"""
    if 'body' not in event or not event['body']:
        raise ValueError("Request body is missing")
    
    try:
        body = json.loads(event['body'])
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON format")
    
    required_fields = ["event_name", "description", "date", "location"]
    missing_fields = [f for f in required_fields if f not in body or not body[f]]
    
    if missing_fields:
        raise ValueError(f"Missing required fields: {', '.join(missing_fields)}")
    
    return body

def store_event(event_data, event_id):
    """Store event in DynamoDB"""
    event_data['event_id'] = event_id
    try:
        dynamodb.Table(TABLE_NAME).put_item(Item=event_data)
    except ClientError as e:
        print(f"DynamoDB Error: {e.response['Error']['Message']}")
        raise Exception("Failed to save event")

def send_notification(event_data, event_id):
    """Send properly formatted SNS notification"""
    try:
        # Create clean, readable message
        message = f"""
        New Event Created!
        
        Event: {event_data['event_name']}
        Date: {event_data['date']}
        Location: {event_data['location']}
        Description: {event_data['description'][:200]}...
        
        Event ID: {event_id}
        """
        
        # Remove extra whitespace and format cleanly
        message = '\n'.join(line.strip() for line in message.split('\n')).strip()
        
        sns.publish(
            TopicArn=TOPIC_ARN,
            Message=message,
            Subject=f"New Event: {event_data['event_name']}"
        )
    except ClientError as e:
        print(f"SNS Error: {e.response['Error']['Message']}")
        # Notification failure shouldn't fail the whole operation

def success_response(event_id):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "message": "Event created successfully",
            "event_id": event_id
        })
    }

def bad_request_response(error_msg):
    return {
        "statusCode": 400,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": error_msg})
    }

def server_error_response():
    return {
        "statusCode": 500,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": "Internal server error"})
    }