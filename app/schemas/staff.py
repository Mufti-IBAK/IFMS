from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime, date
from typing import Optional, List

class StaffQueryBase(BaseModel):
    title: str
    description: Optional[str] = None
    deduction_amount: float = 0.0
    issue_date: date

class StaffQueryCreate(StaffQueryBase):
    staff_id: UUID

class StaffQueryResolve(BaseModel):
    resolution_notes: str

class StaffQueryResponse(StaffQueryBase):
    id: UUID
    staff_id: UUID
    is_resolved: bool
    resolution_notes: Optional[str] = None
    resolved_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class StaffBase(BaseModel):
    name: str
    role: str
    phone: Optional[str] = None
    base_salary: float = 0.0
    performance_rating: float = 5.0

class StaffCreate(StaffBase):
    pass

class StaffUpdate(BaseModel):
    name: Optional[str] = None
    role: Optional[str] = None
    phone: Optional[str] = None
    base_salary: Optional[float] = None
    performance_rating: Optional[float] = None
    is_active: Optional[bool] = None

class StaffResponse(StaffBase):
    id: UUID
    is_active: bool
    final_payout: float = 0.0
    active_queries_count: int = 0
    total_deductions: float = 0.0

    model_config = ConfigDict(from_attributes=True)

class BudgetSummary(BaseModel):
    total_base_salary: float
    total_active_deductions: float
    net_salary_budget: float
    staff_count: int
    active_queries_count: int
