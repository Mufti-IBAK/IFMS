from uuid import UUID
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

class FeedItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    category: str = Field(..., pattern="^(feed|drug|vaccine|supplement|supply)$")
    unit: str = Field(..., min_length=1, max_length=20)
    current_stock: float = Field(0.0, ge=0.0)
    reorder_threshold: float = Field(10.0, ge=0.0)
    cost_per_unit: float = Field(0.0, ge=0.0)
    supplier: Optional[str] = None

class FeedItemResponse(FeedItemCreate):
    id: UUID
    currency: str
    is_active: bool
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class FeedItemUpdate(BaseModel):
    name: Optional[str] = None
    current_stock: Optional[float] = None
    reorder_threshold: Optional[float] = None
    cost_per_unit: Optional[float] = None
    supplier: Optional[str] = None
    is_active: Optional[bool] = None

class InventoryLogCreate(BaseModel):
    item_id: UUID
    change_type: str = Field(..., pattern="^(purchase|consumption|adjustment|waste|return)$")
    quantity_change: float
    related_entity_type: Optional[str] = Field(None, pattern="^(animal|poultry_batch)$")
    related_entity_id: Optional[UUID] = None
    notes: Optional[str] = None
    log_date: date

class InventoryLogResponse(InventoryLogCreate):
    id: UUID
    balance_after: float
    logged_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True
