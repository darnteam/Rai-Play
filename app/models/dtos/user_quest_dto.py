from pydantic import BaseModel, UUID4
from typing import Optional
from datetime import datetime

class UserQuestBase(BaseModel):
    """Base DTO for UserQuest with common attributes"""
    status: str
    progress: int = 0
    is_current: bool = False

class UserQuestCreate(UserQuestBase):
    """DTO for creating a new UserQuest"""
    quest_id: UUID4

class UserQuestUpdate(BaseModel):
    """DTO for updating a UserQuest"""
    status: Optional[str] = None
    progress: Optional[int] = None
    is_current: Optional[bool] = None

class UserQuestRead(UserQuestBase):
    """DTO for reading UserQuest data"""
    user_id: UUID4
    quest_id: UUID4
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
