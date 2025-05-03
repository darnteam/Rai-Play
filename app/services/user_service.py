from models.dtos import UserResponse
from repositories.user_repository import UserRepository
from models.dtos import AchievementResponse
from fastapi import HTTPException, status
from typing import List

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