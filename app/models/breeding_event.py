from sqlalchemy import Column, DateTime, String, ForeignKey, Index
from app.models.base import BaseModel, GUID
from app.core.database import Base

class BreedingEvent(BaseModel):
    __tablename__ = "breeding_events"
    __table_args__ = (
        Index('ix_breeding_events_composite', 'animal_id', 'event_type', 'event_date'),
    )
    
    animal_id = Column(GUID(), ForeignKey("animals.id", ondelete="CASCADE"), nullable=False, index=True)
    event_type = Column(String(50), nullable=False, index=True) 
    event_date = Column(DateTime, nullable=False, index=True)
    sire_id = Column(String(50), nullable=True)
    semen_batch_id = Column(String(100), nullable=True)
    technician = Column(String(100), nullable=True)
    result = Column(String(50), nullable=True) 
    notes = Column(String(255), nullable=True)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=True) # Make nullable=True for offline sync if user isn't passed

