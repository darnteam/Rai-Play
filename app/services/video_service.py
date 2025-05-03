from repositories.video_repository import VideoRepository
from models.dtos import VideoResponse
from typing import List

class VideoService:
    def __init__(self):
        self.repository = VideoRepository()

    def get_all_videos(self) -> List[VideoResponse]:
        videos = self.repository.fetch_all_videos()
        return [VideoResponse.from_orm(video) for video in videos]
