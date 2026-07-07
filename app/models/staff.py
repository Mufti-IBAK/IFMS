from sqlalchemy import Column, String, Float, Boolean
from app.models.base import BaseModel

class Staff(BaseModel):
    __tablename__ = "staff"
    
    name = Column(String(100), nullable=False)
    role = Column(String(50), nullable=False)
    phone = Column(String(20), nullable=True)
    base_salary = Column(Float, nullable=False, default=0.0)
    performance_rating = Column(Float, nullable=False, default=5.0) # 1.0 to 5.0
    is_active = Column(Boolean, default=True)
    
    # Biodata & Demographics
    profile_pic = Column(String(255), nullable=True)
    gender = Column(String(20), nullable=True)
    date_of_birth = Column(String(50), nullable=True) # ISO Date string or Date
    address = Column(String(255), nullable=True)
    emergency_contact = Column(String(255), nullable=True)
    employment_type = Column(String(50), nullable=True) # Full-time, Part-time, Contract
