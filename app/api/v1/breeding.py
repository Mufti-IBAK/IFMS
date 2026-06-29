from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional, Dict, Any

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.breeding import BreedingEventCreate, BreedingEventResponse
from app.services import breeding_service

router = APIRouter()

@router.post("/event", response_model=BreedingEventResponse, status_code=status.HTTP_201_CREATED)
def create_breeding_event_endpoint(
    event_in: BreedingEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.create_breeding_event(db, event_in, current_user.id)

@router.get("/calendar")
def get_breeding_calendar_endpoint(
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_calendar(db, reference_date)

@router.get("/kpi/herd")
def get_herd_kpi_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_kpi_herd(db)

@router.get("/kpi/animal/{id}")
def get_animal_kpi_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_kpi_animal(db, id)

@router.get("/{animal_id}", response_model=List[BreedingEventResponse])
def get_animal_breeding_timeline_endpoint(
    animal_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_animal_breeding_timeline(db, animal_id)
