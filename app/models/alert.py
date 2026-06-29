from sqlalchemy import Column, DateTime, String, ForeignKey, Index
from app.models.base import BaseModel, GUID

class Alert(BaseModel):
    __tablename__ = "alerts"
    __table_args__ = (
        Index('ix_alerts_entity_lookup', 'entity_type', 'entity_id', 'alert_type', 'status'),
    )
    
    entity_type = Column(String(50), nullable=False, index=True) # "animal", "poultry_batch", "hatchery_batch", "finance"
    entity_id = Column(GUID(), nullable=True, index=True)
    
    alert_type = Column(String(50), nullable=False, index=True) # "health_alert", "production_alert", "reproduction_alert", "financial_alert", "system_alert"
    severity = Column(String(20), nullable=False, index=True) # "low", "medium", "high", "critical"
    message = Column(String(255), nullable=False)
    status = Column(String(20), nullable=False, default="open", index=True) # "open", "acknowledged", "resolved"
    resolved_at = Column(DateTime, nullable=True)
