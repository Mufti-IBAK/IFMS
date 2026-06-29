from datetime import date, datetime
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.task import Task
from app.models.user import User
from app.schemas.task import TaskCreate, TaskStatusUpdate


def create_task(db: Session, task_in: TaskCreate, assigner_id: UUID) -> Task:
    # Validate assigned_to user exists if provided
    if task_in.assigned_to:
        assignee = db.query(User).filter(User.id == task_in.assigned_to).first()
        if not assignee:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Assigned user not found."
            )
    
    db_task = Task(
        title=task_in.title,
        description=task_in.description,
        priority=task_in.priority,
        assigned_to=task_in.assigned_to,
        assigned_by=assigner_id,
        due_date=task_in.due_date,
        related_entity_type=task_in.related_entity_type,
        related_entity_id=task_in.related_entity_id
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task


def get_tasks(
    db: Session,
    assigned_to: Optional[UUID] = None,
    status_filter: Optional[str] = None,
    priority: Optional[str] = None,
    overdue_only: bool = False
) -> List[Task]:
    query = db.query(Task)
    if assigned_to:
        query = query.filter(Task.assigned_to == assigned_to)
    if status_filter:
        query = query.filter(Task.status == status_filter)
    if priority:
        query = query.filter(Task.priority == priority)
    if overdue_only:
        query = query.filter(
            Task.due_date < date.today(),
            Task.status.in_(["pending", "in_progress"])
        )
    return query.order_by(Task.due_date.asc().nullslast(), Task.created_at.desc()).all()


def get_task(db: Session, task_id: UUID) -> Task:
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found."
        )
    return task


def update_task_status(db: Session, task_id: UUID, status_update: TaskStatusUpdate) -> Task:
    task = get_task(db, task_id)
    
    # Validate transition
    valid_transitions = {
        "pending": ["in_progress", "cancelled"],
        "in_progress": ["completed", "cancelled"],
        "overdue": ["in_progress", "completed", "cancelled"],
    }
    
    allowed = valid_transitions.get(task.status, [])
    if status_update.status not in allowed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot transition from '{task.status}' to '{status_update.status}'. Allowed: {allowed}"
        )
    
    task.status = status_update.status
    if status_update.status == "completed":
        task.completed_at = datetime.utcnow()
    
    db.commit()
    db.refresh(task)
    return task


def mark_overdue_tasks(db: Session) -> int:
    """Scan for tasks past due date and mark them overdue."""
    overdue = db.query(Task).filter(
        Task.due_date < date.today(),
        Task.status.in_(["pending", "in_progress"])
    ).all()
    
    count = 0
    for task in overdue:
        task.status = "overdue"
        count += 1
    
    if count > 0:
        db.commit()
    return count


def get_task_summary(db: Session, assigned_to: Optional[UUID] = None) -> Dict[str, Any]:
    query = db.query(Task)
    if assigned_to:
        query = query.filter(Task.assigned_to == assigned_to)
    
    tasks = query.all()
    
    summary = {
        "total": len(tasks),
        "pending": sum(1 for t in tasks if t.status == "pending"),
        "in_progress": sum(1 for t in tasks if t.status == "in_progress"),
        "completed": sum(1 for t in tasks if t.status == "completed"),
        "overdue": sum(1 for t in tasks if t.status == "overdue"),
        "cancelled": sum(1 for t in tasks if t.status == "cancelled"),
        "by_priority": {
            "urgent": sum(1 for t in tasks if t.priority == "urgent" and t.status not in ["completed", "cancelled"]),
            "high": sum(1 for t in tasks if t.priority == "high" and t.status not in ["completed", "cancelled"]),
            "medium": sum(1 for t in tasks if t.priority == "medium" and t.status not in ["completed", "cancelled"]),
            "low": sum(1 for t in tasks if t.priority == "low" and t.status not in ["completed", "cancelled"]),
        }
    }
    return summary
