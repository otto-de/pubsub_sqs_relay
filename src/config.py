#! /usr/bin/env python3
import os


# will be injected via terraform lambda environment variables
# see terraform/service/lambda.tf
class Config:
    def __init__(self):
        self.expected_jwt_audience = os.environ.get("EXPECTED_JWT_AUDIENCE")
        self.expected_jwt_client_email = os.environ.get("EXPECTED_JWT_CLIENT_EMAIL")
        self.expected_gcp_subscription = os.environ.get("EXPECTED_GCP_SUBSCRIPTION")
        self.target_queue_url = os.environ.get("TARGET_QUEUE")
