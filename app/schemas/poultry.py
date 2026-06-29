from uuid import UUID
from datetime import date, datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field

class PoultryBatchCreate(BaseModel):
    batch_type: str = Field("broiler", pattern="^(broiler)$")
    breed: Optional[str] = None
    start_date: date
    initial_count: int = Field(..., gt=0)
    location_id: Optional[str] = None
    initial_chick_cost: float = Field(0.0, ge=0.0)

class PoultryBatchResponse(BaseModel):
    id: UUID
    batch_type: str
    breed: Optional[str]
    start_date: date
    end_date: Optional[date]
    initial_count: int
    current_count: int
    status: str
    location_id: Optional[str]
    initial_chick_cost: float
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class PoultryEventCreate(BaseModel):
    event_type: str = Field(..., pattern="^(feed|mortality|vaccination|weight_sample|sale|transfer)$")
    event_date: date
    quantity: float = Field(..., ge=0.0)
    value_json: Optional[Dict[str, Any]] = None

class PoultryEventResponse(PoultryEventCreate):
    id: UUID
    batch_id: UUID
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True
