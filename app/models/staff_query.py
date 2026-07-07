from sqlalchemy import Column, String, Float, Boolean, Text, DateTime, Date, ForeignKey
from app.models.base import BaseModel, GUID
from sqlalchemy.orm import relationship

class StaffQuery(BaseModel):
    __tablename__ = "staff_queries"
    
    staff_id = Column(GUID(), ForeignKey("staff.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    deduction_amount = Column(Float, nullable=False, default=0.0)
    is_resolved = Column(Boolean, default=False)
    resolution_notes = Column(Text, nullable=True)
    resolved_at = Column(DateTime, nullable=True)
    issue_date = Column(Date, nullable=False)

    staff = relationship("Staff", backref="queries")
