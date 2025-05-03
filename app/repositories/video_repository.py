from database.connection import get_db
from models import Video, UserSavedVideo
from typing import List

class VideoRepository:
    def __init__(self):
        self.db = next(get_db())

    def fetch_all_videos(self):
        return self.db.query(Video).all()
    
    def fetch_saved_videos(self, user_id: int):
        return (
            self.db.query(UserSavedVideo)
            .filter(UserSavedVideo.user_id == user_id)
            .all()
        )

    def fetch_videos_by_ids(self, video_ids: List[int]):
        return (
            self.db.query(Video)
            .filter(Video.id.in_(video_ids))
            .all()
        )
