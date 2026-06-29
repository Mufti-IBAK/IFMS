from uuid import UUID
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

class MilkRecordCreate(BaseModel):
    animal_id: UUID
    record_date: date
    milking_session: str = Field(..., pattern="^(morning|evening|total_day)$")
    quantity_liters: float = Field(..., gt=0.0)
    fat_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    protein_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)

class MilkRecordResponse(MilkRecordCreate):
    id: UUID
    is_withdrawn: bool
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class LactationResponse(BaseModel):
    id: UUID
    animal_id: UUID
    start_date: date
    end_date: Optional[date]
    lactation_number: int
    status: str

    class Config:
        from_attributes = True
