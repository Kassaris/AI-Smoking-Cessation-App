import os
import requests
import pickle
import logging
from langchain.chains import ConversationalRetrievalChain
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.memory import ConversationBufferMemory
from langchain.chat_models import ChatOpenAI
from sentence_transformers import SentenceTransformer, util
from typing import List, Dict, Any
from datetime import datetime, timezone

from user_memory import get_user_memory
from firebase import get_user_profile

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Semantic classifier model
smoking_model = SentenceTransformer('all-MiniLM-L6-v2')
smoking_examples = [
    "How do I quit smoking?", "What are the health risks of cigarettes?", "Tips to manage cravings",
    "What happens to my lungs after quitting?", "What helps with nicotine withdrawal?",
    "How long does withdrawal last?", "Should I use nicotine patches or gum?",
    "How do I stay motivated to quit?", "What are benefits of quitting smoking?"
]
smoking_embeddings = smoking_model.encode(smoking_examples, convert_to_tensor=True)


def is_smoking_related_semantic(message: str, threshold: float = 0.1) -> bool:
    query_embedding = smoking_model.encode(message, convert_to_tensor=True)
    similarity_scores = util.cos_sim(query_embedding, smoking_embeddings)
    max_score = similarity_scores.max().item()
    logger.info(f"Semantic similarity score: {max_score:.3f}")
    return max_score >= threshold


# Custom memory class with retrieved_docs
class CustomMemory(ConversationBufferMemory):
    retrieved_docs: List[Dict[str, Any]] = []


_qa_chain = None


def load_qa_chain():
    global _qa_chain
    if _qa_chain is None:
        logger.info("Initializing QA chain...")
        embedding = HuggingFaceEmbeddings(model_name="paraphrase-MiniLM-L3-v2")
        vectorstore = Chroma(persist_directory="./memory", embedding_function=embedding)

        llm = ChatOpenAI(
            model_name="deepseek/deepseek-chat",
            temperature=0.7,
            max_tokens=1024,
            openai_api_key=os.getenv("OPENROUTER_API_KEY"),
            request_timeout=10,
            openai_api_base="https://openrouter.ai/api/v1"
        )

        # Create a custom prompt template that matches the expected input variables
        from langchain.prompts import PromptTemplate
        
        # Define the prompt template with correct input variables
        template = """You are helping a user quit smoking.

Use the following retrieved documents to answer the question. 
**You must include the source title and year in your answer for each piece of information you reference.**
If multiple documents support the answer, cite all relevant sources.

Context: {context}

Question: {question}

Answer:"""

        QA_PROMPT = PromptTemplate(
            template=template,
            input_variables=["context", "question"]
        )

        # Create memory with explicit input/output keys
        memory = CustomMemory(
            memory_key="chat_history", 
            return_messages=True,
            input_key="question",
            output_key="answer"
        )

        # Create the chain with explicit output key
        _qa_chain = ConversationalRetrievalChain.from_llm(
            llm=llm,
            retriever=vectorstore.as_retriever(),
            memory=memory,
            combine_docs_chain_kwargs={"prompt": QA_PROMPT},
            return_source_documents=True,
            output_key="answer"  # This tells the chain which output to use
        )

    logger.info("QA chain initialized.")
    return _qa_chain


def query_web_search_api(query: str):
    api_key = os.getenv("SERPER_API_KEY")
    if not api_key:
        logger.warning("SERPER_API_KEY not found.")
        return None

    url = "https://google.serper.dev/search"
    headers = {"X-API-KEY": api_key, "Content-Type": "application/json"}
    data = {"q": f"{query} smoking cessation quitting cigarettes health"}

    try:
        response = requests.post(url, headers=headers, json=data)
        if response.status_code == 200:
            json_data = response.json()
            results = []
            for result in json_data.get("organic", []):
                title = result.get("title", "")
                snippet = result.get("snippet", "")
                link = result.get("link", "")
                results.append(f"- [{title}]({link})\n  {snippet}")
            return "\n".join(results) if results else None
        else:
            logger.error(f"Serper API error {response.status_code}: {response.text}")
    except Exception:
        logger.exception("Web search API exception")
    return None


def run_chat_pipeline(userId: str, message: str):
    logger.info(f"Running chat pipeline for user {userId} with message: {message}")

    if not is_smoking_related_semantic(message):
        logger.info("Off-topic question detected.")
        return "I'm here to help with smoking cessation. Please ask something related to quitting smoking. 💪🚭"

    user_profile = get_user_profile(userId)
    logger.info(f"Fetched user profile: {user_profile}")

    # Load QA chain first to get the properly configured memory
    qa_chain = load_qa_chain()
    
    # Get memory from the chain instead of loading separately
    memory = qa_chain.memory

    # Fetch values from user profile safely
    cigarettes_per_day = user_profile.get("cigarettesPerDay", 0)
    cigarettes_per_pack = user_profile.get("cigarettesPerPack", 20)
    cost_per_pack = user_profile.get("costPerPack", 0.0)

    # Calculate cost per day
    cost_per_day = 0.0
    if cigarettes_per_pack > 0:
        cost_per_day = (cigarettes_per_day / cigarettes_per_pack) * cost_per_pack

    # Calculate smoke-free time
    quit_timestamp = user_profile.get("quitDate")
    smoke_free_time_str = "Not available"
    if quit_timestamp:
        try:
            quit_date = datetime.fromtimestamp(quit_timestamp, tz=timezone.utc)
            now = datetime.now(timezone.utc)
            delta = now - quit_date
            days = delta.days
            hours = delta.seconds // 3600
            minutes = (delta.seconds % 3600) // 60
            smoke_free_time_str = f"{days} days, {hours} hours, {minutes} minutes"
        except Exception as e:
            logger.warning(f"Could not parse quitDate: {e}")

    # Structured user prompt for better LLM results
    personalized_context = f"""You are helping a user quit smoking.

User Profile:
- Name: {user_profile.get("username", "Unknown")}
- Gender: {user_profile.get("gender", "unspecified")}
- Cigarettes per day: {cigarettes_per_day} cigarettes/day
- Cigarettes per pack: {cigarettes_per_pack} cigarettes/pack
- Cost per pack: {cost_per_pack} $
- Cost per day: {cost_per_day:.2f} $
- Smoking Duration: {user_profile.get("smokingYears", 0)} years
- Quit Date: {quit_timestamp if quit_timestamp else "Not provided"}
- Smoke-free time: {smoke_free_time_str}
- Completed Achievements: {", ".join(user_profile.get("completedAchievements", []))}
- Reason of smoking: {user_profile.get("whySmoke", "Unknown")}
- Feelings while smoking: {user_profile.get("feelWhenSmoking", "Unknown")}
- Type of smoker: {user_profile.get("typeOfSmoker", "Unknown")}
- Reason of quitting: {user_profile.get("whyQuit", "Unknown")}
- Methods of quitting tried/ if tried: {user_profile.get("triedQuitMethods", "Unknown")}
- What do cigarettes mean to the user emotionally: {user_profile.get("emotionalMeaning", "Unknown")}
- In what situations the user crave cigarettes: {user_profile.get("cravingSituations", "Unknown")}
- How confident is the user in quitting: {user_profile.get("confidenceLevel", "Unknown")}
- Do the user live/work with other smokers? : {user_profile.get("smokingEnvironment", "Unknown")}
- The users biggest fear about quitting: {user_profile.get("biggestFear", "Unknown")}
- The users biggest motivation to stay smoke-free: {user_profile.get("biggestMotivation", "Unknown")}

Use this information to personalize your answers and motivation strategies.
Do not mention the term retrived documents in the conversation.
"""

    # Retrieve relevant documents
    retrieved_docs = qa_chain.retriever.get_relevant_documents(message)

    # Build context with source title + year
    retrieved_context_with_source = []
    for doc in retrieved_docs:
        title = doc.metadata.get("title", " ")
        year = doc.metadata.get("year", " ")
        retrieved_context_with_source.append(f"[{title} ({year})] {doc.page_content}")

    # Combine personalized context + retrieved docs
    context_text = f"{personalized_context}\n\nRetrieved Documents:\n" + "\n\n".join(retrieved_context_with_source)

    # Create the input with context included in the question
    modified_question = f"Context: {context_text}\n\nQuestion: {message}"
    
    # Run the chain
    result = qa_chain({
        "question": modified_question,
        "chat_history": memory.load_memory_variables({})["chat_history"]
    })

    answer = result["answer"]
    logger.info(f"Answer: {answer}")

    # Optional fallback
    if len(answer) < 20 or "i don't know" in answer.lower():
        web_snippets = query_web_search_api(message)
        if web_snippets:
            fallback_prompt = f"{personalized_context}\nSearch Results:\n{web_snippets}\nQuestion: {message}"
            answer = qa_chain.llm.predict(fallback_prompt)
            logger.info(f"Fallback answer: {answer}")

    # Save retrieved context for logging/evaluation (with sources)
    if hasattr(memory, 'retrieved_docs'):
        memory.retrieved_docs.append({
            "input": message,
            "response": answer,
            "retrieved_context": retrieved_context_with_source
        })

    # Save memory to disk
    try:
        os.makedirs("./memory", exist_ok=True)
        with open(f"./memory/{userId}.pkl", "wb") as f:
            pickle.dump(memory, f)
        logger.info(f"Memory saved to ./memory/{userId}.pkl")
    except Exception:
        logger.exception("Failed to save memory")

    return answer