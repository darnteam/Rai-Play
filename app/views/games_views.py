from fastapi import APIRouter, Depends, Query
from services.games_service import GameService
from models.dtos import GameResponse
from typing import List
from auth.dependencies import get_current_user  
from models import User

router = APIRouter(prefix="/games", tags=["Games"])

service = GameService()

@router.get("/", response_model=List[GameResponse])
def get_games_by_completion(
    completed: bool = Query(False, description="Set to true to get completed games."),
    current_user: User = Depends(get_current_user)
):
    """
    Fetch a list of games based on completion status for the authenticated user.
    """
    return service.get_games_by_completion(current_user.id, completed)


@router.get("/minigames", response_model=List[GameResponse])
def get_all_minigames():
    """
    Returns all games with game_type = 'minigame'.
    """
    service = GameService()
    return service.get_all_minigames()


@router.get("/quests/storyline", response_model=List[GameResponse])
def get_quest_storyline():
    """
    Returns quest storyline games ordered by order_index.
    """
    service = GameService()
    return service.get_quest_storyline()