from sqlalchemy import Column, String, Text, Integer, Float, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
import uuid
from database.connection import Base  # your declarative base (from declarative_base())

class Quest(Base):
    __tablename__ = "quests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(50), nullable=False)
    difficulty = Column(Integer, nullable=False, default=1)
    position_x = Column(Float, nullable=False)
    position_y = Column(Float, nullable=False)
    sequence_order = Column(Integer, nullable=False)
    prerequisite_quest_id = Column(UUID(as_uuid=True), ForeignKey("quests.id"), nullable=True)

    xp_reward = Column(Integer, nullable=False, default=20)
    coin_reward = Column(Integer, nullable=False, default=15)
    status = Column(String(20), default="active")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    prerequisite_quest = relationship("Quest", remote_side=[id], backref="dependent_quests")
    users = relationship("UserQuest", back_populates="quest")
