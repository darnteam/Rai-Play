from fastapi import APIRouter, HTTPException
from services.chat_service import ChatService
from models.dtos.chat_dto import ChatRequest, ChatResponse

router = APIRouter(prefix="/chat", tags=["Chatbot"])

chat_service = ChatService()

@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Endpoint to interact with the chatbot via Hugging Face Inference API.
    """
    try:
        reply = await chat_service.get_chat_response(request.message)
        return ChatResponse(reply=reply)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))