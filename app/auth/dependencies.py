from fastapi import Depends
from models.dtos import UserResponse
from auth.auth import auth_service

def get_current_user(token: str = Depends(auth_service.oauth2_scheme)) -> UserResponse:
    return auth_service.get_current_user()