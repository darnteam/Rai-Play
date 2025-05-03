import boto3
from fastapi import HTTPException

# Initialize Cognito Client
cognito_client = boto3.client('cognito-idp', region_name='eu-central-1')  # Update the region

USER_POOL_ID = 'eu-central-1_DOMzKdfpW'
CLIENT_ID = '5h10f0vss5p1p83pvmgmuhoqr1'

def sign_up_user(username: str, password: str, email: str):
    try:
        response = cognito_client.sign_up(
            ClientId=CLIENT_ID,
            Username=username,
            Password=password,
            UserAttributes=[
                {'Name': 'email', 'Value': email},
            ]
        )
        return response
    except cognito_client.exceptions.UsernameExistsException:
        raise HTTPException(status_code=400, detail="Username already exists")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def authenticate_user(username: str, password: str):
    try:
        response = cognito_client.initiate_auth(
            ClientId=CLIENT_ID,
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': password
            }
        )
        return response['AuthenticationResult']
    except cognito_client.exceptions.NotAuthorizedException:
        raise HTTPException(status_code=401, detail="Incorrect username or password")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
