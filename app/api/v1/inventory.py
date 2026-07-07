from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.inventory import (
    FeedItemCreate, FeedItemResponse, FeedItemUpdate,
    InventoryLogCreate, InventoryLogResponse
)
from app.services import inventory_service

router = APIRouter()

@router.post("/items", response_model=FeedItemResponse, status_code=201)
def create_feed_item_endpoint(
    item_in: FeedItemCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.create_feed_item(db, item_in, current_user.id)

@router.get("/items", response_model=List[FeedItemResponse])
def get_feed_items_endpoint(
    category: Optional[str] = None,
    active_only: bool = True,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.get_feed_items(db, category, active_only)

@router.get("/items/{id}", response_model=FeedItemResponse)
def get_feed_item_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.get_feed_item(db, id)

@router.patch("/items/{id}", response_model=FeedItemResponse)
def update_feed_item_endpoint(
    id: UUID,
    update_in: FeedItemUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.update_feed_item(db, id, update_in)

@router.post("/log", response_model=InventoryLogResponse, status_code=201)
def log_inventory_change_endpoint(
    log_in: InventoryLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.log_inventory_change(db, log_in, current_user.id)

@router.get("/logs", response_model=List[InventoryLogResponse])
def get_inventory_logs_endpoint(
    item_id: Optional[UUID] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.get_inventory_logs(db, item_id, start_date, end_date)

@router.get("/low-stock")
def get_low_stock_alerts_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.get_low_stock_alerts(db)

@router.get("/consumption-summary")
def get_consumption_summary_endpoint(
    days: int = Query(30, ge=1, le=365),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return inventory_service.get_consumption_summary(db, days)

@router.delete("/items/{id}", status_code=204)
def delete_feed_item_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    from app.schemas.inventory import FeedItemUpdate
    inventory_service.update_feed_item(db, id, FeedItemUpdate(is_active=False))
    return None
