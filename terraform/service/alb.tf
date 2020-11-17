resource "aws_lb_target_group" "lambda" {
  for_each    = { for rs in local.relay_settings : rs.service_name => rs }
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "lambda" {
  for_each         = { for rs in local.relay_settings : rs.service_name => rs }
  target_group_arn = aws_lb_target_group.lambda[each.key].arn
  target_id        = aws_lambda_function.lambda[each.key].arn
  depends_on = [
    aws_lambda_permission.lambda
  ]
}

resource "aws_alb_listener_rule" "lambda" {
  for_each     = { for rs in local.relay_settings : rs.service_name => rs }
  listener_arn = data.aws_alb_listener.alb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda[each.key].arn
  }

  # path all request to /pubsub_sqs_relay to the lambda
  condition {
    path_pattern {
      values = ["/${each.key}/*"]
    }
  }
}

resource "aws_lambda_permission" "lambda" {
  for_each      = { for rs in local.relay_settings : rs.service_name => rs }
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.key].function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}
