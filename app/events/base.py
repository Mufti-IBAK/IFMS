from sqlalchemy import Column, String, JSON
from app.models.base import BaseModel

class Event(BaseModel):
    __tablename__ = "events"
    
    entity_type = Column(String(50), nullable=False) # e.g. "animal", "batch"
    entity_id = Column(String(50), nullable=False)   # UUID string reference
    event_type = Column(String(50), nullable=False)  # e.g. "milk_record", "disease_diagnosis"
    payload = Column(JSON, nullable=False)           # JSON payload detailing event data
