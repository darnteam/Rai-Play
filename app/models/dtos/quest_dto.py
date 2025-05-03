from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime

class QuestBase(BaseModel):
    title: str
    description: str
    category: str
    difficulty: int
    position_x: float
    position_y: float
    sequence_order: int
    prerequisite_quest_id: Optional[UUID]
    xp_reward: int
    coin_reward: int
    status: Optional[str] = "active"

class QuestCreate(QuestBase):
    pass

class QuestUpdate(BaseModel):
    title: Optional[str]
    description: Optional[str]
    category: Optional[str]
    difficulty: Optional[int]
    position_x: Optional[float]
    position_y: Optional[float]
    sequence_order: Optional[int]
    prerequisite_quest_id: Optional[UUID]
    xp_reward: Optional[int]
    coin_reward: Optional[int]
    status: Optional[str]

class QuestRead(QuestBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
