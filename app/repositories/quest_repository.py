from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy import select, update, delete
from sqlalchemy.ext.asyncio import AsyncSession
from models import Quest, UserQuest
from datetime import datetime

class QuestRepository:
    """Repository for handling quest-related database operations."""

    @staticmethod
    async def create(session: AsyncSession, quest_data: Dict[str, Any]) -> Quest:
        """Create a new quest."""
        quest = Quest(**quest_data)
        session.add(quest)
        await session.commit()
        await session.refresh(quest)
        return quest

    @staticmethod
    async def get_all(session: AsyncSession) -> List[Quest]:
        result = await session.execute(select(Quest))
        return result.scalars().all()

    @staticmethod
    async def get_by_id(session: AsyncSession, quest_id: UUID) -> Optional[Quest]:
        result = await session.execute(select(Quest).where(Quest.id == quest_id))
        return result.scalar_one_or_none()

    @staticmethod
    async def update(session: AsyncSession, quest_id: UUID, quest_data: dict) -> Optional[Quest]:
        await session.execute(update(Quest).where(Quest.id == quest_id).values(**quest_data))
        await session.commit()
        return await QuestRepository.get_by_id(session, quest_id)

    @staticmethod
    async def delete(session: AsyncSession, quest_id: UUID) -> None:
        await session.execute(delete(Quest).where(Quest.id == quest_id))
        await session.commit()

    @staticmethod
    async def get_user_quests(
        session: AsyncSession,
        user_id: UUID,
        status: Optional[str] = None
    ) -> List[UserQuest]:
        """Get quests for a specific user."""
        query = select(UserQuest).where(UserQuest.user_id == user_id)
        if status:
            query = query.where(UserQuest.status == status)
        result = await session.execute(query)
        return result.scalars().all()

    @staticmethod
    async def get_completed_quests(
        session: AsyncSession,
        user_id: UUID
    ) -> List[UserQuest]:
        """Get completed quests for a user."""
        query = select(UserQuest).where(
            UserQuest.user_id == user_id,
            UserQuest.status == 'completed'
        )
        result = await session.execute(query)
        return result.scalars().all()

    @staticmethod
    async def start_quest(
        session: AsyncSession,
        user_id: UUID,
        quest_id: UUID
    ) -> UserQuest:
        """Start a new quest for a user."""
        user_quest = UserQuest(
            user_id=user_id,
            quest_id=quest_id,
            status='in_progress',
            started_at=datetime.utcnow()
        )
        session.add(user_quest)
        await session.commit()
        await session.refresh(user_quest)
        return user_quest
