from pydantic import BaseModel
from datetime import datetime

class AchievementResponse(BaseModel):
    id: int
    title: str
    description: str | None = None
    icon_url: str | None = None
    reward_type: str
    reward_amount: int
    created_at: datetime

    class Config:
        orm_mode = True
        from_attributes = True