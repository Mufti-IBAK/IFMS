from datetime import date, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.feed_item import FeedItem
from app.models.inventory_log import InventoryLog
from app.schemas.inventory import FeedItemCreate, FeedItemUpdate, InventoryLogCreate


def create_feed_item(db: Session, item_in: FeedItemCreate, user_id: UUID) -> FeedItem:
    existing = db.query(FeedItem).filter(FeedItem.name == item_in.name).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Feed item with name '{item_in.name}' already exists."
        )
    db_item = FeedItem(
        name=item_in.name,
        category=item_in.category,
        unit=item_in.unit,
        current_stock=item_in.current_stock,
        reorder_threshold=item_in.reorder_threshold,
        cost_per_unit=item_in.cost_per_unit,
        supplier=item_in.supplier,
        created_by=user_id
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


def get_feed_items(db: Session, category: Optional[str] = None, active_only: bool = True) -> List[FeedItem]:
    query = db.query(FeedItem)
    if active_only:
        query = query.filter(FeedItem.is_active == True)
    if category:
        query = query.filter(FeedItem.category == category)
    return query.order_by(FeedItem.name).all()


def get_feed_item(db: Session, item_id: UUID) -> FeedItem:
    item = db.query(FeedItem).filter(FeedItem.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Feed item not found."
        )
    return item


def update_feed_item(db: Session, item_id: UUID, update_in: FeedItemUpdate) -> FeedItem:
    item = get_feed_item(db, item_id)
    update_data = update_in.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(item, key, value)
    db.commit()
    db.refresh(item)
    return item


def log_inventory_change(db: Session, log_in: InventoryLogCreate, user_id: UUID) -> InventoryLog:
    item = get_feed_item(db, log_in.item_id)
    
    # Calculate new balance
    if log_in.change_type in ["purchase", "return", "adjustment"]:
        new_balance = item.current_stock + abs(log_in.quantity_change)
    elif log_in.change_type in ["consumption", "waste"]:
        deduction = abs(log_in.quantity_change)
        if deduction > item.current_stock:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Insufficient stock. Current: {item.current_stock} {item.unit}, Requested: {deduction} {item.unit}"
            )
        new_balance = item.current_stock - deduction
    else:
        new_balance = item.current_stock + log_in.quantity_change
    
    # Update stock level
    item.current_stock = new_balance
    
    # Create log entry
    db_log = InventoryLog(
        item_id=log_in.item_id,
        change_type=log_in.change_type,
        quantity_change=log_in.quantity_change if log_in.change_type in ["purchase", "return", "adjustment"] else -abs(log_in.quantity_change),
        balance_after=new_balance,
        related_entity_type=log_in.related_entity_type,
        related_entity_id=log_in.related_entity_id,
        notes=log_in.notes,
        log_date=log_in.log_date,
        logged_by=user_id
    )
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log


def get_inventory_logs(db: Session, item_id: Optional[UUID] = None, start_date: Optional[date] = None, end_date: Optional[date] = None) -> List[InventoryLog]:
    query = db.query(InventoryLog)
    if item_id:
        query = query.filter(InventoryLog.item_id == item_id)
    if start_date:
        query = query.filter(InventoryLog.log_date >= start_date)
    if end_date:
        query = query.filter(InventoryLog.log_date <= end_date)
    return query.order_by(InventoryLog.log_date.desc()).all()


def get_low_stock_alerts(db: Session) -> List[Dict[str, Any]]:
    items = db.query(FeedItem).filter(
        FeedItem.is_active == True,
        FeedItem.current_stock <= FeedItem.reorder_threshold
    ).all()
    
    alerts = []
    for item in items:
        alerts.append({
            "item_id": item.id,
            "name": item.name,
            "category": item.category,
            "current_stock": item.current_stock,
            "unit": item.unit,
            "reorder_threshold": item.reorder_threshold,
            "deficit": round(item.reorder_threshold - item.current_stock, 2),
            "estimated_reorder_cost": round((item.reorder_threshold - item.current_stock) * item.cost_per_unit, 2) if item.current_stock < item.reorder_threshold else 0.0
        })
    return alerts


def get_consumption_summary(db: Session, days: int = 30) -> Dict[str, Any]:
    cutoff = date.today() - timedelta(days=days)
    
    logs = db.query(InventoryLog).filter(
        InventoryLog.change_type == "consumption",
        InventoryLog.log_date >= cutoff
    ).all()
    
    by_item: Dict[str, float] = {}
    total_cost = 0.0
    
    for log in logs:
        item = db.query(FeedItem).filter(FeedItem.id == log.item_id).first()
        if item:
            item_name = item.name
            consumed = abs(log.quantity_change)
            by_item[item_name] = by_item.get(item_name, 0.0) + consumed
            total_cost += consumed * item.cost_per_unit
    
    return {
        "period_days": days,
        "consumption_by_item": {k: round(v, 2) for k, v in by_item.items()},
        "total_estimated_cost": round(total_cost, 2)
    }
