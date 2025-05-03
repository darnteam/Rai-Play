from fastapi import APIRouter, HTTPException, Request
from authlib.integrations.starlette_client import OAuth
from configuration import GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
from authlib.oauth2.rfc6749 import OAuth2Token, OAuth2Error
from app.services.auth_service import AuthService
from app.models.dtos.auth_dto import SignUpDTO, ConfirmSignUpDTO, LoginDTO

router = APIRouter(prefix="/auth", tags=["Auth"])

auth_service = AuthService()

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

@router.post("/signup")
async def signup(payload: SignUpDTO):
    try:
        await auth_service.sign_up(payload)
        return {"message": "Signup initiated. Please check your email for confirmation code."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/confirm-signup")
async def confirm_signup(payload: ConfirmSignUpDTO):
    try:
        await auth_service.confirm_sign_up(payload)
        return {"message": "User confirmed successfully."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/signin")
async def signin(payload: LoginDTO):
    try:
        tokens = await auth_service.sign_in(payload)
        return tokens
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))