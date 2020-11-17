data "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.team_name}-${replace(local.service_name, "_", "-")}-${local.infra_account_id}-${data.aws_region.current.name}"
}

data "aws_sqs_queue" "queue" {
  for_each = { for rs in local.relay_settings : rs.service_name => rs }
  name     = each.value.target_queue_name
}

data "aws_alb" "alb" {
  name = "entrance-loadbalancer"
}

data "aws_alb_listener" "alb_listener" {
  load_balancer_arn = data.aws_alb.alb.arn
  port              = 8443
}


data "aws_region" "current" {}
