from sqlalchemy import Column, Date, String, ForeignKey, JSON
from app.models.base import BaseModel, GUID
from app.core.database import Base

class HatcheryEvent(BaseModel):
    __tablename__ = "hatchery_events"
    
    batch_id = Column(GUID(), ForeignKey("hatchery_batches.id", ondelete="CASCADE"), nullable=False, index=True)
    event_type = Column(String(50), nullable=False, index=True) # "candling", "temperature_check", "humidity_check", "turning", "hatch_start", "hatch_complete"
    event_date = Column(Date, nullable=False, index=True)
    value_json = Column(JSON, nullable=True) # Candling counts, hatched chick counts, temperature readings
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
