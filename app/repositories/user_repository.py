from sqlalchemy.orm import Session
from models import User, Achievement, UserAchievement
from typing import Optional
from database.connection import get_db
from hashlib import sha256
from datetime import datetime

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
    
    def create_user_from_google(self, email: str, name: str, avatar_url: Optional[str] = None) -> User:
        dummy_password = sha256(f"{email}{datetime.utcnow()}".encode()).hexdigest()

        new_user = User(
            username=name,
            email=email,
            password_hash=dummy_password,
            avatar_url=avatar_url,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )

        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user
    
    def get_user_by_email(self, email: str) -> Optional[User] :
        return self.db.query(User).filter(User.email == email).first()
    
    def create_user(self, email: str, username: str, password_hash: str) -> User:
        user = User(
            email=email,
            username=username,
            password_hash=password_hash
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_user_by_identifier(self, identifier: str) -> User:
        # This function returns a user by either email or username
        user = self.db.query(User).filter(
            (User.email == identifier) | (User.username == identifier)
        ).first()
        return user