from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel

class BreedingEventCreate(BaseModel):
    id: Optional[UUID] = None
    animal_id: str
    event_type: str
    event_date: datetime
    sire_id: Optional[str] = None
    semen_batch_id: Optional[str] = None
    technician: Optional[str] = None
    result: Optional[str] = None
    notes: Optional[str] = None

class BreedingEventResponse(BreedingEventCreate):
    id: UUID
    created_by: Optional[UUID] = None

    class Config:
        from_attributes = True
