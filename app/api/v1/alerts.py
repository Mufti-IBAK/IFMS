from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.alert import RuleCreate, RuleResponse, AlertResponse
from app.services import alert_service

router = APIRouter()

@router.post("/rules", response_model=RuleResponse, status_code=status.HTTP_201_CREATED)
def create_rule_endpoint(
    rule_in: RuleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.create_rule(db, rule_in)

@router.get("/rules", response_model=List[RuleResponse])
def get_rules_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.get_rules(db)

@router.get("", response_model=List[AlertResponse])
def get_alerts_endpoint(
    severity: Optional[str] = Query(None, pattern="^(low|medium|high|critical)$"),
    status_filter: Optional[str] = Query(None, alias="status", pattern="^(open|acknowledged|resolved)$"),
    entity_type: Optional[str] = Query(None, pattern="^(animal|poultry_batch|hatchery_batch|finance)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.get_alerts(db, severity, status_filter, entity_type)

@router.post("/evaluate", response_model=List[AlertResponse])
def evaluate_alerts_endpoint(
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.evaluate_all_alerts(db, reference_date)

@router.patch("/{id}/resolve", response_model=AlertResponse)
def resolve_alert_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.resolve_alert(db, id)

@router.get("/insights/recommendations")
def get_insights_recommendations_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return alert_service.get_optimization_insights(db)
