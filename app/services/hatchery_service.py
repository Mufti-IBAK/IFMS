from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.hatchery_batch import HatcheryBatch
from app.models.hatchery_event import HatcheryEvent
from app.schemas.hatchery import HatcheryBatchCreate, HatcheryEventCreate

def create_hatchery_batch(db: Session, batch_in: HatcheryBatchCreate, user_id: UUID) -> HatcheryBatch:
    # 21-day incubation period for chicken eggs
    expected_hatch_date = batch_in.set_date + timedelta(days=21)
    
    db_batch = HatcheryBatch(
        egg_source=batch_in.egg_source,
        egg_count=batch_in.egg_count,
        breed=batch_in.breed,
        set_date=batch_in.set_date,
        expected_hatch_date=expected_hatch_date,
        fertile_eggs=None,
        hatched_chicks=None,
        failed_eggs=None,
        initial_egg_cost=batch_in.initial_egg_cost,
        status="incubating",
        created_by=user_id
    )
    db.add(db_batch)
    db.commit()
    db.refresh(db_batch)
    return db_batch

def create_hatchery_event(db: Session, batch_id: UUID, event_in: HatcheryEventCreate, user_id: UUID) -> HatcheryEvent:
    batch = db.query(HatcheryBatch).filter(HatcheryBatch.id == batch_id).first()
    if not batch:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Hatchery batch not found."
        )
        
    if batch.status == "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot add events to a completed hatchery batch."
        )
        
    val = event_in.value_json or {}
    
    if event_in.event_type == "candling":
        fertile = val.get("fertile_eggs")
        if fertile is not None:
            if fertile > batch.egg_count:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Fertile eggs ({fertile}) cannot exceed initial egg count ({batch.egg_count})."
                )
            batch.fertile_eggs = fertile
            
    elif event_in.event_type == "hatch_complete":
        hatched = val.get("hatched_chicks")
        if hatched is not None:
            # Hatched chicks cannot exceed fertile eggs (if candling has occurred)
            max_allowed = batch.fertile_eggs if batch.fertile_eggs is not None else batch.egg_count
            if hatched > max_allowed:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Hatched chicks ({hatched}) cannot exceed fertile eggs or initial egg count ({max_allowed})."
                )
            batch.hatched_chicks = hatched
            # Compute failed eggs
            batch.failed_eggs = batch.egg_count - hatched
            batch.status = "completed"
            
    db_event = HatcheryEvent(
        batch_id=batch_id,
        event_type=event_in.event_type,
        event_date=event_in.event_date,
        value_json=event_in.value_json,
        created_by=user_id
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

def get_hatchery_events(db: Session, batch_id: UUID) -> List[HatcheryEvent]:
    return db.query(HatcheryEvent).filter(HatcheryEvent.batch_id == batch_id).order_by(HatcheryEvent.event_date.desc()).all()

def get_hatchery_batch(db: Session, batch_id: UUID) -> HatcheryBatch:
    batch = db.query(HatcheryBatch).filter(HatcheryBatch.id == batch_id).first()
    if not batch:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Hatchery batch not found."
        )
    return batch

def get_hatchery_batch_kpi(db: Session, batch_id: UUID) -> Dict[str, Any]:
    batch = get_hatchery_batch(db, batch_id)
    
    # 1. Rates
    fertility_rate = 0.0
    if batch.fertile_eggs is not None:
        fertility_rate = (batch.fertile_eggs / batch.egg_count * 100.0) if batch.egg_count > 0 else 0.0
        
    hatchability_rate = 0.0
    if batch.hatched_chicks is not None and batch.fertile_eggs:
        hatchability_rate = (batch.hatched_chicks / batch.fertile_eggs * 100.0)
        
    # 2. Total cost rollup
    # Incubation events might have operational costs (like electricity/heating logged in value_json)
    events = db.query(HatcheryEvent).filter(HatcheryEvent.batch_id == batch_id).all()
    op_cost = 0.0
    for e in events:
        val = e.value_json or {}
        op_cost += val.get("cost", 0.0)
        
    total_cost = batch.initial_egg_cost + op_cost
    
    # 3. Cost per chick
    cost_per_chick = 0.0
    if batch.hatched_chicks and batch.hatched_chicks > 0:
        cost_per_chick = total_cost / batch.hatched_chicks
        
    return {
        "fertility_rate_percent": round(fertility_rate, 2),
        "hatchability_rate_percent": round(hatchability_rate, 2),
        "total_cost": round(total_cost, 2),
        "cost_per_chick": round(cost_per_chick, 2),
        "hatched_chicks": batch.hatched_chicks or 0,
        "failed_eggs": batch.failed_eggs or 0,
        "status": batch.status
    }

def get_hatchery_profitability_summary(db: Session) -> Dict[str, Any]:
    batches = db.query(HatcheryBatch).all()
    
    total_cost = 0.0
    total_chicks = 0
    incubating_count = 0
    completed_count = 0
    
    for b in batches:
        kpis = get_hatchery_batch_kpi(db, b.id)
        total_cost += kpis["total_cost"]
        total_chicks += kpis["hatched_chicks"]
        if b.status == "incubating":
            incubating_count += 1
        else:
            completed_count += 1
            
    avg_cost_per_chick = total_cost / total_chicks if total_chicks > 0 else 0.0
    
    return {
        "total_batches": len(batches),
        "incubating_batches": incubating_count,
        "completed_batches": completed_count,
        "total_cost": round(total_cost, 2),
        "total_chicks_hatched": total_chicks,
        "average_cost_per_chick": round(avg_cost_per_chick, 2)
    }

def get_hatchery_batches(db: Session, status: Optional[str] = None) -> List[HatcheryBatch]:
    query = db.query(HatcheryBatch)
    if status:
        query = query.filter(HatcheryBatch.status == status)
    return query.order_by(HatcheryBatch.created_at.desc()).all()
