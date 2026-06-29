from sqlalchemy import Column, String, Boolean, JSON
from app.models.base import BaseModel

class Rule(BaseModel):
    __tablename__ = "rules"
    
    name = Column(String(100), nullable=False)
    entity_type = Column(String(50), nullable=False) # "animal", "poultry_batch", "hatchery_batch", "finance"
    condition_json = Column(JSON, nullable=True)
    severity = Column(String(20), nullable=False, default="medium") # "low", "medium", "high", "critical"
    action_type = Column(String(20), nullable=False, default="alert") # "alert", "recommend"
    active = Column(Boolean, nullable=False, default=True)
