# Pub/Sub SQS Relay
This example implemenation shows how to forward messages from **GCP** Pub/Sub to **AWS** SQS.
It uses Pub/Sub Push Subscriptions, AWS lambda Functions and AWS SQS.

# Scenario
_Given:_ Two independent product teams want to exchange data, Team A (producer) lives 
in **GCP**, Team B (consumer) lives in **AWS**  
_Given:_ Team A uses GCP Pub/Sub to publish messages  
_When:_ A message is published via Pub/Sub (Team A)  
_Then:_ The message is forwarded to a AWS Lambda Function (Team B)  
_Then:_ The message is stored on AWS SQS (Team B)
 
# Solution
This repo shows an example how to deploy the resources and the AWS Lambda function.

# Deployment
```bash
├── src
│     ├── __init__.py
│     ├── config.py
│     ├── gcp_jwt_validator.py
│     ├── handler.py
│     ├── requirements.txt
│     └── util.py
├── terraform
│     ├── pipeline_role
│     │     ├── backend.tf
│     │     ├── constants.tf
│     │     ├── infra.tfvars
│     │     ├── live.tfvars
│     │     ├── main.tf
│     │     ├── nonlive.tfvars
│     │     ├── role.tf
│     │     └── variables.tf
│     ├── resources
│     │     ├── backend.tf
│     │     ├── constants.tf
│     │     ├── data.tf
│     │     ├── kms.tf
│     │     ├── live.tfvars
│     │     ├── main.tf
│     │     ├── nonlive.tfvars
│     │     ├── role_lambda_role.tf
│     │     ├── sqs.tf
│     │     └── variables.tf
│     └── service
│         ├── alb.tf
│         ├── backend.tf
│         ├── constants.tf
│         ├── data.tf
│         ├── lambda.tf
│         ├── live.tfvars
│         ├── main.tf
│         ├── nonlive.tfvars
│         └── variables.tf
├── test
│     ├── __init__.py
│     ├── resources
│     │     ├── test_handler_fail_invalid_http_method.json
│     │     └── test_handler_happy_path_input.json
│     ├── test_handler.py
│     └── utils.py
```

It deployes a bunch of AWS resources:
1. An encrypted SQS queue for receiving messages with KMS
2. IAM permissions to invoke the function
3. An AWS lambda function as HTTPS POST endpoint to receive messages
4. An ALB targetgroup to make the function public available (an ALB should already be deployed)
 
Before deployment, you need to exchange the expected_gcp_subscription, expected_jwt_email and expected_jwt_audience
validates that the request comes from this topic. These values are in the `service/constants.tf` 
as a variable injected into the deployment.

# Usage
1. Get the expected gcp values and inject them
2. Deploy the lambda function and send the endpoints url to the consumer
3. Deploy the GCP Pub/Sub subscription on the producers side
in the AWS account with a terraform resource deployment
like this:
```hcl-terraform
variable "aws_endpoint" {
  default = "https://my.loadbalancer.endpoint/my-function"
}

resource "google_pubsub_subscription" "relay_output_sub" {
  name                       = "others-subscription"
  topic                      = "my-outgoing-topic"
  message_retention_duration = "86400s" # 1 day
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  push_config {
    push_endpoint = var.aws_endpoint

    attributes = {
      x-goog-version = "v1"
    }
    oidc_token {
      service_account_email = var.relay_service_account_email
    }
  }

  retry_policy {
    minimum_backoff = "1s"
  }
}
``` 