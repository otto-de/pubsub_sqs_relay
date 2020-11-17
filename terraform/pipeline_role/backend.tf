# In case of inital deploymet or disaster recovery remove the backend configuration
# the code cant deploy itself, when the resources used in the backend do not exist

terraform {
  backend "s3" {
    bucket         = "my-state-bucket-accountid-region"
    region         = "eu-central-1"
    key            = "pubsub_sqs_relay.json"
    dynamodb_table = "terraform-lock-table"
    role_arn       = "arn:aws:iam::ACCOUNT_ID:role/tf_state_pipeline_role"
    encrypt        = true
  }
}
