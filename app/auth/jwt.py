from jose import jwt
from jose.exceptions import JWTError
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer
import requests
import json

# These must match your Cognito setup
COGNITO_REGION = "eu-central-1"
USER_POOL_ID = 'eu-central-1_DOMzKdfpW'
APP_CLIENT_ID = '5h10f0vss5p1p83pvmgmuhoqr1'

JWKS_URL = f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/{USER_POOL_ID}/.well-known/jwks.json"
ALGORITHM = "RS256"

http_bearer = HTTPBearer()

# Cache JWKS on first load
jwks = requests.get(JWKS_URL).json()

def verify_jwt_token(token: str):
    try:
        headers = jwt.get_unverified_header(token)
        kid = headers["kid"]

        key = next((k for k in jwks["keys"] if k["kid"] == kid), None)
        if key is None:
            raise HTTPException(status_code=401, detail="Invalid JWT key")

        payload = jwt.decode(
            token,
            key,
            algorithms=[ALGORITHM],
            audience=APP_CLIENT_ID,
            issuer=f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/{USER_POOL_ID}",
        )

        return payload

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_current_user(credentials=Security(http_bearer)):
    token = credentials.credentials
    payload = verify_jwt_token(token)
    return payload
