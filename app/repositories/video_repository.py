from database.connection import get_db
from models import Video

class VideoRepository:
    def __init__(self):
        self.db = next(get_db())

    def fetch_all_videos(self):
        return self.db.query(Video).all()
