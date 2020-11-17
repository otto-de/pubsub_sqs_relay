provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/${local.service_name}_pipeline_role"
  }
  allowed_account_ids = ["111111111111", "222222222222"] // only nonlive, live
}