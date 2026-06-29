from sqlalchemy import Column, Date, Integer, String, ForeignKey
from app.models.base import BaseModel, GUID
from app.core.database import Base

class Lactation(BaseModel):
    __tablename__ = "lactations"
    
    animal_id = Column(GUID(), ForeignKey("animals.id", ondelete="CASCADE"), nullable=False, index=True)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    lactation_number = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, default="active") # "active", "completed"
