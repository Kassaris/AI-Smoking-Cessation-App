from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_logic import run_chat_pipeline
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class ChatRequest(BaseModel):
    userId: str
    message: str

@app.get("/")  # ✅ Health check
async def root():
    logger.info("Health check accessed")
    return {"status": "Server is running 🚀"}

@app.post("/chat/")
async def chat(request: ChatRequest):
    logger.info(f"Received message from user {request.userId}: {request.message}")
    try:
        reply = str(run_chat_pipeline(request.userId, request.message))  # ✅ force plain string
        logger.info(f"Reply generated for user {request.userId}: {reply}")
        logger.info(f"Reply type: {type(reply)}")
        return {"reply": reply}
    except Exception as e:
        logger.exception("Error in /chat/ endpoint")
        raise HTTPException(status_code=500, detail=str(e))
