from fastapi import APIRouter
from services.video_service import VideoService
from models.dtos import VideoResponse
from typing import List

router = APIRouter(prefix="/videos", tags=["Videos"])


service = VideoService()

@router.get("/", response_model=List[VideoResponse])
def get_all_videos():
    """
    Returns all videos.
    """

    return service.get_all_videos()
