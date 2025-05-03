from sqlalchemy import Column, Integer, String, Text, Enum, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.types import DateTime
from app.database import Base
import enum

class GameType(enum.Enum):
    quest = "quest"
    minigame = "minigame"

class Game(Base):
    __tablename__ = "games"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(Text)
    game_type = Column(Enum(GameType), nullable=False)
    category = Column(String(50))
    xp_reward = Column(Integer, default=0)
    coin_reward = Column(Integer, default=0)
    badge_id = Column(Integer, ForeignKey("badges.id"))
    completed = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
