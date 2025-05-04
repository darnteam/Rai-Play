from fastapi import APIRouter, Depends
from auth.dependencies import get_current_user
from services.video_service import VideoService
from models.dtos import VideoResponse
from typing import List
from models import User

router = APIRouter(prefix="/videos", tags=["Videos"])


service = VideoService()

@router.get("/", response_model=List[VideoResponse])
def get_all_videos():
    """
    Returns all videos.
    """

    return service.get_all_videos()


@router.get("/saved", response_model=List[VideoResponse])
def get_saved_videos(current_user: User = Depends(get_current_user)):
    """
    Fetch a list of videos saved by the authenticated user.
    """
    return service.get_saved_videos(current_user.id)
