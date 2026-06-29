from uuid import UUID
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

class TransactionCreate(BaseModel):
    transaction_type: str = Field(..., pattern="^(income|expense)$")
    category: str = Field(..., pattern="^(milk_sales|animal_sales|poultry_sales|hatchery_sales|feed|medication|labor|equipment|utilities|misc)$")
    amount: float = Field(..., gt=0.0)
    related_entity_type: Optional[str] = Field(None, pattern="^(animal|poultry_batch|hatchery_batch)$")
    related_entity_id: Optional[UUID] = None
    description: Optional[str] = None
    transaction_date: date

class TransactionResponse(TransactionCreate):
    id: UUID
    currency: str
    created_by: UUID
    created_at: datetime
    is_reconciled: bool = False
    approved_by: Optional[UUID] = None
    reversal_of: Optional[UUID] = None

    class Config:
        from_attributes = True
