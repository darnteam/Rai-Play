from sqlalchemy.orm import Session
from database.connection import get_db
from models import UserGame, Game, QuestStoryline, User, UserAchievement

class GameRepository:
    """
    Repository layer to handle game-related DB operations.
    """

    def __init__(self):
        self.db: Session = next(get_db())

    def fetch_games_by_completion(self, user_id: int, completed: bool):
        """
        Fetch games for the given user based on completion status.

        Args:
            user_id (int): The ID of the user.
            completed (bool): True for completed games, False for uncompleted games.

        Returns:
            List[UserGame]: List of user games filtered by completion status.
        """
        return (
            self.db.query(UserGame)
            .filter(UserGame.user_id == user_id, UserGame.completed == completed)
            .all()
        )

    
    def fetch_games_by_type(self, game_type: str):
        """
        Returns all games with the given game_type.
        """
        return self.db.query(Game).filter(Game.game_type == game_type).all()

    def fetch_quest_storyline_games(self):
        """
        Returns games in quest storyline ordered by order_index.
        """
        storyline_entries = (
            self.db.query(QuestStoryline)
            .order_by(QuestStoryline.order_index)
            .all()
        )

        game_ids = [entry.game_id for entry in storyline_entries]

        # Keep the order using an index map
        id_to_index = {id_: idx for idx, id_ in enumerate(game_ids)}
        
        games = self.db.query(Game).filter(Game.id.in_(game_ids)).all()
        games_sorted = sorted(games, key=lambda game: id_to_index[game.id])

        return games_sorted
    
    def mark_game_completed(self, user_id: int, game_id: int):
        """
        Marks the game as completed for the user. If the entry does not exist,
        it creates a new one marked as completed.
        """
        game_entry = (
            self.db.query(UserGame)
            .filter(UserGame.user_id == user_id, UserGame.game_id == game_id)
            .first()
        )

        if game_entry:
            game_entry.completed = True
        else:
            new_entry = UserGame(user_id=user_id, game_id=game_id, completed=True)
            self.db.add(new_entry)

        self.db.commit()

    def get_game_by_id(self, game_id: int) -> Game:
        return self.db.query(Game).filter(Game.id == game_id).one()

    def add_rewards_to_user(self, user_id: int, xp: int, coins: int):
        user = self.db.query(User).filter(User.id == user_id).first()
        if user:
            user.xp += xp
            user.coins += coins
            self.db.commit()

    def assign_achievement_if_missing(self, user_id: int, achievement_id: int):
        exists = (
            self.db.query(UserAchievement)
            .filter(UserAchievement.user_id == user_id, UserAchievement.achievement_id == achievement_id)
            .first()
        )
        if not exists:
            new_record = UserAchievement(user_id=user_id, achievement_id=achievement_id)
            self.db.add(new_record)
            self.db.commit()