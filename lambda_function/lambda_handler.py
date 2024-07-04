import json
import boto3
import logging
import os

#Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        instance_id = os.environ['INSTANCE_ID']
        sns_topi_arn = os.environ['SNS_TOPIC_ARN']
        
        ## Rebooting the EC2 server
        logger.info(f"Attempting to reboot the EC2 instance: {instance_id}")
        ec2.reboot_instances(InstanceIds=[instance_id])
        logger.info(f"Rebooted the EC2 instance: {instance_id} successfully")
        
        ## Publish message to SNS
        message = f"EC2 instance {instance_id} has been rebooted due to an alert from SUMOLOGIC as reponses are taking > 3 seconds"
        subject = f"Server restarted as reponse_time > 3 seconds"
        sns.publish(
            TopicArn=sns_topi_arn,
            Message=message,
            Subject=subject,)
    except Exception as e:
        logger.error(f"Failed to restart the server or send notification {str(e)}")
        raise e
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Server {instance_id} rebooted successfully')
    }
