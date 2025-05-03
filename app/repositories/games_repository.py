from sqlalchemy.orm import Session
from database.connection import get_db
from models import UserGame

class GameRepository:
    """
    Repository layer to handle game-related DB operations.
    """

    def __init__(self):
        self.db: Session = next(get_db())

    def fetch_uncompleted_games(self, user_id: int):
        """
        Fetch all uncompleted games for the given user from user_games table.
        """
        return (
            self.db.query(UserGame)
            .filter(UserGame.user_id == user_id, UserGame.completed == False)
            .all()
        )
