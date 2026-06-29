from sqlalchemy import Column, Date, Float, String, Boolean, ForeignKey, Index
from app.models.base import BaseModel, GUID
from app.core.database import Base

class Transaction(BaseModel):
    __tablename__ = "transactions"
    __table_args__ = (
        Index('ix_transactions_entity_date', 'related_entity_type', 'related_entity_id', 'transaction_date'),
    )
    
    transaction_type = Column(String(20), nullable=False) # "income", "expense"
    category = Column(String(50), nullable=False) # "milk_sales", "animal_sales", "poultry_sales", "hatchery_sales", "feed", "medication", "labor", "equipment", "utilities", "misc"
    amount = Column(Float, nullable=False)
    currency = Column(String(10), nullable=False, default="NGN")
    
    related_entity_type = Column(String(50), nullable=True) # "animal", "poultry_batch", "hatchery_batch"
    related_entity_id = Column(GUID(), nullable=True)
    
    description = Column(String(255), nullable=True)
    transaction_date = Column(Date, nullable=False, index=True)
    created_by = Column(GUID(), ForeignKey("users.id"), nullable=False)
    
    # Audit trail fields
    is_reconciled = Column(Boolean, default=False, nullable=False)
    approved_by = Column(GUID(), ForeignKey("users.id"), nullable=True)
    reversal_of = Column(GUID(), nullable=True)  # Links reversal entries to the original transaction
