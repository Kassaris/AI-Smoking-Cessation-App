import os
import pickle
import logging
from langchain.memory import ConversationBufferMemory

MAX_MEMORY_LENGTH = 10

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def prune_memory(memory):
    if hasattr(memory, "chat_memory"):
        messages = memory.chat_memory.messages
        if len(messages) > MAX_MEMORY_LENGTH:
            logger.info(f"Pruning memory to last {MAX_MEMORY_LENGTH} messages")
            memory.chat_memory.messages = messages[-MAX_MEMORY_LENGTH:]

def get_user_memory(user_id: str):
    memory_path = f"./memory/{user_id}.pkl"
    logger.info(f"Looking for memory at: {memory_path}")
    
    if os.path.exists(memory_path):
        logger.info("Memory file found. Loading...")
        try:
            with open(memory_path, "rb") as f:
                memory = pickle.load(f)
                prune_memory(memory)
                return memory
        except Exception as e:
            logger.exception("Failed to load memory file. Creating new memory.")

    logger.info("Memory not found or failed to load. Creating fresh memory.")
    return ConversationBufferMemory(memory_key="chat_history", return_messages=True)