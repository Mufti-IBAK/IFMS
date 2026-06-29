from sqlalchemy import Column, String, Float, Date, ForeignKey, Index
from app.models.base import BaseModel, GUID

class InventoryLog(BaseModel):
    __tablename__ = "inventory_logs"
    __table_args__ = (
        Index('ix_inventory_logs_item_date', 'item_id', 'log_date'),
    )
    
    item_id = Column(GUID(), ForeignKey("feed_items.id", ondelete="CASCADE"), nullable=False, index=True)
    change_type = Column(String(30), nullable=False)  # "purchase", "consumption", "adjustment", "waste", "return"
    quantity_change = Column(Float, nullable=False)  # positive for additions, negative for consumption/waste
    balance_after = Column(Float, nullable=False)
    related_entity_type = Column(String(50), nullable=True)  # "animal", "poultry_batch"
    related_entity_id = Column(GUID(), nullable=True)
    notes = Column(String(255), nullable=True)
    log_date = Column(Date, nullable=False, index=True)
    logged_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
