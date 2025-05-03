from fastapi import APIRouter

from .chat_views import router as chat_router
from .auth_views import router as auth_router
from .games_views import router as games_router 
from .user_views import router as user_router
from .video_views import router as video_router


routers: list[APIRouter] = [
    auth_router,
    chat_router,
    games_router,
    user_router,
    video_router,

]