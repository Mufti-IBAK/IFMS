from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.hatchery import HatcheryBatchCreate, HatcheryBatchResponse, HatcheryEventCreate, HatcheryEventResponse
from app.services import hatchery_service

router = APIRouter()

@router.post("/batch", response_model=HatcheryBatchResponse, status_code=status.HTTP_201_CREATED)
def create_hatchery_batch_endpoint(
    batch_in: HatcheryBatchCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.create_hatchery_batch(db, batch_in, current_user.id)

@router.get("/batch/{id}", response_model=HatcheryBatchResponse)
def get_hatchery_batch_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.get_hatchery_batch(db, id)

@router.post("/batch/{id}/event", response_model=HatcheryEventResponse, status_code=status.HTTP_201_CREATED)
def create_hatchery_event_endpoint(
    id: UUID,
    event_in: HatcheryEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.create_hatchery_event(db, id, event_in, current_user.id)

@router.get("/batch/{id}/kpi")
def get_hatchery_kpi_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.get_hatchery_batch_kpi(db, id)

@router.get("/profit/summary")
def get_hatchery_profit_summary_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.get_hatchery_profitability_summary(db)

@router.get("/batches", response_model=List[HatcheryBatchResponse])
def get_hatchery_batches_endpoint(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return hatchery_service.get_hatchery_batches(db, status)
