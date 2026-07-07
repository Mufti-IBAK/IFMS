from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.staff import (
    StaffCreate,
    StaffUpdate,
    StaffResponse,
    StaffQueryBase,
    StaffQueryCreate,
    StaffQueryResponse,
    StaffQueryResolve,
    BudgetSummary
)
from app.services import staff_service

router = APIRouter()

@router.post("", response_model=StaffResponse, status_code=status.HTTP_201_CREATED)
def create_staff(
    staff_in: StaffCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.create_staff(db, staff_in)

@router.get("", response_model=List[StaffResponse])
def list_staff(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.list_staff(db, skip=skip, limit=limit)

@router.patch("/{id}", response_model=StaffResponse)
def update_staff(
    id: UUID,
    staff_in: StaffUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.update_staff(db, id, staff_in)

@router.get("/salary-budget", response_model=BudgetSummary)
def get_budget(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.get_budget_summary(db)

@router.post("/{id}/queries", response_model=StaffQueryResponse, status_code=status.HTTP_201_CREATED)
def issue_query(
    id: UUID,
    query_in: StaffQueryBase,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    q_create = StaffQueryCreate(**query_in.model_dump(), staff_id=id)
    return staff_service.issue_query(db, q_create)

@router.get("/queries", response_model=List[StaffQueryResponse])
def list_queries(
    staff_id: Optional[UUID] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.get_queries(db, staff_id)

@router.patch("/queries/{query_id}/resolve", response_model=StaffQueryResponse)
def resolve_query(
    query_id: UUID,
    resolve_in: StaffQueryResolve,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return staff_service.resolve_query(db, query_id, resolve_in)
