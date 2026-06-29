from uuid import UUID
from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field

class RuleCreate(BaseModel):
    name: str
    entity_type: str = Field(..., pattern="^(animal|poultry_batch|hatchery_batch|finance)$")
    condition_json: Optional[Dict[str, Any]] = None
    severity: str = Field("medium", pattern="^(low|medium|high|critical)$")
    action_type: str = Field("alert", pattern="^(alert|recommend)$")
    active: bool = True

class RuleResponse(RuleCreate):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class AlertResponse(BaseModel):
    id: UUID
    entity_type: str
    entity_id: Optional[UUID] = None
    alert_type: str
    severity: str
    message: str
    status: str
    resolved_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True
