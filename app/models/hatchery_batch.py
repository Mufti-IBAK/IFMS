from sqlalchemy import Column, Date, Integer, String, Float, ForeignKey
from app.models.base import BaseModel, GUID
from app.core.database import Base

class HatcheryBatch(BaseModel):
    __tablename__ = "hatchery_batches"
    
    egg_source = Column(String(100), nullable=False) # e.g. "farm-house-1" or "supplier-name"
    egg_count = Column(Integer, nullable=False)
    breed = Column(String(100), nullable=True)
    set_date = Column(Date, nullable=False)
    expected_hatch_date = Column(Date, nullable=False)
    fertile_eggs = Column(Integer, nullable=True) # filled during candling event
    hatched_chicks = Column(Integer, nullable=True) # filled during hatch_complete event
    failed_eggs = Column(Integer, nullable=True)
    initial_egg_cost = Column(Float, nullable=False, default=0.0)
    status = Column(String(20), nullable=False, default="incubating") # "incubating", "completed"
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
