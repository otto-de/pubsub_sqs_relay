resource "aws_sqs_queue" "queue" {
  name = "${local.service_name}-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600 // 14 days

  tags = {
    service     = local.service_name
    environment = var.environment
  }

  // set up dlq
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 3
  })

  kms_master_key_id = aws_kms_key.key.id
}

resource "aws_sqs_queue" "deadletter_queue" {
  #tfsec:ignore:AWS015
  name = "${local.service_name}-queue-dlq"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600 // 14 days

  tags = {
    name        = local.service_name
    environment = var.environment
  }
}
