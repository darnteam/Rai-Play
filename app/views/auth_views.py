from fastapi import APIRouter, HTTPException, Request
from authlib.integrations.starlette_client import OAuth
from configuration import GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
from authlib.oauth2.rfc6749 import OAuth2Token, OAuth2Error
router = APIRouter(prefix="/auth", tags=["Auth"])

oauth = OAuth()
oauth.register(
    name="google",
    client_id=GOOGLE_CLIENT_ID,
    client_secret=GOOGLE_CLIENT_SECRET,
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"},
)

@router.get("/login/google")
async def login_via_google(request: Request):
    """Redirects user to Google's OAuth consent screen."""
    redirect_uri = GOOGLE_REDIRECT_URI
    return await oauth.google.authorize_redirect(request, redirect_uri)

@router.get("/callback/google")
async def google_auth_callback(request: Request):
    """Handles callback from Google and returns user info."""
    
    user_response: OAuth2Token = await oauth.google.authorize_access_token(request)
    user_info = user_response.get("userinfo")
    return user_info
