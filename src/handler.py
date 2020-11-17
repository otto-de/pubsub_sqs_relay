#! /usr/bin/env python3
import json
from http import HTTPStatus

import boto3

from src.config import Config
from src.gcp_jwt_validator import GcpJwtValidator
from src.util import info


# see https://docs.aws.amazon.com/lambda/latest/dg/services-alb.html
# see https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
# see https://docs.aws.amazon.com/lambda/latest/dg/python-context.html
def handler(event, context):
    lambda_handler = LambdaHandler(GcpJwtValidator(), Config())
    return lambda_handler.handle_event(event, context)


class LambdaHandler:
    def __init__(self, gcp_jwt_validator, config):
        self.gcp_jwt_validator = gcp_jwt_validator
        self.expected_jwt_client_email = config.expected_jwt_client_email
        self.expected_jwt_audience = config.expected_jwt_audience
        self.expected_gcp_subscription = config.expected_gcp_subscription
        self.target_queue = config.target_queue_url

    def handle_event(self, event, context):
        info("Event: " + json.dumps(event))

        # wrap everything to prevent errors leaking to the outside
        try:
            self.validate_http_method(event)
            self.validate_authorization(event)
            self.validate_gcp_subscription(event)
            self.forward_to_sqs(event)
            return self.status_ok()
        except Exception as e:
            info("catched exception", e)
            # always return 404 in case something goes bonkers, so that potential attackers don't get too many details
            return self.status_not_found()

    def validate_gcp_subscription(self, event):
        gcp_subscription = json.loads(event["body"])["subscription"]
        if gcp_subscription != self.expected_gcp_subscription:
            raise Exception('wrong gcp subscription')

    def validate_authorization(self, event):
        authorization_header = event["headers"]["authorization"]
        token_method, jwt_token = authorization_header.split(' ', 1)
        if not (token_method.lower() == 'bearer' and jwt_token):
            info("Failing due to invalid token_method or missing jwt_token")
            raise Exception('Unauthorized')
        result = self.gcp_jwt_validator.validate(jwt_token, self.expected_jwt_audience)
        if result["email"] != self.expected_jwt_client_email:
            raise Exception('wrong email')

    @staticmethod
    def validate_http_method(event):
        if event["httpMethod"] != "POST":
            raise Exception('wrong httpMethod')

    @staticmethod
    def status_ok():
        return {
            "statusCode": HTTPStatus.OK,
            "body": json.dumps("Success")
        }

    @staticmethod
    def status_not_found():
        return {
            "statusCode": HTTPStatus.NOT_FOUND,
            "body": json.dumps("Not Found")
        }

    def forward_to_sqs(self, event):
        info("forwarding message to SQS: " + self.target_queue)
        message_to_forward = json.loads(event["body"])["message"]["data"]
        sqs_client = boto3.client('sqs')
        sqs_client.send_message(QueueUrl=self.target_queue, MessageBody=message_to_forward)
