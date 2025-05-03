from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from repositories.quest_repository import QuestRepository
from models import Quest, UserQuest

class QuestService:
    """Service layer for handling quest-related business logic."""

    @staticmethod
    async def create_quest(session: AsyncSession, quest_data: Dict[str, Any]) -> Quest:
        """
        Create a new quest.
        
        Args:
            session: Database session
            quest_data: Dictionary containing quest information
            
        Returns:
            Quest: Newly created quest
        """
        return await QuestRepository.create(session, quest_data)

    @staticmethod
    async def get_all_quests(
        session: AsyncSession,
        skip: int = 0,
        limit: int = 100,
        category: Optional[str] = None
    ) -> List[Quest]:
        """
        Retrieve all quests with optional filtering.
        
        Args:
            session: Database session
            skip: Number of records to skip
            limit: Maximum number of records to return
            category: Optional category filter
            
        Returns:
            List[Quest]: List of quests matching criteria
        """
        return await QuestRepository.get_all(session, skip, limit, category)

    @staticmethod
    async def get_user_quests(
        session: AsyncSession,
        user_id: UUID,
        status: Optional[str] = None
    ) -> List[UserQuest]:
        """
        Get all quests for a specific user.
        
        Args:
            session: Database session
            user_id: ID of the user
            status: Optional status filter (completed, in_progress, locked)
            
        Returns:
            List[UserQuest]: List of user's quests
        """
        return await QuestRepository.get_user_quests(session, user_id, status)

    @staticmethod
    async def get_completed_quests(
        session: AsyncSession,
        user_id: UUID
    ) -> List[UserQuest]:
        """
        Get all completed quests for a user.
        
        Args:
            session: Database session
            user_id: ID of the user
            
        Returns:
            List[UserQuest]: List of completed quests
        """
        return await QuestRepository.get_completed_quests(session, user_id)

    @staticmethod
    async def start_quest(
        session: AsyncSession,
        user_id: UUID,
        quest_id: UUID
    ) -> UserQuest:
        """
        Start a new quest for a user.
        
        Args:
            session: Database session
            user_id: ID of the user
            quest_id: ID of the quest
            
        Returns:
            UserQuest: Created user quest entry
        """
        return await QuestRepository.start_quest(session, user_id, quest_id)

    @staticmethod
    async def get_quest_by_id(session: AsyncSession, quest_id: UUID) -> Optional[Quest]:
        """
        Retrieve a quest by its ID.
        
        Args:
            session: Database session
            quest_id: ID of the quest
            
        Returns:
            Optional[Quest]: Quest object if found, else None
        """
        return await QuestRepository.get_by_id(session, quest_id)

    @staticmethod
    async def update_quest(session: AsyncSession, quest_id: UUID, quest_data: Dict[str, Any]) -> Optional[Quest]:
        """
        Update an existing quest.
        
        Args:
            session: Database session
            quest_id: ID of the quest
            quest_data: Dictionary containing updated quest information
            
        Returns:
            Optional[Quest]: Updated quest object if found, else None
        """
        return await QuestRepository.update(session, quest_id, quest_data)

    @staticmethod
    async def delete_quest(session: AsyncSession, quest_id: UUID) -> None:
        """
        Delete a quest by its ID.
        
        Args:
            session: Database session
            quest_id: ID of the quest
            
        Returns:
            None
        """
        await QuestRepository.delete(session, quest_id)
