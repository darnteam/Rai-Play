from models.dtos import UserResponse
from repositories.user_repository import UserRepository
from models.dtos import AchievementResponse
from fastapi import HTTPException, status
from typing import List
from auth.auth import auth_service
from utils.auth_utils import hash_password, verify_password


class UserService:
    """
    Service for handling user-related business logic.
    """

    def __init__(self):
        self.user_repository = UserRepository()

    def get_user_info(self, user_id: int) -> UserResponse:
        """
        Get user information by ID.

        Args:
            user_id (int): User ID.

        Returns:
            UserDTO: User data.

        Raises:
            HTTPException: If user not found.
        """
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        return UserResponse.model_validate(user)
    
    def get_users_leaderboard(self) -> List[UserResponse]:
        """
        Get all users sorted by XP in descending order.
        """
        users = self.user_repository.fetch_all_users()
        sorted_users = sorted(users, key=lambda user: user.xp, reverse=True)
        return [UserResponse.model_validate(user) for user in sorted_users]

    def get_user_badges(self, user_id: int) -> List[AchievementResponse]:
        """
        Returns all badge-type achievements for the given user.
        """
        achievements = self.user_repository.fetch_user_badges(user_id)
        return [AchievementResponse.model_validate(a) for a in achievements]
    
    def login(self, identifier: str, password: str) -> dict:
        # Get user by email or username
        user = self.user_repository.get_user_by_identifier(identifier)
        if not user or not self.verify_password(password, user.password_hash):
            raise ValueError("Invalid credentials")

        # Create JWT token with the user's ID
        access_token = auth_service.create_access_token(user.id)
        
        return {"access_token": access_token, "token_type": "bearer"}
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return verify_password(plain_password, hashed_password)