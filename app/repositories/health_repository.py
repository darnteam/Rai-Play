from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

class HealthRepository:
    """
    Repository class responsible for database health checks.
    """

    def __init__(self, db: AsyncSession) -> None:
        """
        Initialize HealthRepository with a database session.

        Args:
            db (AsyncSession): The async database session.
        """
        self.db = db

    async def check_database_connection(self) -> bool:
        """
        Check the health of the database by executing a simple query.

        Returns:
            bool: True if the database is reachable, False otherwise.
        """
        try:
            # Simple SELECT query to check DB connectivity
            await self.db.execute(text("SELECT 1"))
            return True
        except Exception:
            # Add logger here for monitoring failures
            return False
