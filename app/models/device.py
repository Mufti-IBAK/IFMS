from sqlalchemy import Column, String, ForeignKey
from app.models.base import BaseModel, GUID

class DeviceToken(BaseModel):
    __tablename__ = "device_tokens"

    user_id = Column(GUID(), ForeignKey("users.id"), nullable=False)
    fcm_token = Column(String(255), unique=True, index=True, nullable=False)
    device_type = Column(String(50), nullable=True) # "android", "ios"
