from fastapi import FastAPI
from views import routers
import uvicorn
from fastapi.routing import APIRouter
from starlette.middleware.sessions import SessionMiddleware
import os
from configuration import SESSION_SECRET_KEY

def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application.

    Returns:
        FastAPI: The configured FastAPI instance.
    """
    app = FastAPI(
        title="RaiPlay API",
        description="Backend service for the RaiPlay financial literacy app",
        version="1.0.0"
    )

    # Register all routers from the views module
    for router in routers:
        app.include_router(router)

    return app

app: FastAPI = create_app()

app.add_middleware(
    SessionMiddleware,
    secret_key= SESSION_SECRET_KEY
)

if __name__ == "__main__":
    # Run the application with live reloading
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
