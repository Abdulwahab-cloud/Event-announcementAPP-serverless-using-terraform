# Serverless Announcement App
# Architecture
![Event driven (2)](https://github.com/user-attachments/assets/04fd238d-0918-42d1-8801-62def4bacbad)

A simple AWS serverless application that:
1. Lets users subscribe to announcements via email (SNS)
2. Allows admins to post events (stored in DynamoDB)
3. Automatically notifies all subscribers when new events are posted

## How It Works

1. **Frontend**: Static website (hosted on S3) with two forms:
   - Subscribe form (email input)
   - Event creation form (title + description)

2. **Backend**:
   - `/subscription` endpoint → Adds email to SNS topic
   - `/events` endpoint → Saves to DynamoDB + sends SNS notifications

3. **AWS Services Used**:
   - S3 (hosting)
   - API Gateway (endpoints)
   - Lambda (processing)
   - DynamoDB (storage)
   - SNS (notifications)
