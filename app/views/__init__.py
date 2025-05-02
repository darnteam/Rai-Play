from fastapi import APIRouter
#from .health_views import router as health_router
from .chat_views import router as chat_router

routers: list[APIRouter] = [

    chat_router

]