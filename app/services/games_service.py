from sqlalchemy.orm import Session
from app.models.games import Game
from app.models.dtos.games_dtos import GameCreate, GameUpdate
from app.repositories.games_repository import GamesRepository
from typing import List, Optional

class GameService:
    """Service layer for handling game-related business logic."""

    def __init__(self) -> None:
        """Initialize GameService with repository."""
        self.repository = GamesRepository()

    def create_game(self, game: GameCreate) -> Game:
        """
        Create a new game.

        Args:
            game: GameCreate DTO containing game data

        Returns:
            Game: Created game instance
        """
        game_data = game.dict()
        return self.repository.create(game_data)

    def get_game(self, game_id: int) -> Optional[Game]:
        """
        Retrieve a game by ID.

        Args:
            game_id: ID of the game to retrieve

        Returns:
            Optional[Game]: Game if found, None otherwise
        """
        return self.repository.get_by_id(game_id)

    def get_games(self, skip: int = 0, limit: int = 100) -> List[Game]:
        """
        Retrieve all games with pagination.

        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return

        Returns:
            List[Game]: List of games
        """
        return self.repository.get_all(skip, limit)

    def update_game(self, game_id: int, game: GameUpdate) -> Optional[Game]:
        """
        Update a game's information.

        Args:
            game_id: ID of the game to update
            game: GameUpdate DTO containing update data

        Returns:
            Optional[Game]: Updated game if found, None otherwise
        """
        db_game = self.repository.get_by_id(game_id)
        if db_game:
            update_data = game.dict(exclude_unset=True)
            return self.repository.update(db_game, update_data)
        return None

    def delete_game(self, game_id: int) -> bool:
        """
        Delete a game.

        Args:
            game_id: ID of the game to delete

        Returns:
            bool: True if deleted successfully, False otherwise
        """
        db_game = self.repository.get_by_id(game_id)
        if db_game:
            self.repository.delete(db_game)
            return True
        return False

    def get_games_by_category(self, category: str) -> List[Game]:
        """Get all games in a specific category."""
        return self.repository.get_by_category(category)

    def get_games_by_type(self, game_type: str) -> List[Game]:
        """Get all games of a specific type."""
        return self.repository.get_by_game_type(game_type)

    def get_uncompleted_games(self) -> List[Game]:
        """Get all uncompleted games."""
        return self.repository.get_uncompleted_games()

    def get_uncompleted_by_category(self, category: str) -> List[Game]:
        """Get uncompleted games in a specific category."""
        return self.repository.get_uncompleted_by_category(category)


