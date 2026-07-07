from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from uuid import UUID

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.models.breeding_event import BreedingEvent
from app.schemas.breeding import BreedingEventCreate, BreedingEventResponse
from app.services import breeding_service

router = APIRouter()

@router.post("/event", response_model=BreedingEventResponse, status_code=status.HTTP_201_CREATED)
def create_breeding_event(
    event_in: BreedingEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.create_breeding_event(db, event_in, current_user.id)

@router.get("/event", response_model=List[BreedingEventResponse])
def get_breeding_events(
    animal_id: Optional[UUID] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    if animal_id:
        return breeding_service.get_animal_breeding_timeline(db, animal_id)
    return db.query(BreedingEvent).all()

@router.get("/calendar")
def get_breeding_calendar(
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_calendar(db, reference_date)

@router.get("/kpi/herd")
def get_breeding_kpi_herd(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_kpi_herd(db)

@router.get("/kpi/animal/{animal_id}")
def get_breeding_kpi_animal(
    animal_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return breeding_service.get_breeding_kpi_animal(db, animal_id)
