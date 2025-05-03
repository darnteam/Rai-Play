from fastapi import APIRouter, HTTPException, Request, status
import bcrypt
from configuration import GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
from authlib.integrations.starlette_client import OAuth
from authlib.oauth2.rfc6749 import OAuth2Token, OAuth2Error
from models.dtos import SignUpDTO, ConfirmSignUpDTO, LoginDTO
from repositories.user_repository import UserRepository
from auth.auth import auth_service
from fastapi.responses import JSONResponse
from services.user_service import UserService
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends



router = APIRouter(prefix="/auth", tags=["Auth"])


user_repository = UserRepository()
user_service = UserService()
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
    """
    Handles Google OAuth callback:
    - Gets user info from Google
    - Checks/creates user in DB
    - Returns JWT access token
    """
    try:
        token = await oauth.google.authorize_access_token(request)
        user_info = token.get("userinfo")

        if not user_info or "email" not in user_info:
            raise HTTPException(status_code=400, detail="Failed to retrieve user info from Google.")

        email = user_info["email"]
        name = user_info.get("name", email.split("@")[0])

        user_repo = UserRepository()
        user = user_repo.get_user_by_email(email)

        if not user:
            user = user_repo.create_user_from_google(email=email, name=name, avatar_url=None)

        access_token = auth_service.create_access_token(user_id=user.id)

        return JSONResponse(content={"access_token": access_token, "token_type": "bearer"})

    except OAuth2Error as e:
        raise HTTPException(status_code=400, detail=f"Google OAuth error: {str(e)}")
    

@router.post("/signup")
def signup(payload: SignUpDTO):
    """
    Handles user registration:
    - Validates email uniqueness
    - Hashes password
    - Stores new user
    - Returns JWT access token
    """
    existing_user = user_repository.get_user_by_email(payload.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already registered.",
        )

    hashed_password = bcrypt.hash(payload.password)
    new_user = user_repository.create_user(
        email=payload.email,
        username=payload.username,
        password_hash=hashed_password,
    )

    access_token = auth_service.create_access_token(user_id=new_user.id)

    return JSONResponse(content={"access_token": access_token, "token_type": "bearer"})

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends() ):
    try:
        result = user_service.login(form_data.username, form_data.password)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))
    
    return result