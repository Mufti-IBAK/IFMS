from sqlalchemy.orm import Session
from uuid import UUID
from datetime import datetime, date
from typing import List, Optional, Dict, Any
from fastapi import HTTPException, status
from app.models.staff import Staff
from app.models.staff_query import StaffQuery
from app.schemas.staff import StaffCreate, StaffUpdate, StaffQueryCreate, StaffQueryResolve, BudgetSummary

def get_staff(db: Session, staff_id: UUID) -> Optional[Staff]:
    return db.query(Staff).filter(Staff.id == staff_id).first()

def list_staff(db: Session, skip: int = 0, limit: int = 100) -> List[Dict[str, Any]]:
    staff_members = db.query(Staff).offset(skip).limit(limit).all()
    results = []
    for s in staff_members:
        # Calculate payout
        active_queries = db.query(StaffQuery).filter(
            StaffQuery.staff_id == s.id,
            StaffQuery.is_resolved == False
        ).all()
        
        total_deductions = sum(q.deduction_amount for q in active_queries)
        final_payout = max(0.0, s.base_salary - total_deductions)
        
        results.append({
            **s.__dict__,
            "final_payout": final_payout,
            "active_queries_count": len(active_queries),
            "total_deductions": total_deductions
        })
    return results

def create_staff(db: Session, staff_in: StaffCreate) -> Staff:
    db_staff = Staff(**staff_in.model_dump())
    db.add(db_staff)
    db.commit()
    db.refresh(db_staff)
    return db_staff

def update_staff(db: Session, staff_id: UUID, staff_in: StaffUpdate) -> Staff:
    db_staff = get_staff(db, staff_id)
    if not db_staff:
        raise HTTPException(status_code=404, detail="Staff not found")
    
    update_data = staff_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_staff, field, value)

    db.commit()
    db.refresh(db_staff)
    return db_staff

def issue_query(db: Session, query_in: StaffQueryCreate) -> StaffQuery:
    staff = get_staff(db, query_in.staff_id)
    if not staff:
        raise HTTPException(status_code=404, detail="Staff member not found")

    db_query = StaffQuery(**query_in.model_dump())
    db.add(db_query)
    db.commit()
    db.refresh(db_query)
    return db_query

def resolve_query(db: Session, query_id: UUID, resolve_in: StaffQueryResolve) -> StaffQuery:
    db_query = db.query(StaffQuery).filter(StaffQuery.id == query_id).first()
    if not db_query:
        raise HTTPException(status_code=404, detail="Query not found")

    db_query.is_resolved = True
    db_query.resolution_notes = resolve_in.resolution_notes
    db_query.resolved_at = datetime.utcnow()

    db.commit()
    db.refresh(db_query)
    return db_query

def get_queries(db: Session, staff_id: Optional[UUID] = None) -> List[StaffQuery]:
    query = db.query(StaffQuery)
    if staff_id:
        query = query.filter(StaffQuery.staff_id == staff_id)
    return query.order_by(StaffQuery.issue_date.desc()).all()

def get_budget_summary(db: Session) -> BudgetSummary:
    active_staff = db.query(Staff).filter(Staff.is_active == True).all()
    total_base = sum(s.base_salary for s in active_staff)
    
    active_queries = db.query(StaffQuery).filter(StaffQuery.is_resolved == False).all()
    total_deductions = sum(q.deduction_amount for q in active_queries)

    return BudgetSummary(
        total_base_salary=total_base,
        total_active_deductions=total_deductions,
        net_salary_budget=total_base - total_deductions,
        staff_count=len(active_staff),
        active_queries_count=len(active_queries)
    )
