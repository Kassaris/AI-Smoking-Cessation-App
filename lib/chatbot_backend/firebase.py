# backend/firebase.py
import os
import firebase_admin
from firebase_admin import credentials, firestore

from dotenv import load_dotenv
load_dotenv()  # Must be before os.getenv


cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
if not firebase_admin._apps:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def get_user_profile(userId: str):
    doc = db.collection("users").document(userId).get()
    if doc.exists:
        return doc.to_dict()
    return {}