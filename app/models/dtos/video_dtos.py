from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class VideoResponse(BaseModel):
    id: int
    title: str
    url: str
    duration_seconds: Optional[int]
    created_at: datetime

    class Config:
        orm_mode = True
        from_attributes = True
