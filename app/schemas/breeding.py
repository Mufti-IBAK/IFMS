from uuid import UUID
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

class BreedingEventCreate(BaseModel):
    animal_id: UUID
    event_type: str = Field(..., pattern="^(heat|mating|ai_insemination|pregnancy_check|confirmed_pregnant|abortion|calving)$")
    event_date: date
    result: Optional[str] = None
    notes: Optional[str] = None

class BreedingEventResponse(BreedingEventCreate):
    id: UUID
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True
