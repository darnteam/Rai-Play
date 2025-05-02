from fastapi import APIRouter
from health_views import router as health_router
routers: list[APIRouter] = [
    health_router

]