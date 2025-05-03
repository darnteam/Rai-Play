from repositories.video_repository import VideoRepository
from models.dtos import VideoResponse
from typing import List

class VideoService:
    def __init__(self):
        self.repository = VideoRepository()

    def get_all_videos(self) -> List[VideoResponse]:
        videos = self.repository.fetch_all_videos()
        return [VideoResponse.model_validate(video) for video in videos]

    def get_saved_videos(self, user_id: int) -> List[VideoResponse]:
        saved_videos = self.repository.fetch_saved_videos(user_id)
        video_ids = [video.video_id for video in saved_videos]
        return [VideoResponse.model_validate(video) for video in self.repository.fetch_videos_by_ids(video_ids)]