from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.animal import Animal, AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.models.poultry_batch import PoultryBatch
from app.models.hatchery_batch import HatcheryBatch
from app.models.transaction import Transaction
from app.models.animal_event import AnimalEvent, EventCategory
from app.schemas.finance import TransactionCreate
from app.services import animal_service

def create_transaction(db: Session, txn_in: TransactionCreate, user_id: UUID) -> Transaction:
    # Validate related entity if provided
    if txn_in.related_entity_type and txn_in.related_entity_id:
        if txn_in.related_entity_type == "animal":
            entity = db.query(Animal).filter(Animal.id == txn_in.related_entity_id).first()
        elif txn_in.related_entity_type == "poultry_batch":
            entity = db.query(PoultryBatch).filter(PoultryBatch.id == txn_in.related_entity_id).first()
        elif txn_in.related_entity_type == "hatchery_batch":
            entity = db.query(HatcheryBatch).filter(HatcheryBatch.id == txn_in.related_entity_id).first()
        else:
            entity = None
            
        if not entity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Referenced {txn_in.related_entity_type} entity with ID {txn_in.related_entity_id} not found."
            )
            
    # SAFETY CHECK: Block milk sales for animals under antibiotic withdrawal
    if (txn_in.category == "milk_sales" 
        and txn_in.related_entity_type == "animal" 
        and txn_in.related_entity_id is not None):
        from datetime import datetime as dt_cls
        treatment_events = db.query(AnimalEvent).filter(
            AnimalEvent.animal_id == txn_in.related_entity_id,
            AnimalEvent.event_type == "treatment",
            AnimalEvent.event_category == EventCategory.HEALTH
        ).all()
        for evt in treatment_events:
            payload = evt.payload or {}
            if payload.get("treatment_type") == "antibiotic":
                withdrawal_days = payload.get("withdrawal_days", 0)
                treatment_date = evt.event_timestamp.date() if isinstance(evt.event_timestamp, dt_cls) else evt.event_timestamp
                withdrawal_end = treatment_date + timedelta(days=withdrawal_days)
                if txn_in.transaction_date <= withdrawal_end:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Cannot record milk sales: animal is under antibiotic withdrawal until {withdrawal_end.isoformat()}. Milk is unsafe for sale."
                    )
    
    db_txn = Transaction(
        transaction_type=txn_in.transaction_type,
        category=txn_in.category,
        amount=txn_in.amount,
        related_entity_type=txn_in.related_entity_type,
        related_entity_id=txn_in.related_entity_id,
        description=txn_in.description,
        transaction_date=txn_in.transaction_date,
        created_by=user_id
    )
    db.add(db_txn)
    db.commit()
    db.refresh(db_txn)
    return db_txn

def get_transactions(
    db: Session, 
    transaction_type: Optional[str] = None, 
    category: Optional[str] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None
) -> List[Transaction]:
    query = db.query(Transaction)
    if transaction_type:
        query = query.filter(Transaction.transaction_type == transaction_type)
    if category:
        query = query.filter(Transaction.category == category)
    if start_date:
        query = query.filter(Transaction.transaction_date >= start_date)
    if end_date:
        query = query.filter(Transaction.transaction_date <= end_date)
    return query.order_by(Transaction.transaction_date.desc()).all()

def count_active_production_units(db: Session, target_date: date) -> int:
    # 1. Count active animals
    animals_count = db.query(Animal).filter(
        Animal.status == AnimalStatus.ACTIVE,
        Animal.date_of_birth <= target_date
    ).count()
    
    # 2. Count active poultry batches
    poultry_count = db.query(PoultryBatch).filter(
        PoultryBatch.status == "active",
        PoultryBatch.start_date <= target_date
    ).count()
    
    # 3. Count active hatchery batches
    hatchery_count = db.query(HatcheryBatch).filter(
        HatcheryBatch.status == "incubating",
        HatcheryBatch.set_date <= target_date
    ).count()
    
    return animals_count + poultry_count + hatchery_count

def get_animal_depreciation(animal: Animal, check_date: date) -> Dict[str, Any]:
    useful_life = 8.0 if animal.species == AnimalSpecies.COW else 5.0
    salvage_val = animal.salvage_value or (50000.0 if animal.species == AnimalSpecies.COW else 15000.0)
    
    age_days = (check_date - animal.date_of_birth).days
    age_years = age_days / 365.25
    if age_years < 0:
        age_years = 0.0
        
    depreciation_rate = (animal.acquisition_cost - salvage_val) / useful_life if animal.acquisition_cost > salvage_val else 0.0
    cumulative_depr = age_years * depreciation_rate
    book_value = max(salvage_val, animal.acquisition_cost - cumulative_depr)
    
    return {
        "useful_life_years": useful_life,
        "salvage_value": salvage_val,
        "age_years": round(age_years, 2),
        "annual_depreciation": round(depreciation_rate, 2),
        "cumulative_depreciation": round(cumulative_depr, 2),
        "current_book_value": round(book_value, 2)
    }

def get_animal_financial_summary(db: Session, animal_id: UUID, reference_date: Optional[date] = None) -> Dict[str, Any]:
    if not reference_date:
        reference_date = date.today()
        
    animal = db.query(Animal).filter(Animal.id == animal_id).first()
    if not animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
        
    # Query direct transactions
    direct_txns = db.query(Transaction).filter(
        Transaction.related_entity_type == "animal",
        Transaction.related_entity_id == animal_id
    ).all()
    
    direct_feed = sum(t.amount for t in direct_txns if t.transaction_type == "expense" and t.category == "feed")
    direct_health = sum(t.amount for t in direct_txns if t.transaction_type == "expense" and t.category == "medication")
    direct_labor = sum(t.amount for t in direct_txns if t.transaction_type == "expense" and t.category == "labor")
    direct_revenue = sum(t.amount for t in direct_txns if t.transaction_type == "income")
    
    # Query indirect general transactions to allocate overheads
    indirect_txns = db.query(Transaction).filter(
        Transaction.related_entity_type == None
    ).all()
    
    allocated_feed = 0.0
    allocated_labor = 0.0
    allocated_overhead = 0.0
    
    for t in indirect_txns:
        units = count_active_production_units(db, t.transaction_date)
        if units > 0:
            share = t.amount / units
            if t.category == "feed":
                allocated_feed += share
            elif t.category == "labor":
                allocated_labor += share
            else:
                allocated_overhead += share
                
    total_feed = direct_feed + allocated_feed
    total_health = direct_health
    total_labor = direct_labor + allocated_labor
    total_overhead = allocated_overhead
    
    total_costs = total_feed + total_health + total_labor + total_overhead
    net_profit = direct_revenue - total_costs
    
    depr_summary = get_animal_depreciation(animal, reference_date)
    
    return {
        "tag_id": animal.tag_id,
        "species": animal.species,
        "acquisition_cost": animal.acquisition_cost,
        "direct_revenue": round(direct_revenue, 2),
        "feed_cost": round(total_feed, 2),
        "health_cost": round(total_health, 2),
        "labor_cost": round(total_labor, 2),
        "allocated_overhead": round(total_overhead, 2),
        "total_costs": round(total_costs, 2),
        "net_profit": round(net_profit, 2),
        "depreciation": depr_summary
    }

def get_culling_recommendations(db: Session, reference_date: Optional[date] = None) -> List[Dict[str, Any]]:
    if not reference_date:
        reference_date = date.today()
        
    cows = db.query(Animal).filter(
        Animal.status == AnimalStatus.ACTIVE,
        Animal.species == AnimalSpecies.COW,
        Animal.sex == "female"
    ).all()
    
    recommendations = []
    
    # Fetch herd average yield to check senescence
    from app.services.dairy_service import get_herd_dairy_kpis
    herd_kpis = get_herd_dairy_kpis(db, reference_date)
    avg_herd_yield = herd_kpis["average_milk_per_cow"]
    
    for cow in cows:
        fin = get_animal_financial_summary(db, cow.id, reference_date)
        
        # 1. Health Loss check (medical costs > 50% of acquisition cost)
        health_loss = False
        if cow.acquisition_cost > 0 and fin["health_cost"] > (cow.acquisition_cost * 0.5):
            health_loss = True
            
        # 2. Economic Loss check (30-day trailing profit is negative)
        # Fetch transactions of the last 30 days
        thirty_days_ago = reference_date - timedelta(days=30)
        direct_txns_30d = db.query(Transaction).filter(
            Transaction.related_entity_type == "animal",
            Transaction.related_entity_id == cow.id,
            Transaction.transaction_date >= thirty_days_ago,
            Transaction.transaction_date <= reference_date
        ).all()
        
        rev_30d = sum(t.amount for t in direct_txns_30d if t.transaction_type == "income")
        direct_costs_30d = sum(t.amount for t in direct_txns_30d if t.transaction_type == "expense")
        
        # Estimate allocated costs of the last 30 days
        indirect_txns_30d = db.query(Transaction).filter(
            Transaction.related_entity_type == None,
            Transaction.transaction_date >= thirty_days_ago,
            Transaction.transaction_date <= reference_date
        ).all()
        
        alloc_costs_30d = 0.0
        for t in indirect_txns_30d:
            units = count_active_production_units(db, t.transaction_date)
            if units > 0:
                alloc_costs_30d += t.amount / units
                
        total_costs_30d = direct_costs_30d + alloc_costs_30d
        profit_30d = rev_30d - total_costs_30d
        economic_loss = profit_30d < 0.0 and total_costs_30d > 0.0
        
        # 3. Reproductive Failure: Cow has been OPEN for > 150 days since calving without AI/Mating
        repro_failure = False
        if cow.current_reproductive_status in [ReproductiveStatus.OPEN, ReproductiveStatus.LACTATING, ReproductiveStatus.IN_HEAT]:
            latest_calving = db.query(AnimalEvent).filter(
                AnimalEvent.animal_id == cow.id,
                func.lower(AnimalEvent.event_type) == "calving"
            ).order_by(AnimalEvent.event_timestamp.desc()).first()
            
            if latest_calving:
                days_open = (reference_date - latest_calving.event_timestamp.date()).days
                if days_open > 150:
                    # Verify no mating service occurred since calving
                    latest_service = db.query(AnimalEvent).filter(
                        AnimalEvent.animal_id == cow.id,
                        AnimalEvent.event_type.in_(["mating", "ai_insemination"]),
                        AnimalEvent.event_timestamp > latest_calving.event_timestamp
                    ).first()
                    if not latest_service:
                        repro_failure = True
                        
        # 4. Senescence check (fully depreciated AND yield below average)
        senescence = False
        depr = fin["depreciation"]
        if depr["current_book_value"] <= depr["salvage_value"]:
            # Check today's yield
            from app.services.dairy_service import get_animal_dairy_kpis
            cow_kpi = get_animal_dairy_kpis(db, cow.id, reference_date)
            today_yield = cow_kpi["today_yield"]
            if today_yield < avg_herd_yield:
                senescence = True
                
        if health_loss or economic_loss or repro_failure or senescence:
            reasons = []
            if health_loss: reasons.append("Chronic Health Costs")
            if economic_loss: reasons.append("Negative Trailing Margin")
            if repro_failure: reasons.append("Extended Open Days (>150d)")
            if senescence: reasons.append("Fully Depreciated / Low Yield")
            
            recommendations.append({
                "animal_id": cow.id,
                "tag_id": cow.tag_id,
                "book_value": depr["current_book_value"],
                "salvage_value": depr["salvage_value"],
                "reasons": reasons,
                "health_loss": health_loss,
                "economic_loss": economic_loss,
                "reproductive_failure": repro_failure,
                "senescence": senescence
            })
            
    return recommendations

def get_overall_farm_profit(db: Session) -> Dict[str, Any]:
    # General totals
    income_sum = db.query(func.sum(Transaction.amount)).filter(Transaction.transaction_type == "income").scalar() or 0.0
    expense_sum = db.query(func.sum(Transaction.amount)).filter(Transaction.transaction_type == "expense").scalar() or 0.0
    
    # Breakdown by category
    categories = ["milk_sales", "animal_sales", "poultry_sales", "hatchery_sales", "feed", "medication", "labor", "equipment", "utilities", "misc"]
    breakdown = {}
    for cat in categories:
        val = db.query(func.sum(Transaction.amount)).filter(Transaction.category == cat).scalar() or 0.0
        breakdown[cat] = round(val, 2)
        
    return {
        "total_revenue": round(income_sum, 2),
        "total_expenses": round(expense_sum, 2),
        "net_profit": round(income_sum - expense_sum, 2),
        "breakdown": breakdown
    }

def reconcile_transaction(db: Session, transaction_id: UUID, user_id: UUID) -> Dict[str, Any]:
    txn = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not txn:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction not found."
        )
    if txn.is_reconciled:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Transaction is already reconciled."
        )
    txn.is_reconciled = True
    txn.approved_by = user_id
    db.commit()
    db.refresh(txn)
    return {"message": "Transaction reconciled successfully.", "id": str(txn.id)}

def reverse_transaction(db: Session, transaction_id: UUID, user_id: UUID) -> Transaction:
    original = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not original:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Original transaction not found."
        )
    # Check if already reversed
    existing_reversal = db.query(Transaction).filter(Transaction.reversal_of == transaction_id).first()
    if existing_reversal:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This transaction has already been reversed."
        )
    # Create reversal entry (same data, opposite type)
    reversed_type = "expense" if original.transaction_type == "income" else "income"
    reversal = Transaction(
        transaction_type=reversed_type,
        category=original.category,
        amount=original.amount,
        related_entity_type=original.related_entity_type,
        related_entity_id=original.related_entity_id,
        description=f"REVERSAL of transaction {original.id}: {original.description or ''}",
        transaction_date=date.today(),
        created_by=user_id,
        reversal_of=transaction_id
    )
    db.add(reversal)
    db.commit()
    db.refresh(reversal)
    return reversal
