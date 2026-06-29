from fastapi import APIRouter, Depends, UploadFile, File
from fastapi.responses import PlainTextResponse
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.services import import_service

router = APIRouter()

@router.post("/animals")
async def import_animals_endpoint(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    content = await file.read()
    file_content = content.decode("utf-8-sig")  # Handle BOM from Excel
    return import_service.import_animals_from_csv(db, file_content, current_user.id)

@router.post("/transactions")
async def import_transactions_endpoint(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    content = await file.read()
    file_content = content.decode("utf-8-sig")
    return import_service.import_transactions_from_csv(db, file_content, current_user.id)

@router.get("/templates/animals", response_class=PlainTextResponse)
def get_animal_template(
    current_user: User = Depends(get_current_active_user)
):
    return import_service.get_animal_csv_template()

@router.get("/templates/transactions", response_class=PlainTextResponse)
def get_transaction_template(
    current_user: User = Depends(get_current_active_user)
):
    return import_service.get_transaction_csv_template()
