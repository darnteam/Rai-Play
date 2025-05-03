import boto3
from botocore.exceptions import ClientError
from fastapi import HTTPException
from configuration import COGNITO_REGION, USER_POOL_ID, APP_CLIENT_ID

class AuthService:
    def __init__(self):
        self.client = boto3.client("cognito-idp", region_name=COGNITO_REGION)
        self.user_pool_id = USER_POOL_ID
        self.client_id = APP_CLIENT_ID

    def register_user(self, email: str, password: str):
        try:
            self.client.sign_up(
                ClientId=self.client_id,
                Username=email,
                Password=password,
                UserAttributes=[{"Name": "email", "Value": email}]
            )
        except ClientError as e:
            raise HTTPException(status_code=400, detail=e.response["Error"]["Message"])

    def confirm_user_registration(self, email: str, code: str):
        try:
            self.client.confirm_sign_up(
                ClientId=self.client_id,
                Username=email,
                ConfirmationCode=code
            )
        except ClientError as e:
            raise HTTPException(status_code=400, detail=e.response["Error"]["Message"])

    def authenticate_user(self, email: str, password: str):
        try:
            response = self.client.initiate_auth(
                AuthFlow='USER_PASSWORD_AUTH',
                AuthParameters={'USERNAME': email, 'PASSWORD': password},
                ClientId=self.client_id
            )
            return response["AuthenticationResult"]
        except ClientError as e:
            raise HTTPException(status_code=400, detail=e.response["Error"]["Message"])
