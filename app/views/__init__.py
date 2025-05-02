from fastapi import APIRouter
#from .health_views import router as health_router
from .chat_views import router as chat_router
from .auth_views import router as auth_router

routers: list[APIRouter] = [
    auth_router,
    chat_router

]