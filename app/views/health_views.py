from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from database.connection import get_db
from services.health_service import HealthService
from repositories.health_repository import HealthRepository

router = APIRouter(prefix="/health", tags=["Health Check"])

@router.get("/", response_class=JSONResponse)
async def health_check(db: AsyncSession = Depends(get_db)) -> JSONResponse:
    """
    Health check endpoint to verify the application's status.

    Args:
        db (AsyncSession): Dependency-injected async DB session.

    Returns:
        JSONResponse: JSON object indicating service and database status.
    """
    # Inject repository into the service
    health_repo = HealthRepository(db)
    health_service = HealthService(health_repo)
    
    db_ok = await health_service.check_database()
    status = "ok" if db_ok else "error"
    status_code = 200 if db_ok else 500

    return JSONResponse(
        status_code=status_code,
        content={
            "status": status,
            "database": "connected" if db_ok else "disconnected"
        }
    )
