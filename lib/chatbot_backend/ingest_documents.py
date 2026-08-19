import os
import json
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document

DOCUMENTS_DIR = "./documents"
VECTORSTORE_DIR = "./memory"

embedding = HuggingFaceEmbeddings(model_name="paraphrase-MiniLM-L3-v2")

def load_jsonl(filepath):
    docs = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            try:
                record = json.loads(line)
                text = record.get("text") or record.get("content") or ""
                metadata = {k: v for k, v in record.items() if k not in ["text", "content"]}
                if text.strip():
                    docs.append(Document(page_content=text, metadata=metadata))
            except json.JSONDecodeError:
                continue
    return docs

def ingest_documents():
    all_docs = []

    # Load PDFs
    pdf_files = sorted([f for f in os.listdir(DOCUMENTS_DIR) if f.endswith(".pdf")])
    for filename in pdf_files:
        print(f"Processing {filename}... ", end="")
        loader = PyPDFLoader(os.path.join(DOCUMENTS_DIR, filename))
        docs = loader.load()
        print(f"{len(docs)} pages.")
        all_docs.extend(docs)

    # Load JSONL
    jsonl_files = sorted([f for f in os.listdir(DOCUMENTS_DIR) if f.endswith(".jsonl")])
    for filename in jsonl_files:
        print(f"Processing {filename}... ", end="")
        docs = load_jsonl(os.path.join(DOCUMENTS_DIR, filename))
        print(f"{len(docs)} entries.")
        all_docs.extend(docs)

    if not all_docs:
        print("⚠️ No documents found.")
        return

    print(f"✅ Loaded total of {len(all_docs)} documents.")

    # Split
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
    split_docs = text_splitter.split_documents(all_docs)
    print(f"✅ Split into {len(split_docs)} chunks.")

    # Store in Chroma
    vectorstore = Chroma.from_documents(split_docs, embedding, persist_directory=VECTORSTORE_DIR)
    print("✅ Documents embedded and stored in Chroma.")

if __name__ == "__main__":
    ingest_documents()
