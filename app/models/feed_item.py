from sqlalchemy import Column, String, Float, Boolean, ForeignKey, Index
from app.models.base import BaseModel, GUID

class FeedItem(BaseModel):
    __tablename__ = "feed_items"
    __table_args__ = (
        Index('ix_feed_items_category', 'category'),
    )
    
    name = Column(String(100), nullable=False, unique=True)
    category = Column(String(50), nullable=False)  # "feed", "drug", "vaccine", "supplement", "supply"
    unit = Column(String(20), nullable=False)  # "kg", "liters", "bottles", "doses", "bags"
    current_stock = Column(Float, nullable=False, default=0.0)
    reorder_threshold = Column(Float, nullable=False, default=10.0)
    cost_per_unit = Column(Float, nullable=False, default=0.0)
    currency = Column(String(10), nullable=False, default="NGN")
    supplier = Column(String(100), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
