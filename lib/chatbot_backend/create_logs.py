# lib/chatbot_backend/create_logs.py

import os
import pickle
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MEMORY_DIR = os.path.join(SCRIPT_DIR, "./memory")
OUT_LOG = os.path.join(SCRIPT_DIR, "./logs.jsonl")

if not os.path.exists(MEMORY_DIR):
    raise FileNotFoundError(f"Memory directory not found: {MEMORY_DIR}")

written_count = 0
with open(OUT_LOG, "w", encoding="utf-8") as f_out:
    for filename in os.listdir(MEMORY_DIR):
        if filename.endswith(".pkl"):
            path = os.path.join(MEMORY_DIR, filename)
            try:
                with open(path, "rb") as f:
                    memory = pickle.load(f)
                
                chat_records = getattr(memory, "retrieved_docs", [])
                for record in chat_records:
                    # Make sure retrieved_context exists
                    if "retrieved_context" not in record:
                        record["retrieved_context"] = []

                    f_out.write(json.dumps(record, ensure_ascii=False) + "\n")
                    written_count += 1

            except Exception:
                logger.exception(f"Failed to process memory file: {filename}")

logger.info(f"Logs written to {OUT_LOG}, total records: {written_count}")
print(f"Logs written to {OUT_LOG}, total records: {written_count}")
