from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import List, Optional
from database.connection import get_db
from services.quest_service import QuestService
from models.dtos.quest_dto import QuestCreate, QuestRead, QuestUpdate
from models.dtos.user_quest_dto import UserQuestRead, UserQuestUpdate  # Add this import
from auth.deps import get_current_user #IMPLEMENT AFTER AUTHENTIFICATION IS COMPLETE

router = APIRouter(prefix="/quests", tags=["Quests"])

@router.post("/", response_model=QuestRead)
async def create_quest(data: QuestCreate, session: AsyncSession = Depends(get_db)):
    return await QuestService.create_quest(session, data.dict())

@router.get("/user/current", response_model=List[UserQuestRead])
async def get_current_user_quests(
    status: Optional[str] = Query(None, enum=['completed', 'in_progress', 'locked']),
    session: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get quests for the current user with optional status filter."""
    return await QuestService.get_user_quests(session, current_user['id'], status)

@router.get("/user/completed", response_model=List[UserQuestRead])
async def get_user_completed_quests(
    session: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all completed quests for the current user."""
    return await QuestService.get_completed_quests(session, current_user['id'])

@router.post("/start/{quest_id}", response_model=UserQuestRead)
async def start_quest(
    quest_id: UUID,
    session: AsyncSession = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Start a new quest for the current user."""
    return await QuestService.start_quest(session, current_user['id'], quest_id)

@router.get("/", response_model=List[QuestRead])
async def get_quests(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    category: Optional[str] = None,
    session: AsyncSession = Depends(get_db)
):
    """Get all quests with pagination and optional category filter."""
    return await QuestService.get_all_quests(session, skip, limit, category)

@router.get("/{quest_id}", response_model=QuestRead)
async def get_quest(quest_id: UUID, session: AsyncSession = Depends(get_db)):
    quest = await QuestService.get_quest_by_id(session, quest_id)
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    return quest

@router.put("/{quest_id}", response_model=QuestRead)
async def update_quest(quest_id: UUID, data: QuestUpdate, session: AsyncSession = Depends(get_db)):
    quest = await QuestService.update_quest(session, quest_id, data.dict(exclude_unset=True))
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    return quest

@router.delete("/{quest_id}")
async def delete_quest(quest_id: UUID, session: AsyncSession = Depends(get_db)):
    await QuestService.delete_quest(session, quest_id)
    return {"detail": "Quest deleted successfully"}
