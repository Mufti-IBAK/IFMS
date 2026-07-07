from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.breeding_event import BreedingEvent
from app.schemas.breeding_event import BreedingEventCreate, BreedingEventResponse
# If auth is required:
# from app.services.auth_service import get_current_active_user
# from app.models.user import User

router = APIRouter()

@router.post("", response_model=BreedingEventResponse, status_code=status.HTTP_201_CREATED)
def create_breeding_event(
    event_in: BreedingEventCreate,
    db: Session = Depends(get_db),
    # current_user: User = Depends(get_current_active_user)
):
    db_event = BreedingEvent(
        id=event_in.id,
        animal_id=event_in.animal_id,
        event_type=event_in.event_type,
        event_date=event_in.event_date,
        sire_id=event_in.sire_id,
        semen_batch_id=event_in.semen_batch_id,
        technician=event_in.technician,
        result=event_in.result,
        notes=event_in.notes,
        # created_by=current_user.id
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

@router.get("", response_model=List[BreedingEventResponse])
def get_breeding_events(
    animal_id: str = None,
    db: Session = Depends(get_db),
    # current_user: User = Depends(get_current_active_user)
):
    query = db.query(BreedingEvent)
    if animal_id:
        query = query.filter(BreedingEvent.animal_id == animal_id)
    return query.all()
