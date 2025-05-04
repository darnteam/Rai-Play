from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from models import GameType  

class GameResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    game_type: GameType
    category: Optional[str] = None
    xp_reward: int
    coin_reward: int
    created_at: datetime

    class Config:
        orm_mode = True
        from_attributes = True