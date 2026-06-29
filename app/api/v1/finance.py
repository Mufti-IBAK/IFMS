from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.finance import TransactionCreate, TransactionResponse
from app.services import finance_service

router = APIRouter()

@router.post("/transaction", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def create_transaction_endpoint(
    txn_in: TransactionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.create_transaction(db, txn_in, current_user.id)

@router.get("/transactions", response_model=List[TransactionResponse])
def get_transactions_endpoint(
    transaction_type: Optional[str] = Query(None, pattern="^(income|expense)$"),
    category: Optional[str] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.get_transactions(db, transaction_type, category, start_date, end_date)

@router.get("/profit/farm")
def get_overall_farm_profit_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.get_overall_farm_profit(db)

@router.get("/profit/animal/{id}")
def get_animal_financial_summary_endpoint(
    id: UUID,
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.get_animal_financial_summary(db, id, reference_date)

@router.get("/culling-analysis")
def get_culling_recommendations_endpoint(
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.get_culling_recommendations(db, reference_date)

@router.patch("/transactions/{id}/reconcile")
def reconcile_transaction_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.reconcile_transaction(db, id, current_user.id)

@router.post("/transactions/{id}/reverse", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def reverse_transaction_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return finance_service.reverse_transaction(db, id, current_user.id)
