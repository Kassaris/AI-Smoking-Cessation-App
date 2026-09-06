# AI-Assisted Smoking Cessation Platform

A full-stack **mobile health application for smoking cessation**, combining a cross-platform Flutter client, Firebase cloud services, behavioral-support tools, and a **personalized Retrieval-Augmented Generation (RAG) assistant**.

Developed as a **Diploma Thesis at the National Technical University of Athens (NTUA), School of Electrical and Computer Engineering**.

## Overview

This thesis explores the design and implementation of an intelligent digital platform for supporting users throughout the smoking-cessation process.

The system combines conventional mobile-health functionality with a context-aware conversational assistant capable of incorporating:

* curated smoking-cessation knowledge,
* semantic document retrieval,
* user-specific cessation data,
* conversation history,
* and large language model generation.

The resulting platform integrates **mobile development, cloud infrastructure, backend engineering and applied generative AI** into a single end-to-end system.

### Key Capabilities

* Personalized smoking-cessation tracking
* Health and financial progress monitoring
* AI-powered conversational support
* Retrieval-Augmented Generation (RAG)
* User-profile-aware response generation
* Persistent conversational context
* Craving-management interventions
* Goals and achievement tracking
* Social and community features
* Push and local notifications
* AI response logging and evaluation

## Thesis

The accompanying Diploma Thesis documents the **system design, implementation, AI architecture, methodology and evaluation** in detail.

> 📄 **[Read the full Diploma Thesis (PDF)](PATH_TO_THESIS.pdf)**

The thesis provides the research and engineering context behind the implementation, including the motivation for the system, architectural decisions, smoking-cessation support methodology, RAG pipeline and evaluation process.

> **Project scope:** This repository contains the implementation of the system developed as part of the Diploma Thesis, including the Flutter mobile application, Firebase infrastructure, AI backend, retrieval pipeline and evaluation tooling.

---

## System Architecture

The platform follows a multi-component architecture separating the mobile client, cloud services and AI inference pipeline.

```text
┌───────────────────────────────────────────────┐
│              Flutter Mobile App               │
│                                               │
│  Progress · Goals · Cravings · Social · Chat  │
└───────────────┬───────────────────────────────┘
                │
        ┌───────┴───────────┐
        │                   │
        ▼                   ▼
┌───────────────┐    ┌──────────────────┐
│   Firebase    │    │  FastAPI Backend │
│               │    │                  │
│ Auth          │    │   /chat API      │
│ Firestore     │    └────────┬─────────┘
│ Storage       │             │
│ Messaging     │             ▼
└───────────────┘    ┌──────────────────┐
                     │ LangChain / RAG  │
                     └────────┬─────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
          User Profile     Chroma       Conversation
            Context       Retrieval       Memory
                │             │             │
                └─────────────┼─────────────┘
                              ▼
                      Context Assembly
                              │
                              ▼
                     OpenRouter / LLM
                              │
                              ▼
                    Personalized Response
```

This separation allows the mobile application, persistent user data and AI subsystem to evolve independently while communicating through clearly defined interfaces.

---

## Technology Stack

| Layer                  | Technologies                                  |
| ---------------------- | --------------------------------------------- |
| **Mobile Client**      | Flutter, Dart                                 |
| **State Management**   | Provider                                      |
| **Local Storage**      | Hive, SharedPreferences                       |
| **Authentication**     | Firebase Authentication, Google Sign-In       |
| **Cloud Database**     | Cloud Firestore                               |
| **Cloud Storage**      | Firebase Storage                              |
| **Notifications**      | Firebase Cloud Messaging, Local Notifications |
| **Backend API**        | Python, FastAPI                               |
| **AI Orchestration**   | LangChain                                     |
| **Vector Database**    | Chroma                                        |
| **Embeddings**         | HuggingFace Sentence Transformers             |
| **LLM Access**         | OpenRouter / DeepSeek                         |
| **External Retrieval** | Serper API                                    |
| **AI Evaluation**      | DeepEval                                      |

---

# Mobile Application

The Flutter application serves as the primary user-facing component of the platform.

It integrates cessation tracking, behavioral-support interventions, social functionality and the AI assistant within a unified mobile experience.

## Progress & Motivation

The application tracks the user's cessation journey and transforms progress into measurable feedback.

Functionality includes:

* smoke-free duration
* health progress
* financial progress
* personal goals
* achievements
* statistics
* motivational content
* daily cessation tips

These features provide users with continuous feedback throughout the cessation process.

## Craving Management

The application includes several interventions intended for moments of increased craving.

### Guided Breathing

Interactive breathing exercises provide structured techniques that users can access directly from the application.

### Distraction Activities

Short interactive games provide an alternative activity during craving episodes.

Implemented mini-games include:

* Snake
* Pac-Man
* Tic-Tac-Toe

### Additional Support

Users can also access motivational content, cessation resources, daily tips and the conversational assistant.

## Social Layer

Community-oriented functionality includes:

* Friends
* Global chat
* Leaderboards
* Achievements

Firebase provides the cloud infrastructure required for persistent user and social data.

---

# AI Conversational Assistant

A central engineering component of the thesis is the implementation of a **domain-specific, personalized RAG assistant for smoking-cessation support**.

Rather than forwarding user messages directly to a general-purpose LLM, the backend constructs responses using multiple contextual information sources.

```text
             User Message
                   │
                   ▼
        Semantic Relevance Check
                   │
                   ▼
        ┌──────────────────────┐
        │   Context Retrieval  │
        └──────────┬───────────┘
                   │
       ┌───────────┼────────────┐
       │           │            │
       ▼           ▼            ▼
 Knowledge      User Profile  Conversation
   Base           Context       History
       │           │            │
       └───────────┼────────────┘
                   ▼
             Prompt Context
                   │
                   ▼
                  LLM
                   │
                   ▼
        Personalized Response
```

## Retrieval-Augmented Generation

The knowledge retrieval layer is implemented using:

* **LangChain**
* **Chroma**
* **HuggingFace embeddings**

Documents are transformed into vector representations and stored in a persistent Chroma vector database.

For each relevant query, the system performs semantic retrieval to identify information from the knowledge base that can support response generation.

The retrieved context is then supplied to the language model together with the user's query and personalized context.

This architecture aims to produce responses that are more **domain-grounded and contextually relevant** than direct LLM generation.

## Personalization

User-specific information is retrieved from the application's data layer and incorporated into the conversational context.

Depending on available profile data, this may include:

* smoking frequency
* cigarette consumption
* smoking duration
* cigarette cost
* quit date
* previous cessation attempts
* craving situations
* confidence level
* environmental factors
* concerns about quitting
* personal motivations

Conceptually:

```text
Domain Knowledge
       +
User Profile
       +
Conversation History
       +
Current Question
       │
       ▼
Personalized Context
       │
       ▼
LLM Response
```

This enables the assistant to adapt its responses to the user's individual cessation journey instead of operating as a stateless general-purpose chatbot.

## Conversational Memory

The system maintains conversation context so that subsequent interactions can account for previous exchanges.

This allows follow-up questions and responses to remain contextually connected within an ongoing conversation.

## Semantic Relevance Filtering

Before entering the complete retrieval and generation pipeline, messages can be evaluated for semantic relevance to the smoking-cessation domain.

This acts as an additional control layer around the domain-specific assistant.

## External Search Fallback

The architecture also supports an external retrieval fallback through the **Serper API**.

When the primary knowledge retrieval pipeline cannot provide sufficient information, additional search results can be retrieved and incorporated into the response-generation process.

```text
Knowledge Base Retrieval
          │
          ▼
    Sufficient Context?
       /          \
     Yes           No
      │             │
      ▼             ▼
 LLM Response    Web Search
                    │
                    ▼
              Additional Context
                    │
                    ▼
                LLM Response
```

---

# Backend API

The AI subsystem is exposed to the Flutter application through a **FastAPI REST service**.

The primary conversational endpoint is:

```http
POST /chat/
```

Example request:

```json
{
  "userId": "<firebase-user-id>",
  "message": "<user-message>"
}
```

The backend is responsible for orchestrating:

1. Request validation
2. User identification
3. User-profile retrieval
4. Semantic relevance analysis
5. Vector retrieval
6. Conversation context
7. Prompt construction
8. LLM inference
9. Fallback retrieval
10. Response delivery

This keeps AI orchestration separate from the Flutter client and provides a dedicated service boundary for the conversational system.

---

# Firebase Infrastructure

Firebase provides the application's cloud data and identity layer.

```text
Firebase
│
├── Authentication
│   └── User identity / sign-in
│
├── Cloud Firestore
│   └── Application & user data
│
├── Cloud Storage
│   └── File / media storage
│
└── Cloud Messaging
    └── Push notifications
```

The mobile application additionally supports local persistence for selected application state using **Hive** and **SharedPreferences**.

---

# AI Evaluation

The repository includes dedicated tooling for logging and evaluating chatbot responses.

```text
lib/chatbot_backend/
├── create_logs.py
└── evaluate_with_deepeval.py
```

The evaluation pipeline uses **DeepEval** to provide a structured approach to assessing the conversational system.

This is an important part of the overall implementation: the AI component is treated not only as an integration with an LLM API, but as a subsystem whose generated responses can be **recorded, analyzed and evaluated**.

---

# Project Structure

```text
Smoking-Cessation-App/
│
├── lib/
│   │
│   ├── chatbot_backend/
│   │   ├── main.py
│   │   ├── langchain_logic.py
│   │   ├── firebase.py
│   │   ├── user_memory.py
│   │   ├── ingest_documents.py
│   │   ├── create_logs.py
│   │   ├── evaluate_with_deepeval.py
│   │   └── requirements.txt
│   │
│   ├── mini_games/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   ├── widgets/
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── assets/
│   ├── images/
│   └── audios/
│
├── UML/
├── pubspec.yaml
├── pubspec.lock
├── LICENSE
└── README.md
```

The repository separates the mobile application into models, providers, screens, services, reusable widgets and utilities, while the AI backend is maintained as a dedicated subsystem.

---

# Installation & Setup

## Prerequisites

### Mobile Application

* Flutter SDK
* Dart SDK
* Android Studio / Xcode
* Android emulator, iOS simulator or physical device
* Firebase project

Verify your Flutter environment:

```bash
flutter doctor
```

### AI Backend

* Python 3
* `pip`
* Python virtual environment
* Required API credentials
* Firebase Admin credentials

---

## 1. Clone the Repository

```bash
git clone https://github.com/Kassaris/Smoking-Cessation-App.git
cd Smoking-Cessation-App
```

## 2. Install Flutter Dependencies

```bash
flutter pub get
```

## 3. Configure Firebase

The Flutter application expects a Firebase configuration generated through FlutterFire:

```text
lib/firebase_options.dart
```

Platform-specific Firebase configuration may also be required:

```text
Android → android/app/google-services.json
iOS     → ios/Runner/GoogleService-Info.plist
```

Firebase service-account credentials and other sensitive configuration should **never be committed to version control**.

## 4. Configure the AI Backend

Navigate to:

```bash
cd lib/chatbot_backend
```

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it on Linux/macOS:

```bash
source .venv/bin/activate
```

or Windows:

```bash
.venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Configure the required credentials through environment variables or a local `.env` file.

Example:

```env
OPENROUTER_API_KEY=
SERPER_API_KEY=
FIREBASE_CREDENTIALS_PATH=
```

> `.env` files, API keys and Firebase service-account credentials must not be committed to the repository.

## 5. Prepare the Knowledge Base

The backend includes:

```text
ingest_documents.py
```

for processing the source documents used by the retrieval pipeline and creating the vector knowledge base.

Run the ingestion process as required before starting the RAG service.

## 6. Start the Backend

From the chatbot backend directory:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

The backend exposes:

```text
GET  /
POST /chat/
```

## 7. Run the Mobile Application

From the project root:

```bash
flutter run
```

When running the backend locally, ensure that the Flutter application uses an address reachable from the target device.

For Android Emulator environments, the host machine is commonly accessible through:

```text
10.0.2.2
```

rather than `localhost`.

---

# Engineering Highlights

The thesis combines several software engineering and applied AI areas within a single system:

### Mobile Engineering

* Cross-platform Flutter development
* Component-based UI architecture
* State management
* Local persistence
* REST API communication
* Authentication
* Push notifications

### Cloud & Backend Engineering

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Messaging
* FastAPI REST services
* User-specific backend context

### Applied AI

* Retrieval-Augmented Generation
* Vector databases
* Semantic embeddings
* Conversational retrieval
* User-aware prompt construction
* Conversation memory
* LLM API integration
* Semantic relevance filtering
* External retrieval fallback
* Automated response evaluation

### Software Architecture

* Separation of mobile and AI layers
* Service-oriented backend integration
* Persistent cloud state
* Modular Flutter structure
* Dedicated knowledge-ingestion pipeline
* Dedicated AI evaluation pipeline

---

# Diploma Thesis

This repository represents the software implementation developed for a **Diploma Thesis at the National Technical University of Athens (NTUA), School of Electrical and Computer Engineering**.

The work combines **mobile health software engineering with modern generative-AI techniques**, with particular emphasis on personalized conversational support and Retrieval-Augmented Generation for the smoking-cessation domain.

The complete thesis provides the theoretical background, system methodology, implementation details and evaluation.

> 📄 **[Read the full Diploma Thesis (PDF)](PATH_TO_THESIS.pdf)**

---

## Disclaimer

This system was developed for research and academic purposes.

The application and AI assistant are intended to provide informational and behavioral support and **do not constitute medical advice, diagnosis or treatment**. Generated responses should not replace guidance from qualified healthcare professionals.

---

**Flutter · Dart · Firebase · Python · FastAPI · LangChain · RAG · Chroma · HuggingFace · DeepSeek**

*Diploma Thesis — National Technical University of Athens, School of Electrical and Computer Engineering*
