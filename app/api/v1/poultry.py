from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.models.poultry_batch import PoultryBatch
from app.schemas.poultry import PoultryBatchCreate, PoultryBatchResponse, PoultryEventCreate, PoultryEventResponse, PoultryDailyLogCreate
from app.services import poultry_service

router = APIRouter()

@router.post("/batch", response_model=PoultryBatchResponse, status_code=status.HTTP_201_CREATED)
def create_poultry_batch_endpoint(
    batch_in: PoultryBatchCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.create_poultry_batch(db, batch_in, current_user.id)

@router.get("/batch/{id}", response_model=PoultryBatchResponse)
def get_poultry_batch_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.get_poultry_batch(db, id)

@router.post("/batch/{id}/event", response_model=PoultryEventResponse, status_code=status.HTTP_201_CREATED)
def create_poultry_event_endpoint(
    id: UUID,
    event_in: PoultryEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.create_poultry_event(db, id, event_in, current_user.id)

@router.get("/batch/{id}/kpi")
def get_poultry_kpi_endpoint(
    id: UUID,
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.get_poultry_batch_kpi(db, id, reference_date)

@router.get("/profit/summary")
def get_poultry_profit_summary_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.get_poultry_profitability_summary(db)

@router.get("/batches", response_model=List[PoultryBatchResponse])
def get_poultry_batches_endpoint(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    query = db.query(PoultryBatch)
    if status:
        query = query.filter(PoultryBatch.status == status)
    return query.order_by(PoultryBatch.start_date.desc()).all()

@router.post("/batch/{id}/logs")
def create_poultry_daily_log_endpoint(
    id: UUID,
    log_in: PoultryDailyLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return poultry_service.process_poultry_daily_log(db, id, log_in, current_user.id)
