from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.task import TaskCreate, TaskResponse, TaskStatusUpdate
from app.services import task_service

router = APIRouter()

@router.post("", response_model=TaskResponse, status_code=201)
def create_task_endpoint(
    task_in: TaskCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.create_task(db, task_in, current_user.id)

@router.get("", response_model=List[TaskResponse])
def get_tasks_endpoint(
    assigned_to: Optional[UUID] = None,
    status: Optional[str] = Query(None, pattern="^(pending|in_progress|completed|overdue|cancelled)$"),
    priority: Optional[str] = Query(None, pattern="^(low|medium|high|urgent)$"),
    overdue_only: bool = False,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.get_tasks(db, assigned_to, status, priority, overdue_only)

@router.get("/my-tasks", response_model=List[TaskResponse])
def get_my_tasks_endpoint(
    status: Optional[str] = Query(None, pattern="^(pending|in_progress|completed|overdue|cancelled)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.get_tasks(db, assigned_to=current_user.id, status_filter=status)

@router.get("/summary")
def get_task_summary_endpoint(
    assigned_to: Optional[UUID] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.get_task_summary(db, assigned_to)

@router.get("/{id}", response_model=TaskResponse)
def get_task_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.get_task(db, id)

@router.patch("/{id}/status", response_model=TaskResponse)
def update_task_status_endpoint(
    id: UUID,
    status_update: TaskStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return task_service.update_task_status(db, id, status_update)

@router.post("/mark-overdue")
def mark_overdue_tasks_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    count = task_service.mark_overdue_tasks(db)
    return {"message": f"{count} tasks marked as overdue."}
