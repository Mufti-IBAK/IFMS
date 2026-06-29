from sqlalchemy import Column, Date, Float, String, Boolean, ForeignKey, Index
from app.models.base import BaseModel, GUID
from app.core.database import Base

class MilkRecord(BaseModel):
    __tablename__ = "milk_records"
    __table_args__ = (
        Index('ix_milk_records_composite', 'animal_id', 'record_date'),
    )
    
    animal_id = Column(GUID(), ForeignKey("animals.id", ondelete="CASCADE"), nullable=False, index=True)
    record_date = Column(Date, nullable=False, index=True)
    milking_session = Column(String(20), nullable=False) # "morning", "evening", "total_day"
    quantity_liters = Column(Float, nullable=False)
    fat_percentage = Column(Float, nullable=True)
    protein_percentage = Column(Float, nullable=True)
    is_withdrawn = Column(Boolean, default=False, nullable=False) # True if active drug withdrawal exists
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
