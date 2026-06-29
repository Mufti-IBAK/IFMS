from sqlalchemy import Column, Date, String, ForeignKey, Index
from app.models.base import BaseModel, GUID
from app.core.database import Base

class BreedingEvent(BaseModel):
    __tablename__ = "breeding_events"
    __table_args__ = (
        Index('ix_breeding_events_composite', 'animal_id', 'event_type', 'event_date'),
    )
    
    animal_id = Column(GUID(), ForeignKey("animals.id", ondelete="CASCADE"), nullable=False, index=True)
    event_type = Column(String(50), nullable=False, index=True) # "heat", "mating", "ai_insemination", "pregnancy_check", "confirmed_pregnant", "abortion", "calving"
    event_date = Column(Date, nullable=False, index=True)
    result = Column(String(50), nullable=True) # e.g. "pregnant", "open", "normal", "dystocia"
    notes = Column(String(255), nullable=True)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
