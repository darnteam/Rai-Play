from fastapi import APIRouter, Depends
from services.games_service import GameService
from models.dtos import GameResponse
from typing import List
from auth.dependencies import get_current_user  
from models import User

router = APIRouter(prefix="/games", tags=["Games"])

service = GameService()

@router.get("/uncompleted", response_model=List[GameResponse])
def get_uncompleted_games(current_user: User = Depends(get_current_user)):
    """
    Fetch a list of games that the authenticated user has not completed yet.
    """
    return service.get_uncompleted_games(current_user.id)
