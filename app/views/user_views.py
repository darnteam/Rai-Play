from fastapi import APIRouter
from models.dtos import UserResponse
from services.user_service import UserService

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
