from sqlalchemy.orm import Session
from models import User, Achievement, UserAchievement
from typing import Optional
from database.connection import get_db

class UserRepository:
    """
    Repository for performing database operations related to users.
    """

    def __init__(self):
        self.db: Session = next(get_db())  # get a DB session instance

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """
        Retrieve a user by ID.

        Args:
            user_id (int): User ID.

        Returns:
            Optional[User]: User if found, else None.
        """
        return self.db.query(User).filter(User.id == user_id).first()
    
    def fetch_all_users(self):
        """
            Retrieve all users from the database.
        """
        return self.db.query(User).all()
    
    def fetch_user_badges(self, user_id: int):
        """
        Get all achievements of type 'badge' for the given user.
        """
        return (
            self.db.query(Achievement)
            .join(UserAchievement, UserAchievement.achievement_id == Achievement.id)
            .filter(UserAchievement.user_id == user_id)
            .filter(Achievement.reward_type == "badge")
            .all()
        )
