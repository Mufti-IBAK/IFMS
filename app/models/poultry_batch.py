from sqlalchemy import Column, Date, Integer, String, Float, ForeignKey
from app.models.base import BaseModel, GUID
from app.core.database import Base

class PoultryBatch(BaseModel):
    __tablename__ = "poultry_batches"
    
    batch_type = Column(String(50), nullable=False) # e.g. "broiler"
    breed = Column(String(100), nullable=True)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    initial_count = Column(Integer, nullable=False)
    current_count = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, default="active") # "active", "closed"
    location_id = Column(String(50), nullable=True)
    initial_chick_cost = Column(Float, nullable=False, default=0.0)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
