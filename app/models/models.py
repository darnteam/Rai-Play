from sqlalchemy import (
    Column, String, Integer, Text, Boolean, ForeignKey,
    DateTime, Enum, UniqueConstraint
)
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.sql import func
import enum

Base = declarative_base()

# ==========================
# ENUM TYPES
# ==========================
class RewardType(enum.Enum):
    xp = "xp"
    coins = "coins"
    badge = "badge"

class GameType(enum.Enum):
    quest = "quest"
    minigame = "minigame"


# ==========================
# USERS
# ==========================
class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(Text, nullable=False)
    avatar_url = Column(Text)
    xp = Column(Integer, default=0)
    coins = Column(Integer, default=0)
    level = Column(Integer, default=1)
    streak_count = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relationships
    achievements = relationship("UserAchievement", back_populates="user")
    saved_videos = relationship("UserSavedVideo", back_populates="user")
    played_games = relationship("UserGame", back_populates="user")


# ==========================
# GAMES
# ==========================
class Game(Base):
    __tablename__ = 'games'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(Text)
    game_type = Column(Enum(GameType), nullable=False)
    category = Column(String(50))
    xp_reward = Column(Integer, default=0)
    coin_reward = Column(Integer, default=0)
    achievement_id = Column(Integer, ForeignKey('achievements.id', ondelete="SET NULL"))
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    quest_storyline = relationship("QuestStoryline", back_populates="game")
    user_games = relationship("UserGame", back_populates="game")


# ==========================
# QUEST STORYLINE
# ==========================
class QuestStoryline(Base):
    __tablename__ = 'quest_storyline'

    id = Column(Integer, primary_key=True)
    game_id = Column(Integer, ForeignKey('games.id', ondelete="CASCADE"), nullable=False)
    order_index = Column(Integer, nullable=False)

    game = relationship("Game", back_populates="quest_storyline")

    __table_args__ = (
        UniqueConstraint('game_id'),
        UniqueConstraint('order_index'),
    )




# ==========================
# ACHIEVEMENTS
# ==========================
class Achievement(Base):
    __tablename__ = 'achievements'

    id = Column(Integer, primary_key=True)
    title = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(Text)
    reward_type = Column(Enum(RewardType), nullable=False)
    reward_amount = Column(Integer, nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    badge_id = Column(Integer, ForeignKey('badges.id'))
    badge = relationship("Badge", back_populates="achievements")
    user_achievements = relationship("UserAchievement", back_populates="achievement")


# ==========================
# USER ACHIEVEMENTS
# ==========================
class UserAchievement(Base):
    __tablename__ = 'user_achievements'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete="CASCADE"))
    achievement_id = Column(Integer, ForeignKey('achievements.id', ondelete="CASCADE"))
    achieved_at = Column(DateTime, server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="achievements")
    achievement = relationship("Achievement", back_populates="user_achievements")

    __table_args__ = (UniqueConstraint('user_id', 'achievement_id'),)


# ==========================
# VIDEOS
# ==========================
class Video(Base):
    __tablename__ = 'videos'

    id = Column(Integer, primary_key=True)
    title = Column(String(100), nullable=False)
    url = Column(Text, nullable=False)
    duration_seconds = Column(Integer)
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    user_saved_videos = relationship("UserSavedVideo", back_populates="video")


# ==========================
# USER SAVED VIDEOS
# ==========================
class UserSavedVideo(Base):
    __tablename__ = 'user_saved_videos'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete="CASCADE"))
    video_id = Column(Integer, ForeignKey('videos.id', ondelete="CASCADE"))
    saved_at = Column(DateTime, server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="saved_videos")
    video = relationship("Video", back_populates="user_saved_videos")

    __table_args__ = (UniqueConstraint('user_id', 'video_id'),)


# ==========================
# USER PLAYED GAMES
# ==========================
class UserGame(Base):
    __tablename__ = 'user_games'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete="CASCADE"))
    game_id = Column(Integer, ForeignKey('games.id', ondelete="CASCADE"))
    completed = Column(Boolean, default=False)
    played_at = Column(DateTime, server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="played_games")
    game = relationship("Game", back_populates="user_games")

    __table_args__ = (UniqueConstraint('user_id', 'game_id'),)
