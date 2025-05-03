from repositories.games_repository import GameRepository
from models.dtos import GameResponse
from typing import List

class GameService:
    """
    Service layer for game-related operations.
    """

    def __init__(self):
        self.repository = GameRepository()

    def get_uncompleted_games(self, user_id: int) -> List[GameResponse]:
        """
        Return all games that the user has not completed yet.
        """
        games = self.repository.fetch_uncompleted_games(user_id)
        return [GameResponse.model_validate(game) for game in games]
    
    def get_all_minigames(self) -> List[GameResponse]:
        """
        Returns all games with game_type = 'minigame'.
        """
        games = self.repository.fetch_games_by_type("minigame")
        return [GameResponse.model_validate(game) for game in games]
    
    def get_quest_storyline(self) -> List[GameResponse]:
        """
        Fetches and returns games in the quest storyline ordered by order_index.
        """
        games = self.repository.fetch_quest_storyline_games()
        return [GameResponse.model_validate(game) for game in games]
