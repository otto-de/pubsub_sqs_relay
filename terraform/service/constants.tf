locals {
  nonlive_account_id = "111111111111"
  live_account_id    = "222222222222"
  infra_account_id   = "333333333333"
  team_name          = "awesome_team"
  service_name       = "pubsub_sqs_relay"

  # if the receiving side (AWS, lambda) can't handle the message it will be placed inside a DLQ on the sender side (GCP)
  relay_settings = [
    {
      service_name              = "dummy_service"
      expected_jwt_email        = "my-serviceaccount@the-serviceaccount.iam.gserviceaccount.com"
      target_queue_name         = "pubsub_sqs_relay-queue"
      expected_jwt_audience     = "https://my.loadbalancer.endpoint/dummy_service/"
      expected_gcp_subscription = "projects/the-serviceaccount/subscriptions/relay-helloworld-helloworld-output-dummyteam1-subscription"
    },
    {
      service_name              = "another_service"
      expected_jwt_email        = "my-serviceaccount@the-serviceaccount.iam.gserviceaccount.com"
      target_queue_name         = "pubsub_sqs_relay-queue"
      expected_jwt_audience     = "https://my.loadbalancer.endpoint/another_service/"
      expected_gcp_subscription = "projects/the-serviceaccount/subscriptions/relay-helloworld-helloworld-output-dummyteam2-subscription"
    }
  ]
}
