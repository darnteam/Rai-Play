from sqlalchemy import Column, ForeignKey, String, Boolean, Integer, DateTime, UUID
from sqlalchemy.orm import relationship
from datetime import datetime
from database.connection import Base

class UserQuest(Base):
    """
    Model representing the relationship between users and quests.
    Tracks user progress and completion status for each quest.
    """
    __tablename__ = "user_quests"

    user_id = Column(UUID, ForeignKey("users.id"), primary_key=True)
    quest_id = Column(UUID, ForeignKey("quests.id"), primary_key=True)
    status = Column(String(20), default="locked", nullable=False)  # locked, in_progress, completed
    progress = Column(Integer, default=0)
    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    is_current = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="quests")
    quest = relationship("Quest", back_populates="users")

    def __repr__(self) -> str:
        return f"<UserQuest user_id={self.user_id} quest_id={self.quest_id} status={self.status}>"

    def mark_completed(self) -> None:
        """Mark the quest as completed and set completion timestamp."""
        self.status = "completed"
        self.progress = 100
        self.completed_at = datetime.utcnow()
        self.is_current = False

    def start_quest(self) -> None:
        """Start the quest and set initial timestamp."""
        self.status = "in_progress"
        self.started_at = datetime.utcnow()
        self.is_current = True

    def update_progress(self, progress: int) -> None:
        """
        Update the quest progress.
        
        Args:
            progress (int): New progress value (0-100)
        """
        self.progress = min(max(0, progress), 100)
        if self.progress == 100:
            self.mark_completed()
