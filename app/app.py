from fastapi import FastAPI
from views import routers
import uvicorn
from fastapi.routing import APIRouter

def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application.

    Returns:
        FastAPI: The configured FastAPI instance.
    """
    app = FastAPI(
        title="Money Matters API",
        description="Backend service for the Money Matters financial literacy app",
        version="1.0.0"
    )

    # Register all routers from the views module
    for router in routers:
        app.include_router(router)

    return app

app: FastAPI = create_app()

if __name__ == "__main__":
    # Run the application with live reloading
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
