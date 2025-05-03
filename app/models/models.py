from sqlalchemy import (
    Column, String, Integer, Text, Boolean, Date, Enum, ForeignKey, TIMESTAMP
)
from sqlalchemy.orm import relationship, declarative_base
import enum
from datetime import datetime

Base = declarative_base()


# ======================
# ENUMS
# ======================
class RewardType(enum.Enum):
    xp = "xp"
    coins = "coins"
    badge = "badge"


class GameType(enum.Enum):
    quest = "quest"
    minigame = "minigame"


# ======================
# USERS
# ======================
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False, index=True)
    password_hash = Column(Text, nullable=False)
    avatar_url = Column(Text)
    xp = Column(Integer, default=0)
    coins = Column(Integer, default=0)
    level = Column(Integer, default=1)
    streak_count = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)
    updated_at = Column(TIMESTAMP, default=datetime.utcnow)

    streak = relationship("UserStreak", uselist=False, back_populates="user")
    quest_progress = relationship("UserQuestProgress", back_populates="user")
    achievements = relationship("UserAchievement", back_populates="user")
    saved_videos = relationship("UserSavedVideo", back_populates="user")
    played_games = relationship("UserGame", back_populates="user")
    leaderboard_entries = relationship("LeaderboardEntry", back_populates="user")


# ======================
# GAMES
# ======================
class Game(Base):
    __tablename__ = "games"

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(Text)
    game_type = Column(Enum(GameType), nullable=False)
    category = Column(String(50))
    xp_reward = Column(Integer, default=0)
    coin_reward = Column(Integer, default=0)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

    storyline = relationship("QuestStoryline", back_populates="game", uselist=False)
    quest_progress = relationship("UserQuestProgress", back_populates="game")
    played_by_users = relationship("UserGame", back_populates="game")


# ======================
# QUEST STORYLINE
# ======================
class QuestStoryline(Base):
    __tablename__ = "quest_storyline"

    id = Column(Integer, primary_key=True)
    game_id = Column(Integer, ForeignKey("games.id", ondelete="CASCADE"), unique=True)
    order_index = Column(Integer, unique=True, nullable=False)

    game = relationship("Game", back_populates="storyline")



# ======================
# ACHIEVEMENTS
# ======================
class Achievement(Base):
    __tablename__ = "achievements"

    id = Column(Integer, primary_key=True)
    title = Column(String(100), nullable=False)
    description = Column(Text)
    icon_url = Column(Text)
    reward_type = Column(Enum(RewardType), nullable=False)
    reward_amount = Column(Integer, nullable=False)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

    user_achievements = relationship("UserAchievement", back_populates="achievement")


# ======================
# USER ACHIEVEMENTS
# ======================
class UserAchievement(Base):
    __tablename__ = "user_achievements"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    achievement_id = Column(Integer, ForeignKey("achievements.id", ondelete="CASCADE"))
    achieved_at = Column(TIMESTAMP, default=datetime.utcnow)

    user = relationship("User", back_populates="achievements")
    achievement = relationship("Achievement", back_populates="user_achievements")


# ======================
# USER STREAKS
# ======================
class UserStreak(Base):
    __tablename__ = "user_streaks"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    current_streak = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    last_checkin = Column(Date)

    user = relationship("User", back_populates="streak")


# ======================
# VIDEOS
# ======================
class Video(Base):
    __tablename__ = "videos"

    id = Column(Integer, primary_key=True)
    title = Column(String(100), nullable=False)
    url = Column(Text, nullable=False)
    duration_seconds = Column(Integer)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

    saved_by_users = relationship("UserSavedVideo", back_populates="video")


# ======================
# USER SAVED VIDEOS
# ======================
class UserSavedVideo(Base):
    __tablename__ = "user_saved_videos"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    video_id = Column(Integer, ForeignKey("videos.id", ondelete="CASCADE"))
    saved_at = Column(TIMESTAMP, default=datetime.utcnow)

    user = relationship("User", back_populates="saved_videos")
    video = relationship("Video", back_populates="saved_by_users")


# ======================
# USER PLAYED GAMES
# ======================
class UserGame(Base):
    __tablename__ = "user_games"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    game_id = Column(Integer, ForeignKey("games.id", ondelete="CASCADE"))
    completed = Column(Boolean, default=False)
    played_at = Column(TIMESTAMP, default=datetime.utcnow)

    user = relationship("User", back_populates="played_games")
    game = relationship("Game", back_populates="played_by_users")


# ======================
# LEADERBOARDS
# ======================
class Leaderboard(Base):
    __tablename__ = "leaderboards"

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    type = Column(String(50))
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

    entries = relationship("LeaderboardEntry", back_populates="leaderboard")


class LeaderboardEntry(Base):
    __tablename__ = "leaderboard_entries"

    id = Column(Integer, primary_key=True)
    leaderboard_id = Column(Integer, ForeignKey("leaderboards.id", ondelete="CASCADE"))
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    score = Column(Integer, nullable=False)
    recorded_at = Column(TIMESTAMP, default=datetime.utcnow)

    leaderboard = relationship("Leaderboard", back_populates="entries")
    user = relationship("User", back_populates="leaderboard_entries")
