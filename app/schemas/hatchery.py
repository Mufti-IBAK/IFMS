from uuid import UUID
from datetime import date, datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field

class HatcheryBatchCreate(BaseModel):
    egg_source: str
    egg_count: int = Field(..., gt=0)
    breed: Optional[str] = None
    set_date: date
    initial_egg_cost: float = Field(0.0, ge=0.0)

class HatcheryBatchResponse(BaseModel):
    id: UUID
    egg_source: str
    egg_count: int
    breed: Optional[str]
    set_date: date
    expected_hatch_date: date
    fertile_eggs: Optional[int]
    hatched_chicks: Optional[int]
    failed_eggs: Optional[int]
    initial_egg_cost: float
    status: str
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class HatcheryEventCreate(BaseModel):
    event_type: str = Field(..., pattern="^(candling|temperature_check|humidity_check|turning|hatch_start|hatch_complete)$")
    event_date: date
    value_json: Optional[Dict[str, Any]] = None

class HatcheryEventResponse(HatcheryEventCreate):
    id: UUID
    batch_id: UUID
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True
