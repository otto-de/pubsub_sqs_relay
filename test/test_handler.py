from http import HTTPStatus
from unittest.mock import patch

from nose.tools import assert_equal

from src.config import Config
from src.gcp_jwt_validator import GcpJwtValidator
from src.handler import LambdaHandler
from src.util import read_json_as_dict


def get_test_config():
    config = Config()
    config.expected_jwt_audience = "https://my.loadbalancer.endpoint/pubsub_sqs_relay/"
    config.expected_jwt_client_email = "my-serviceaccount@my-project.iam.gserviceaccount.com"
    config.expected_gcp_subscription = "projects/my-project/subscriptions/relay-helloworld-helloworld-output-dummyteam2-subscription"
    config.target_queue_url = "dummy-queue"
    return config


@patch('src.gcp_jwt_validator.GcpJwtValidator')
@patch('src.handler.LambdaHandler.forward_to_sqs')
def test_handler_happy_path(mocked_validator, mocked_handler):
    # given
    expected_response = {'statusCode': HTTPStatus.OK, 'body': '"Success"'}
    mocked_validator.validate.return_value = {
        "email": "my-serviceaccount@my-project.iam.gserviceaccount.com"}

    # when
    result = LambdaHandler(mocked_validator, get_test_config()).handle_event(
        read_json_as_dict('resources/test_handler_happy_path_input.json'), None)

    # then
    assert_equal(result, expected_response)


def test_handler_fails_no_post_request():
    # given
    expected_response = {'statusCode': HTTPStatus.NOT_FOUND, 'body': '"Not Found"'}

    # when
    result = LambdaHandler(GcpJwtValidator(), get_test_config()).handle_event(
        read_json_as_dict('resources/test_handler_fail_invalid_http_method.json'), None)

    # then
    assert_equal(result, expected_response)


@patch('src.gcp_jwt_validator.GcpJwtValidator')
def test_handler_fails_invalid_email(mocked_validator):
    # given
    expected_response = {'statusCode': HTTPStatus.NOT_FOUND, 'body': '"Not Found"'}
    mocked_validator.validate.return_value = {"email": "not_gcp@invalid.com"}

    # when
    result = LambdaHandler(mocked_validator, get_test_config()).handle_event(
        read_json_as_dict('resources/test_handler_happy_path_input.json'), None)

    # then
    assert_equal(result, expected_response)


@patch('src.gcp_jwt_validator.GcpJwtValidator')
def test_handler_fails_invalid_gcp_subscription(mocked_validator):
    # given
    expected_response = {'statusCode': HTTPStatus.NOT_FOUND, 'body': '"Not Found"'}
    test_config = get_test_config()
    test_config.expected_gcp_subscription = "some_invalid_subscription"
    mocked_validator.validate.return_value = {"email": test_config.expected_jwt_client_email}

    # when
    result = LambdaHandler(mocked_validator, test_config).handle_event(
        read_json_as_dict('resources/test_handler_happy_path_input.json'), None)

    # then
    assert_equal(result, expected_response)


if __name__ == '__main__':
    from test.utils import execute_all_tests_in_current_file
    import sys

    execute_all_tests_in_current_file(sys.modules[__name__])
