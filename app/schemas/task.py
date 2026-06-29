from uuid import UUID
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, Field

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    priority: str = Field("medium", pattern="^(low|medium|high|urgent)$")
    assigned_to: Optional[UUID] = None
    due_date: Optional[date] = None
    related_entity_type: Optional[str] = Field(None, pattern="^(animal|poultry_batch|hatchery_batch|feed_item)$")
    related_entity_id: Optional[UUID] = None

class TaskResponse(TaskCreate):
    id: UUID
    status: str
    assigned_by: UUID
    completed_at: Optional[datetime] = None
    source_alert_id: Optional[UUID] = None
    created_at: datetime

    class Config:
        from_attributes = True

class TaskStatusUpdate(BaseModel):
    status: str = Field(..., pattern="^(in_progress|completed|cancelled)$")
