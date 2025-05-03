from repositories.games_repository import GamesRepository
from models.dtos import GameResponse
from typing import List

class GameService:
    """
    Service layer for game-related operations.
    """

    def __init__(self):
        self.repository = GamesRepository()

    def get_uncompleted_games(self, user_id: int) -> List[GameResponse]:
        """
        Return all games that the user has not completed yet.
        """
        games = self.repository.fetch_uncompleted_games(user_id)
        return [GameResponse.model_validate(game) for game in games]
