from sqlalchemy import Column, String, Boolean, Enum as SQLEnum
from app.models.base import BaseModel
from app.core.roles import UserRole

class User(BaseModel):
    __tablename__ = "users"
    
    name = Column(String(100), nullable=False)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(SQLEnum(UserRole, native_enum=False), nullable=False, default=UserRole.WORKER)
    is_active = Column(Boolean, default=True, nullable=False)
