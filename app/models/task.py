from sqlalchemy import Column, String, Date, DateTime, ForeignKey, Index, Text
from app.models.base import BaseModel, GUID

class Task(BaseModel):
    __tablename__ = "tasks"
    __table_args__ = (
        Index('ix_tasks_assigned_status', 'assigned_to', 'status'),
        Index('ix_tasks_due_date', 'due_date', 'status'),
    )
    
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    priority = Column(String(20), nullable=False, default="medium")  # "low", "medium", "high", "urgent"
    status = Column(String(20), nullable=False, default="pending", index=True)  # "pending", "in_progress", "completed", "overdue", "cancelled"
    
    assigned_to = Column(GUID(), ForeignKey("users.id"), nullable=True, index=True)
    assigned_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
    
    due_date = Column(Date, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    
    related_entity_type = Column(String(50), nullable=True)  # "animal", "poultry_batch", "hatchery_batch", "feed_item"
    related_entity_id = Column(GUID(), nullable=True)
    
    source_alert_id = Column(GUID(), ForeignKey("alerts.id"), nullable=True)  # Auto-generated from alert
