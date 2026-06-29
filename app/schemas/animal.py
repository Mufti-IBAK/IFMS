from uuid import UUID
from datetime import date, datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field
from app.models.animal import AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.models.animal_event import EventCategory

class AnimalBase(BaseModel):
    tag_id: str = Field(..., min_length=2, max_length=50)
    species: AnimalSpecies
    breed: Optional[str] = None
    sex: str = Field(..., pattern="^(male|female)$")
    date_of_birth: date
    date_of_acquisition: Optional[date] = None
    sire_id: Optional[UUID] = None
    dam_id: Optional[UUID] = None
    genetic_line: Optional[str] = None
    acquisition_cost: float = Field(0.0, ge=0.0)
    salvage_value: float = Field(0.0, ge=0.0)
    
    # New fields for comprehensive logging
    weight: Optional[float] = Field(None, ge=0.0)
    color: Optional[str] = None
    unique_marks: Optional[str] = None
    pedigree_type: Optional[str] = None
    purpose: Optional[str] = None
    vaccination_status: Optional[str] = None
    deworming_status: Optional[str] = None

class AnimalCreate(AnimalBase):
    pass

class AnimalUpdate(BaseModel):
    tag_id: Optional[str] = None
    breed: Optional[str] = None
    status: Optional[AnimalStatus] = None
    current_location_id: Optional[str] = None
    sire_id: Optional[UUID] = None
    dam_id: Optional[UUID] = None
    genetic_line: Optional[str] = None
    current_reproductive_status: Optional[ReproductiveStatus] = None
    acquisition_cost: Optional[float] = Field(None, ge=0.0)
    salvage_value: Optional[float] = Field(None, ge=0.0)
    
    # New updateable fields
    weight: Optional[float] = Field(None, ge=0.0)
    color: Optional[str] = None
    unique_marks: Optional[str] = None
    pedigree_type: Optional[str] = None
    purpose: Optional[str] = None
    vaccination_status: Optional[str] = None
    deworming_status: Optional[str] = None

class AnimalResponse(AnimalBase):
    id: UUID
    status: AnimalStatus
    current_reproductive_status: ReproductiveStatus
    current_location_id: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class AnimalEventCreate(BaseModel):
    event_type: str = Field(..., min_length=2)
    event_category: EventCategory
    event_timestamp: datetime
    payload: Dict[str, Any] = Field(default_factory=dict)

class AnimalEventResponse(BaseModel):
    id: UUID
    animal_id: UUID
    event_type: str
    event_category: EventCategory
    event_timestamp: datetime
    payload: Dict[str, Any]
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True
