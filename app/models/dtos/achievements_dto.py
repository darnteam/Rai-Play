from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AchievementResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    icon_url: Optional[str]= None
    reward_type: str
    reward_amount: int
    created_at: datetime

    class Config:
        orm_mode = True
        from_attributes = True