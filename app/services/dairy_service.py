from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, text, Float

from app.models.animal import Animal, AnimalSpecies, ReproductiveStatus
from app.models.milk_record import MilkRecord
from app.models.lactation import Lactation
from app.models.animal_event import AnimalEvent
from app.schemas.dairy import MilkRecordCreate

def check_antibiotic_withdrawal(db: Session, animal_id: UUID, check_date: date) -> bool:
    # Fetch all treatment events for this animal
    events = db.query(AnimalEvent).filter(
        AnimalEvent.animal_id == animal_id,
        func.lower(AnimalEvent.event_type) == "treatment"
    ).all()
    
    for event in events:
        payload = event.payload or {}
        # Check if treatment_type, drug_type, or general fields indicate antibiotic
        is_antibiotic = (
            str(payload.get("treatment_type", "")).lower() == "antibiotic" or
            str(payload.get("drug_type", "")).lower() == "antibiotic" or
            payload.get("is_antibiotic") is True or
            "antibiotic" in str(payload.get("drug", "")).lower() or
            "antibiotic" in str(payload.get("notes", "")).lower()
        )
        withdrawal_days = payload.get("withdrawal_days")
        if is_antibiotic and withdrawal_days is not None:
            try:
                w_days = int(withdrawal_days)
                event_date = event.event_timestamp.date()
                # Active withdrawal window: [event_date, event_date + w_days]
                if event_date <= check_date <= (event_date + timedelta(days=w_days)):
                    return True
            except ValueError:
                continue
    return False

def start_lactation(db: Session, animal_id: UUID, start_date: date) -> Lactation:
    # 1. Close any active lactation
    active_lactation = db.query(Lactation).filter(
        Lactation.animal_id == animal_id,
        Lactation.status == "active"
    ).first()
    
    if active_lactation:
        active_lactation.status = "completed"
        active_lactation.end_date = start_date - timedelta(days=1)
        
    # 2. Get highest lactation number
    max_num = db.query(func.max(Lactation.lactation_number)).filter(
        Lactation.animal_id == animal_id
    ).scalar()
    
    next_num = (max_num or 0) + 1
    
    # 3. Create new active lactation
    db_lactation = Lactation(
        animal_id=animal_id,
        start_date=start_date,
        lactation_number=next_num,
        status="active"
    )
    db.add(db_lactation)
    db.commit()
    db.refresh(db_lactation)
    return db_lactation

def close_lactation(db: Session, animal_id: UUID, end_date: date) -> Optional[Lactation]:
    active_lactation = db.query(Lactation).filter(
        Lactation.animal_id == animal_id,
        Lactation.status == "active"
    ).first()
    
    if active_lactation:
        active_lactation.status = "completed"
        active_lactation.end_date = end_date
        db.commit()
        db.refresh(active_lactation)
    return active_lactation

def create_milk_record(db: Session, record_in: MilkRecordCreate, user_id: UUID) -> MilkRecord:
    # Verify animal exists
    animal = db.query(Animal).filter(Animal.id == record_in.animal_id).first()
    if not animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
        
    # Verify it is a female cow
    if animal.species != AnimalSpecies.COW or animal.sex != "female":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only female cows produce milk records."
        )
        
    # Check for active drug withdrawal
    is_withdrawn = check_antibiotic_withdrawal(db, record_in.animal_id, record_in.record_date)
    
    db_record = MilkRecord(
        animal_id=record_in.animal_id,
        record_date=record_in.record_date,
        milking_session=record_in.milking_session,
        quantity_liters=record_in.quantity_liters,
        fat_percentage=record_in.fat_percentage,
        protein_percentage=record_in.protein_percentage,
        is_withdrawn=is_withdrawn,
        created_by=user_id
    )
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record

def get_milk_records(db: Session, animal_id: UUID) -> List[MilkRecord]:
    return db.query(MilkRecord).filter(MilkRecord.animal_id == animal_id).order_by(MilkRecord.record_date.desc(), MilkRecord.milking_session.desc()).all()

def get_lactation_history(db: Session, animal_id: UUID) -> List[Lactation]:
    return db.query(Lactation).filter(Lactation.animal_id == animal_id).order_by(Lactation.lactation_number.desc()).all()

def get_animal_dairy_kpis(db: Session, animal_id: UUID, reference_date: Optional[date] = None) -> Dict[str, Any]:
    if not reference_date:
        reference_date = date.today()
        
    # 1. Days In Milk (DIM)
    active_lactation = db.query(Lactation).filter(
        Lactation.animal_id == animal_id,
        Lactation.status == "active"
    ).first()
    
    dim = 0
    if active_lactation:
        dim = (reference_date - active_lactation.start_date).days
        if dim < 0:
            dim = 0
            
    # 2. 7-Day Rolling Average (based on completed 7 days preceding reference_date)
    seven_days_ago = reference_date - timedelta(days=7)
    
    daily_yields_q = db.query(
        MilkRecord.record_date,
        func.sum(MilkRecord.quantity_liters).label("daily_total")
    ).filter(
        MilkRecord.animal_id == animal_id,
        MilkRecord.record_date >= seven_days_ago,
        MilkRecord.record_date < reference_date
    ).group_by(MilkRecord.record_date).all()
    
    daily_yields = [row.daily_total for row in daily_yields_q]
    avg_7_day = sum(daily_yields) / 7.0 if daily_yields else 0.0
    
    # 3. Peak Yield during current lactation
    peak_yield = 0.0
    if active_lactation:
        peak_yield_q = db.query(
            func.sum(MilkRecord.quantity_liters).label("daily_total")
        ).filter(
            MilkRecord.animal_id == animal_id,
            MilkRecord.record_date >= active_lactation.start_date,
            MilkRecord.record_date <= reference_date
        ).group_by(MilkRecord.record_date).order_by(text("daily_total DESC")).first()
        
        if peak_yield_q:
            peak_yield = peak_yield_q.daily_total
            
    # 4. Yield Drop Anomaly
    today_yield_q = db.query(
        func.sum(MilkRecord.quantity_liters)
    ).filter(
        MilkRecord.animal_id == animal_id,
        MilkRecord.record_date == reference_date
    ).scalar()
    
    today_yield = today_yield_q or 0.0
    
    # Trigger drop if today's yield is 20% lower than 7-day average (only if we have logged yield today and have a stable average > 0)
    milk_drop = False
    if avg_7_day > 0.0 and today_yield > 0.0 and today_yield < (avg_7_day * 0.8):
        milk_drop = True
        
    # 5. Mastitis Risk (sudden drop + abnormal milk health event in the last 3 days)
    risk_mastitis = False
    if milk_drop:
        three_days_ago = datetime.combine(reference_date - timedelta(days=3), datetime.min.time())
        ref_datetime_end = datetime.combine(reference_date, datetime.max.time())
        
        # Fetch all events for this animal and filter in Python to avoid SQLite string date comparison anomalies
        all_events = db.query(AnimalEvent).filter(
            AnimalEvent.animal_id == animal_id
        ).all()
        
        for event in all_events:
            e_type = event.event_type.lower()
            if e_type not in ["disease_diagnosis", "treatment", "abnormal_milk"]:
                continue
                
            # Naive datetime comparison
            if not (three_days_ago <= event.event_timestamp <= ref_datetime_end):
                continue
                
            payload_str = str(event.payload or {}).lower()
            if "mastitis" in payload_str or "clot" in payload_str or "swollen" in payload_str or "abnormal" in payload_str:
                risk_mastitis = True
                break
                
    return {
        "days_in_milk": dim,
        "rolling_average_7d": round(avg_7_day, 2),
        "peak_lactation_yield": round(peak_yield, 2),
        "today_yield": round(today_yield, 2),
        "alerts": {
            "milk_drop_detected": milk_drop,
            "risk_mastitis": risk_mastitis
        }
    }

def get_herd_dairy_kpis(db: Session, reference_date: Optional[date] = None) -> Dict[str, Any]:
    if not reference_date:
        reference_date = date.today()
        
    # Total milk today (only non-withdrawn milk is sellable, but let's return both for analytics)
    totals = db.query(
        func.sum(MilkRecord.quantity_liters).label("total"),
        func.sum(func.cast(MilkRecord.is_withdrawn == False, Float) * MilkRecord.quantity_liters).label("sellable")
    ).filter(MilkRecord.record_date == reference_date).first()
    
    total_milk = totals.total or 0.0
    sellable_milk = totals.sellable or 0.0
    
    # Cows milked today
    cows_count = db.query(MilkRecord.animal_id).filter(MilkRecord.record_date == reference_date).distinct().count()
    avg_per_cow = total_milk / cows_count if cows_count > 0 else 0.0
    
    # Top 10 cows in the last 7 days
    seven_days_ago = reference_date - timedelta(days=7)
    top_cows_q = db.query(
        MilkRecord.animal_id,
        func.sum(MilkRecord.quantity_liters).label("total_yield")
    ).filter(
        MilkRecord.record_date > seven_days_ago,
        MilkRecord.record_date <= reference_date
    ).group_by(MilkRecord.animal_id).order_by(text("total_yield DESC")).limit(10).all()
    
    top_cows = []
    for row in top_cows_q:
        animal = db.query(Animal).filter(Animal.id == row.animal_id).first()
        top_cows.append({
            "animal_id": row.animal_id,
            "tag_id": animal.tag_id if animal else "Unknown",
            "total_yield": round(row.total_yield, 2)
        })
        
    return {
        "total_milk_liters": round(total_milk, 2),
        "sellable_milk_liters": round(sellable_milk, 2),
        "cows_milked_count": cows_count,
        "average_milk_per_cow": round(avg_per_cow, 2),
        "top_producers_7d": top_cows
    }

def get_dairy_profitability_by_animal(
    db: Session, 
    milk_price: float = 500.0, 
    feed_cost: float = 1500.0, 
    target_date: Optional[date] = None
) -> List[Dict[str, Any]]:
    if not target_date:
        target_date = date.today()
        
    # Get all active cows
    cows = db.query(Animal).filter(
        Animal.species == AnimalSpecies.COW,
        Animal.sex == "female"
    ).all()
    
    records = []
    for cow in cows:
        # Sum quantity for target_date
        yield_today = db.query(func.sum(MilkRecord.quantity_liters)).filter(
            MilkRecord.animal_id == cow.id,
            MilkRecord.record_date == target_date
        ).scalar() or 0.0
        
        # Check if milk was withdrawn
        has_withdrawal = db.query(MilkRecord).filter(
            MilkRecord.animal_id == cow.id,
            MilkRecord.record_date == target_date,
            MilkRecord.is_withdrawn == True
        ).first() is not None
        
        # Revenue is only generated if milk is not withdrawn
        revenue = 0.0
        if not has_withdrawal:
            revenue = yield_today * milk_price
            
        profit = revenue - feed_cost
        
        records.append({
            "animal_id": cow.id,
            "tag_id": cow.tag_id,
            "yield_liters": round(yield_today, 2),
            "is_withdrawn": has_withdrawal,
            "revenue": round(revenue, 2),
            "feed_cost": round(feed_cost, 2),
            "profit": round(profit, 2),
            "is_loss_making": profit < 0
        })
    return sorted(records, key=lambda x: x["profit"])

def get_dairy_profitability_summary(
    db: Session, 
    milk_price: float = 500.0, 
    feed_cost: float = 1500.0, 
    target_date: Optional[date] = None
) -> Dict[str, Any]:
    cow_profits = get_dairy_profitability_by_animal(db, milk_price, feed_cost, target_date)
    
    total_revenue = sum(c["revenue"] for c in cow_profits)
    total_feed_cost = sum(c["feed_cost"] for c in cow_profits)
    total_profit = total_revenue - total_feed_cost
    loss_cows_count = sum(1 for c in cow_profits if c["is_loss_making"])
    
    return {
        "date": target_date.isoformat() if target_date else date.today().isoformat(),
        "total_revenue": round(total_revenue, 2),
        "total_feed_cost": round(total_feed_cost, 2),
        "total_profit": round(total_profit, 2),
        "cows_count": len(cow_profits),
        "loss_making_cows_count": loss_cows_count
    }
