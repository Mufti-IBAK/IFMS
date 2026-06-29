# Integrated Farm Management System (IFMS)

IFMS is an offline-first farm management application designed for scaling operations. It enables owners, managers, vets, and farm workers to track records collaboratively.

## Architecture

IFMS consists of two main components:
1. **FastAPI Backend (`/`)**: A Python REST API utilizing SQLAlchemy 2.0 and PostgreSQL (cloud) / SQLite (local dev) to manage central data, role-based authentication, and mobile sync requests.
2. **Flutter Mobile Application (`/mobile`)**: An offline-first mobile app using Drift SQLite cache, BLoC state management, and a custom outbox sync queue (`SyncQueue` & `SyncManager`) to keep devices updated seamlessly.

## Getting Started

### Backend Setup (Local Dev)
1. Initialize virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Set environment variables in a local `.env` file:
   ```env
   DATABASE_URL=sqlite:///./ifms.db
   SECRET_KEY=dev_secret_key_change_in_production_9a8b7c6d5e
   ACCESS_TOKEN_EXPIRE_MINUTES=1440
   REFRESH_TOKEN_EXPIRE_DAYS=7
   ```
4. Run migrations:
   ```bash
   alembic upgrade head
   ```
5. Run server:
   ```bash
   uvicorn app.main:app --reload
   ```

### Mobile App Setup
1. Install [Puro](https://puro.dev) or the standard Flutter SDK.
2. Fetch dependencies:
   ```bash
   cd mobile
   puro flutter pub get
   ```
3. Compile schema code generation:
   ```bash
   puro flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run app:
   ```bash
   puro flutter run
   ```

## Cloud Deployment Overview

* **Database**: PostgreSQL (e.g. Supabase, Neon)
* **Backend API**: Hosted on Render or Railway
* **Device Synchronization**: SQLite on device handles edits offline, replaying requests via `SyncManager` to the cloud backend when connection is active.
