from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.poultry_batch import PoultryBatch
from app.models.poultry_event import PoultryEvent
from app.schemas.poultry import PoultryBatchCreate, PoultryEventCreate

def create_poultry_batch(db: Session, batch_in: PoultryBatchCreate, user_id: UUID) -> PoultryBatch:
    db_batch = PoultryBatch(
        batch_type=batch_in.batch_type,
        breed=batch_in.breed,
        start_date=batch_in.start_date,
        initial_count=batch_in.initial_count,
        current_count=batch_in.initial_count,
        status="active",
        location_id=batch_in.location_id,
        initial_chick_cost=batch_in.initial_chick_cost,
        created_by=user_id
    )
    db.add(db_batch)
    db.commit()
    db.refresh(db_batch)
    return db_batch

def create_poultry_event(db: Session, batch_id: UUID, event_in: PoultryEventCreate, user_id: UUID) -> PoultryEvent:
    batch = db.query(PoultryBatch).filter(PoultryBatch.id == batch_id).first()
    if not batch:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Poultry batch not found."
        )
        
    if batch.status == "closed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot add events to a closed batch."
        )
        
    # Trigger batch count updates
    if event_in.event_type == "mortality":
        if batch.current_count < event_in.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Mortality quantity ({event_in.quantity}) cannot exceed current batch count ({batch.current_count})."
            )
        batch.current_count -= int(event_in.quantity)
        
    elif event_in.event_type == "sale":
        if batch.current_count < event_in.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Sale quantity ({event_in.quantity}) cannot exceed current batch count ({batch.current_count})."
            )
        batch.current_count -= int(event_in.quantity)
        
        # Auto-close batch if current count reaches 0
        if batch.current_count == 0:
            batch.status = "closed"
            batch.end_date = event_in.event_date
            
    db_event = PoultryEvent(
        batch_id=batch_id,
        event_type=event_in.event_type,
        event_date=event_in.event_date,
        quantity=event_in.quantity,
        value_json=event_in.value_json,
        created_by=user_id
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

def get_poultry_events(db: Session, batch_id: UUID) -> List[PoultryEvent]:
    return db.query(PoultryEvent).filter(PoultryEvent.batch_id == batch_id).order_by(PoultryEvent.event_date.desc()).all()

def get_poultry_batch(db: Session, batch_id: UUID) -> PoultryBatch:
    batch = db.query(PoultryBatch).filter(PoultryBatch.id == batch_id).first()
    if not batch:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Poultry batch not found."
        )
    return batch

def get_poultry_batch_kpi(db: Session, batch_id: UUID, reference_date: Optional[date] = None) -> Dict[str, Any]:
    if not reference_date:
        reference_date = date.today()
        
    batch = get_poultry_batch(db, batch_id)
    
    # 1. Mortality count
    total_dead = db.query(func.sum(PoultryEvent.quantity)).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "mortality"
    ).scalar() or 0.0
    
    mortality_rate = (total_dead / batch.initial_count * 100.0) if batch.initial_count > 0 else 0.0
    
    # 2. Feed Sum
    total_feed = db.query(func.sum(PoultryEvent.quantity)).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "feed"
    ).scalar() or 0.0
    
    # 3. Latest weight sample
    latest_sample = db.query(PoultryEvent).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "weight_sample"
    ).order_by(PoultryEvent.event_date.desc()).first()
    
    avg_weight = latest_sample.value_json.get("avg_weight_kg", 0.04) if latest_sample and latest_sample.value_json else 0.04
    live_weight = avg_weight * batch.current_count
    
    # 4. Sold metrics
    sales = db.query(PoultryEvent).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "sale"
    ).all()
    
    sold_weight = 0.0
    sold_count = 0
    revenue = 0.0
    for s in sales:
        qty = s.quantity
        val = s.value_json or {}
        sold_count += qty
        s_weight = val.get("avg_weight_kg", avg_weight)
        sold_weight += qty * s_weight
        revenue += val.get("revenue", qty * val.get("price_per_bird", 500.0))
        
    # 5. FCR computation
    initial_weight = batch.initial_count * 0.04
    weight_gain = live_weight + sold_weight - initial_weight
    if weight_gain < 0.0:
        weight_gain = 0.0
        
    fcr = total_feed / weight_gain if weight_gain > 0.0 else 0.0
    
    # 6. Economic cost rollup
    feed_events = db.query(PoultryEvent).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "feed"
    ).all()
    
    feed_cost = 0.0
    for f in feed_events:
        val = f.value_json or {}
        feed_cost += f.quantity * val.get("price_per_kg", 200.0)
        
    med_events = db.query(PoultryEvent).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "vaccination"
    ).all()
    
    med_cost = 0.0
    for m in med_events:
        val = m.value_json or {}
        med_cost += val.get("cost", 0.0)
        
    total_cost = batch.initial_chick_cost + feed_cost + med_cost
    cost_per_kg = total_cost / sold_weight if sold_weight > 0.0 else 0.0
    profit = revenue - total_cost
    
    # 7. Alert checks
    high_mortality = mortality_rate > 5.0
    poor_fcr = fcr > 2.2
    
    # Outbreak check: sum of mortality in last 48 hours relative to reference_date
    two_days_ago = reference_date - timedelta(days=2)
    mortality_48h = db.query(func.sum(PoultryEvent.quantity)).filter(
        PoultryEvent.batch_id == batch_id,
        PoultryEvent.event_type == "mortality",
        PoultryEvent.event_date >= two_days_ago,
        PoultryEvent.event_date <= reference_date
    ).scalar() or 0.0
    
    outbreak_risk = mortality_48h > (batch.initial_count * 0.02) # > 2% in 48h
    
    return {
        "mortality_rate_percent": round(mortality_rate, 2),
        "total_feed_consumed_kg": round(total_feed, 2),
        "feed_conversion_ratio": round(fcr, 2),
        "average_weight_kg": round(avg_weight, 3),
        "live_weight_kg": round(live_weight, 2),
        "sold_weight_kg": round(sold_weight, 2),
        "total_sold_count": int(sold_count),
        "revenue": round(revenue, 2),
        "total_costs": round(total_cost, 2),
        "cost_per_kg_sold": round(cost_per_kg, 2),
        "net_profit": round(profit, 2),
        "alerts": {
            "high_mortality_alert": high_mortality,
            "poor_fcr_alert": poor_fcr,
            "disease_outbreak_risk": outbreak_risk
        }
    }

def get_poultry_profitability_summary(db: Session) -> Dict[str, Any]:
    batches = db.query(PoultryBatch).all()
    
    total_revenue = 0.0
    total_cost = 0.0
    total_profit = 0.0
    active_count = 0
    closed_count = 0
    
    for b in batches:
        kpis = get_poultry_batch_kpi(db, b.id)
        total_revenue += kpis["revenue"]
        total_cost += kpis["total_costs"]
        total_profit += kpis["net_profit"]
        if b.status == "active":
            active_count += 1
        else:
            closed_count += 1
            
    return {
        "total_batches": len(batches),
        "active_batches": active_count,
        "closed_batches": closed_count,
        "total_revenue": round(total_revenue, 2),
        "total_cost": round(total_cost, 2),
        "net_profit": round(total_profit, 2)
    }
