@echo off
echo ===================================================
echo   FARM BRAIN CORE - SYSTEM LAUNCH PROTOCOL
echo ===================================================

:: 1. Start Backend in a new window
echo [1/3] Syncing Dependencies and Starting FastAPI Backend...
start "IFMS Backend" cmd /k ".\venv\Scripts\activate && pip install -r requirements.txt && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

:: 2. Wait for backend to stabilize
timeout /t 5

:: 3. Seed data (Optional, will only add if DB is empty)
echo [2/3] Seeding Initial Data...
.\venv\Scripts\activate && python seed_data.py

:: 4. Start Mobile App in a new window
echo [3/3] Starting Flutter Mobile App...
cd mobile
start "IFMS Mobile" cmd /k "flutter run"

echo ===================================================
echo System launch initiated. Check separate windows.
echo ===================================================
pause
