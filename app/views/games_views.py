from fastapi import APIRouter, HTTPException, Query
from typing import List
from app.services.games_service import GameService
from app.models.dtos.games_dtos import GameCreate, GameUpdate, GameResponse, GameType

router = APIRouter(prefix="/games", tags=["games"])
game_service = GameService()

@router.post("/", response_model=GameResponse)
def create_game(game: GameCreate):
    """Create a new game."""
    try:
        return game_service.create_game(game)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{game_id}", response_model=GameResponse)
def get_game(game_id: int):
    """Retrieve a game by its ID."""
    try:
        game = game_service.get_game(game_id)
        if game is None:
            raise HTTPException(status_code=404, detail="Game not found")
        return game
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", response_model=List[GameResponse])
def get_games(skip: int = 0, limit: int = 100):
    """Retrieve a list of games."""
    try:
        return game_service.get_games(skip, limit)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{game_id}", response_model=GameResponse)
def update_game(game_id: int, game: GameUpdate):
    """Update an existing game."""
    try:
        updated_game = game_service.update_game(game_id, game)
        if updated_game is None:
            raise HTTPException(status_code=404, detail="Game not found")
        return updated_game
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{game_id}")
def delete_game(game_id: int):
    """Delete a game by its ID."""
    try:
        if not game_service.delete_game(game_id):
            raise HTTPException(status_code=404, detail="Game not found")
        return {"message": "Game deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/category/{category}", response_model=List[GameResponse])
def get_games_by_category(category: str):
    """
    Retrieve all games in a specific category.
    
    Args:
        category: Category name (e.g., 'crypto', 'debit', 'credit')
    """
    try:
        games = game_service.get_games_by_category(category)
        if not games:
            raise HTTPException(status_code=404, detail=f"No games found in category: {category}")
        return games
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/type/{game_type}", response_model=List[GameResponse])
def get_games_by_type(game_type: GameType):
    """
    Retrieve all games of a specific type.
    
    Args:
        game_type: Type of game (quest or minigame)
    """
    try:
        games = game_service.get_games_by_type(game_type)
        if not games:
            raise HTTPException(status_code=404, detail=f"No games found of type: {game_type}")
        return games
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/uncompleted/", response_model=List[GameResponse])
def get_uncompleted_games():
    """
    Retrieve all uncompleted games.
    """
    try:
        games = game_service.get_uncompleted_games()
        if not games:
            raise HTTPException(status_code=404, detail="No uncompleted games found")
        return games
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/uncompleted/category/{category}", response_model=List[GameResponse])
def get_uncompleted_games_by_category(category: str):
    """
    Retrieve uncompleted games in a specific category.
    
    Args:
        category: Category name (e.g., 'crypto', 'debit', 'credit')
    """
    try:
        games = game_service.get_uncompleted_by_category(category)
        if not games:
            raise HTTPException(
                status_code=404, 
                detail=f"No uncompleted games found in category: {category}"
            )
        return games
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

