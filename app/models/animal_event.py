from sqlalchemy import Column, String, DateTime, JSON, ForeignKey, Enum as SQLEnum, Index
from app.models.base import BaseModel, GUID
import enum

class EventCategory(str, enum.Enum):
    IDENTITY = "identity"
    HEALTH = "health"
    REPRODUCTION = "reproduction"
    PRODUCTION = "production"
    MANAGEMENT = "management"

class AnimalEvent(BaseModel):
    __tablename__ = "animal_events"
    __table_args__ = (
        Index('ix_animal_events_composite', 'animal_id', 'event_type', 'event_timestamp'),
    )
    
    animal_id = Column(GUID(), ForeignKey("animals.id", ondelete="CASCADE"), nullable=False, index=True)
    event_type = Column(String(50), nullable=False, index=True) # e.g. "mating", "calving", "treatment"
    event_category = Column(SQLEnum(EventCategory, native_enum=False), nullable=False, index=True)
    event_timestamp = Column(DateTime, nullable=False, index=True)
    payload = Column(JSON, nullable=False)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
