from fastapi import APIRouter, Depends
from auth.dependencies import get_current_user
from models import User
from models.dtos import AchievementResponse
from models.dtos import UserResponse
from services.user_service import UserService
from typing import List

router = APIRouter(prefix="/users", tags=["Users"])

service = UserService()

@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int):
    """
    Retrieve a user by ID.

    Args:
        user_id (int): ID of the user.

    Returns:
        UserDTO: User data.
    """
    return service.get_user_info(user_id)

@router.get("/leaderboard", response_model=List[UserResponse])
def get_leaderboard():
    """
    Return all users sorted by XP (descending) — used for leaderboard.
    """
    
    return service.get_users_leaderboard()


@router.get("/badges", response_model=List[AchievementResponse])
def get_user_badges(current_user: User = Depends(get_current_user)):
    """
    Returns all badges (achievements with reward_type='badge') for the current user.
    """
    return service.get_user_badges(current_user.id)