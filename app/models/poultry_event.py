from sqlalchemy import Column, Date, Float, String, ForeignKey, JSON
from app.models.base import BaseModel, GUID
from app.core.database import Base

class PoultryEvent(BaseModel):
    __tablename__ = "poultry_events"
    
    batch_id = Column(GUID(), ForeignKey("poultry_batches.id", ondelete="CASCADE"), nullable=False, index=True)
    event_type = Column(String(50), nullable=False, index=True) # "feed", "mortality", "vaccination", "weight_sample", "sale", "transfer"
    event_date = Column(Date, nullable=False, index=True)
    quantity = Column(Float, nullable=False) # feed weight kg, dead count, sold count, etc.
    value_json = Column(JSON, nullable=True) # Dynamic prices, average weights, medication names
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
