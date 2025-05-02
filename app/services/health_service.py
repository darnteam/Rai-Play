from repositories.health_repository import HealthRepository

class HealthService:
    """
    Service class responsible for health checks.
    """

    def __init__(self, health_repo: HealthRepository) -> None:
        """
        Initialize HealthService with a HealthRepository.

        Args:
            health_repo (HealthRepository): The health repository to interact with DB.
        """
        self.health_repo = health_repo

    async def check_database(self) -> bool:
        """
        Check the database health by calling the repository's method.

        Returns:
            bool: True if the database is reachable, False otherwise.
        """
        return await self.health_repo.check_database_connection()
