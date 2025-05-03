from sqlalchemy.orm import Session
from app.models.games import Game
from typing import List, Optional, Dict, Any
from app.database.connection import get_db

class GamesRepository:
    """Repository for handling game-related database operations."""

    def __init__(self):
        self.get_db = get_db

    def create(self, game_data: Dict[str, Any]) -> Game:
        """
        Create a new game in the database.

        Args:
            game_data: Dictionary containing game data

        Returns:
            Game: Created game instance
        """
        db = next(self.get_db())
        try:
            db_game = Game(**game_data)
            db.add(db_game)
            db.commit()
            db.refresh(db_game)
            return db_game
        finally:
            db.close()

    def get_by_id(self, game_id: int) -> Optional[Game]:
        """
        Retrieve a game by its ID.

        Args:
            game_id: ID of the game to retrieve

        Returns:
            Optional[Game]: Game if found, None otherwise
        """
        db = next(self.get_db())
        try:
            return db.query(Game).filter(Game.id == game_id).first()
        finally:
            db.close()

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Game]:
        """
        Retrieve all games with pagination.

        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return

        Returns:
            List[Game]: List of games
        """
        db = next(self.get_db())
        try:
            return db.query(Game).offset(skip).limit(limit).all()
        finally:
            db.close()

    def update(self, game_id: int, update_data: Dict[str, Any]) -> Optional[Game]:
        """
        Update a game's information.

        Args:
            game_id: ID of the game to update
            update_data: Dictionary containing fields to update

        Returns:
            Optional[Game]: Updated game if found, None otherwise
        """
        db = next(self.get_db())
        try:
            game = db.query(Game).filter(Game.id == game_id).first()
            if game:
                for key, value in update_data.items():
                    setattr(game, key, value)
                db.commit()
                db.refresh(game)
                return game
            return None
        finally:
            db.close()

    def delete(self, game_id: int) -> bool:
        """
        Delete a game from the database.

        Args:
            game_id: ID of the game to delete

        Returns:
            bool: True if deleted successfully, False otherwise
        """
        db = next(self.get_db())
        try:
            game = db.query(Game).filter(Game.id == game_id).first()
            if game:
                db.delete(game)
                db.commit()
                return True
            return False
        finally:
            db.close()

    def get_by_category(self, category: str) -> List[Game]:
        """Get all games in a specific category."""
        db = next(self.get_db())
        try:
            return db.query(Game).filter(Game.category == category).all()
        finally:
            db.close()

    def get_by_game_type(self, game_type: str) -> List[Game]:
        """Get all games of a specific type."""
        db = next(self.get_db())
        try:
            return db.query(Game).filter(Game.game_type == game_type).all()
        finally:
            db.close()

    def get_uncompleted_games(self) -> List[Game]:
        """
        Retrieve all uncompleted games.

        Returns:
            List[Game]: List of uncompleted games
        """
        db = next(self.get_db())
        try:
            return db.query(Game).filter(Game.completed == False).all()
        finally:
            db.close()

    def get_uncompleted_by_category(self, category: str) -> List[Game]:
        """
        Retrieve uncompleted games in a specific category.

        Args:
            category: Category to filter by

        Returns:
            List[Game]: List of uncompleted games in category
        """
        db = next(self.get_db())
        try:
            return db.query(Game)\
                .filter(Game.category == category)\
                .filter(Game.completed == False)\
                .all()
        finally:
            db.close()


