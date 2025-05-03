from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

class GameType(str, Enum):
    quest = "quest"
    minigame = "minigame"

class GameCreate(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    game_type: GameType
    category: Optional[str] = None
    xp_reward: int = 0
    coin_reward: int = 0
    badge_id: Optional[int] = None

class GameUpdate(GameCreate):
    pass

class GameResponse(GameCreate):
    id: int
    created_at: datetime

class Config:
    orm_mode = True
    from_attributes = True  # for newer pydantic versions


