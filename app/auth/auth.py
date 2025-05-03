import os
from datetime import datetime, timedelta, timezone
from repositories.user_repository import UserRepository
from dotenv import load_dotenv
from jose import jwt, JWTError
from fastapi.security import OAuth2PasswordBearer
from fastapi import Depends, HTTPException, status
from typing import Dict
from functools import lru_cache
from configuration import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
from models.dtos import UserResponse

class AuthService:
    """
    Handles authentication logic, including token generation and verification.
    
    This service provides methods for creating JWT access tokens, verifying them,
    and extracting user details from the token.
    """
    def __init__(self):
        self.repository = UserRepository()


    if not SECRET_KEY or not ALGORITHM or not ACCESS_TOKEN_EXPIRE_MINUTES:
        raise ValueError("Missing required environment variables: SECRET_KEY, ALGORITHM, or ACCESS_TOKEN_EXPIRE_MINUTES")

    ALGORITHM_SET: set[str] = {ALGORITHM}  # Preload as a set for faster lookup
    SECRET_KEY=SECRET_KEY
    ALGORITHM=ALGORITHM
    ACCESS_TOKEN_EXPIRE_MINUTES=ACCESS_TOKEN_EXPIRE_MINUTES
    @lru_cache()
    def get_oauth2_scheme() -> OAuth2PasswordBearer:
        """Cache the OAuth2PasswordBearer instance to reduce memory overhead."""
        return OAuth2PasswordBearer(tokenUrl="auth/login")

    oauth2_scheme: OAuth2PasswordBearer = get_oauth2_scheme()

    def create_access_token(self, user_id: int) -> str:
        """
        Generate a JWT access token containing `user_id`.

        This token will expire in `ACCESS_TOKEN_EXPIRE_MINUTES` minutes.

        Args:
            user_id (int): Unique identifier of the user.
            tenant_id (str): Tenant (schema) identifier.

        Returns:
            str: Encoded JWT access token.

        Example:
            ```python
            token = auth_service.create_access_token(user_id=123, tenant_id="tenant_1")
            ```
        """
        expire: datetime = datetime.now(timezone.utc) + timedelta(minutes=self.ACCESS_TOKEN_EXPIRE_MINUTES)
        payload: Dict[str, str | int | datetime] = {
            "sub": str(user_id),  # User ID as subject
            "exp": expire
        }
        return jwt.encode(payload, self.SECRET_KEY, algorithm=self.ALGORITHM)

    def verify_token(self, token: str) -> Dict[str, int | str]:
        """
        Decode and validate a JWT token.

        If the token is valid, extracts `user_id`. 
        Otherwise, raises an HTTP 401 Unauthorized error.

        Args:
            token (str): The JWT token.

        Returns:
            dict: Decoded token payload containing:
                - `user_id` (int)
                

        Raises:
            HTTPException: If the token is invalid or expired.

        Example:
            ```python
            payload = auth_service.verify_token(token)
            print(payload["user_id"], payload["tenant_id"])
            ```
        """
        try:
            payload: Dict[str, str] = jwt.decode(token, self.SECRET_KEY, algorithms=self.ALGORITHM_SET)
            user_id: str | None = payload.get("sub")


            if not user_id:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            return {"user_id": int(user_id)}

        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
                headers={"WWW-Authenticate": "Bearer"},
            )

    def get_current_user(self, token: str = Depends(oauth2_scheme)) -> UserResponse :
        """
        Extract `user_id` from a valid JWT token.

        This function acts as a FastAPI dependency for protected routes.

        Args:
            token (str): The JWT token obtained from the request.

        Returns:
            dict: Dictionary with:
                - `user_id` (int)
                

        Raises:
            HTTPException: If the token is invalid or expired.

        Example:
            ```python
            user = auth_service.verify_user(token)
            print(user["user_id"], user["tenant_id"])
            ```
        """
        result = self.verify_token(token=token)
        user_id = result["user_id"]
        user = self.repository.get_user_by_id(user_id=user_id)
        return user

    
   
    
auth_service: AuthService = AuthService()