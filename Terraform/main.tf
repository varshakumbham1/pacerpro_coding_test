provider "aws" {
  region = "us-east-1"
  profile = "dev"
}

# EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"
  tags = {
    Name = "Linux Web Server"
  }
}

# SNS topic
resource "aws_sns_topic" "sumo_alert_notification" {
  name = "sumo-alert-notification"
}

# SNS topic subscription
resource "aws_sns_topic_subscription" "user_updates_email_target" {
  topic_arn = aws_sns_topic.sumo_alert_notification.arn
  protocol  = "email"
  endpoint  = "varshareddykumbham@gmail.com"
}

# Lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "ec2_sns_lambda_policy" {
  name = "test_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RebootInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.sumo_alert_notification.arn
      },
    ]
  })
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function/lambda_handler.py"
  output_path = "lambda_function/lambda_handler.zip"

}

resource "aws_lambda_function" "restart_web_server" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function/lambda_handler.zip"
  function_name = "restart_web_server"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_handler.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      INSTANCE_ID = aws_instance.web.id,
      SNS_TOPIC_ARN = aws_sns_topic.sumo_alert_notification.arn
    }
  }
}

#Lambda function URL
resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.restart_web_server.function_name
  authorization_type = "AWS_IAM"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}


resource "aws_sns_topic_policy" "default" {
  arn = "${aws_sns_topic.sumo_alert_notification.arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_lambda_function.restart_web_server.arn,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${aws_sns_topic.sumo_alert_notification.arn}",
    ]
    sid = "__default_statement_ID"
  }
}
