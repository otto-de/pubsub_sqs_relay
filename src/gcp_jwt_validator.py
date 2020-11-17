from google.auth.transport import requests
from google.oauth2 import id_token


class GcpJwtValidator:
    def __init__(self):
        pass

    # TODO check if cert caching is handled by lib ...
    # maybe caching doesn't make sense in lambda context
    @staticmethod
    def validate(gcp_jwt, expected_jwt_audience):
        decoded_jwt = id_token.verify_token(gcp_jwt, requests.Request(), audience=expected_jwt_audience)
        return {
            "email": decoded_jwt['email']
        }
