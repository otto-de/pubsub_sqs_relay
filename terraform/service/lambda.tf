resource "aws_lambda_function" "lambda" {
  for_each      = { for rs in local.relay_settings : rs.service_name => rs }
  function_name = "${local.service_name}-lambda-${each.value.service_name}"
  role          = "arn:aws:iam::${var.account_id}:role/${local.service_name}_lambda_role"
  handler       = "src/handler.handler"
  runtime       = "python3.8"

  s3_bucket = data.aws_s3_bucket.lambda_bucket.id
  s3_key    = "lambda-${var.lambda_version}.zip"

  environment {
    variables = {
      TARGET_QUEUE              = data.aws_sqs_queue.queue[each.key].url
      EXPECTED_JWT_AUDIENCE     = each.value.expected_jwt_audience
      EXPECTED_JWT_CLIENT_EMAIL = each.value.expected_jwt_email
      EXPECTED_GCP_SUBSCRIPTION = each.value.expected_gcp_subscription
    }
  }
}
