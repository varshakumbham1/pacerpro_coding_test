# Sumo Logic and AWS Setup Guide

This guide provides step-by-step instructions for setting up Sumo Logic queries and alerts, implementing an AWS Lambda function, and configuring infrastructure using Terraform.

## Prerequisites

- Sumo Logic account credentials
- AWS account credentials
- Python installed on your machine
- Terraform installed on your machine

## Setup Instructions

### Sumo Logic Hosted Collector with HTTP Source

1. **Log in to Sumo Logic**
   - Go to the Sumo Logic login page and sign in with your credentials.

2. **Navigate to Manage Data**
   - In the Sumo Logic dashboard, go to **Manage Data** and select **Collection** > **Collection**.

3. **Add a New Collector**
   - Click on **Add Collector** and choose **Hosted Collector (HTTP source)**.

4. **Configure the Collector**
   - Provide a name for your collector (e.g., "WebAppCollector"), optionally add a description, and configure additional settings. Click **Save**.

5. **Add an HTTP Source**
   - In the collector's details page, click on **Add Source** and select **HTTP Source**.

6. **Configure the HTTP Source**
   - Provide a name (e.g., "app/logs"), optionally add a description and set other configuration options like **Source Category**. Click **Save** and copy the HTTP Source URL.

7. **Send Logs to the HTTP Source**
   - Use Python to send logs to the HTTP Source URL with POST requests.

### Queries and Alerts in Sumo Logic

1. Open a new log search tab and use the query in `sumo_logic_query.txt`.
2. Navigate to **Manage Data** > **Monitoring** > **Monitor** > **Add Monitor**.
3. Create an alert with the specified settings and save it.

### AWS Configuration

1. **Create a Lambda Role**: Set up a role for the Lambda function.
2. **Create a Lambda Function**: Create the function and enable Functional URL with CORS.

### Webhook Connection for AWS Lambda

1. **Customer-Managed Policy**: Create a policy with the necessary permissions.
2. **IAM User**: Create a user, attach the policy, and generate an Access Key.
3. **Configure Webhook Connection**: Set up the connection in Sumo Logic with the IAM credentials and Lambda URL.

### EC2 and SNS Setup

1. Attach an inline policy for the lambda role to reboot EC2 and publish to SNS.
2. Deploy the lambda function and verify functionality.

### Terraform Deployment

1. Initialize Terraform: `terraform init`
2. Plan the deployment: `terraform plan`
3. Apply the deployment: `terraform apply`

#### Verification and Cleanup

1. Verify functionality, then destroy the infrastructure: `terraform destroy`
