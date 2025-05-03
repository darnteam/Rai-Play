from sqlalchemy.orm import Session
from models import User
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
