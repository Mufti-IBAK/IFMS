from fastapi import APIRouter, Depends, HTTPException, status, Query, Response
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import date
from typing import List, Optional, Dict, Any

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.schemas.dairy import MilkRecordCreate, MilkRecordResponse, LactationResponse
from app.services import dairy_service, report_service

router = APIRouter()

@router.get("/reports/production/pdf")
def get_dairy_pdf_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    from app.services import animal_service
    animals = animal_service.list_animals(db)
    pdf_buffer = report_service.generate_herd_pdf(animals)
    return Response(
        content=pdf_buffer.getvalue(),
        media_type="application/pdf",
        headers={"Content-Disposition": "attachment; filename=dairy_report.pdf"}
    )

@router.post("/milk", response_model=MilkRecordResponse, status_code=status.HTTP_201_CREATED)
def create_milk_record_endpoint(
    record_in: MilkRecordCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.create_milk_record(db, record_in, current_user.id)

@router.get("/milk", response_model=List[MilkRecordResponse])
def get_milk_records_endpoint(
    animal_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_milk_records(db, animal_id)

@router.get("/lactation/{animal_id}", response_model=List[LactationResponse])
def get_lactation_history_endpoint(
    animal_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_lactation_history(db, animal_id)

@router.get("/kpi/herd")
def get_herd_kpis_endpoint(
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_herd_dairy_kpis(db, reference_date)

@router.get("/kpi/animal/{id}")
def get_animal_kpis_endpoint(
    id: UUID,
    reference_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_animal_dairy_kpis(db, id, reference_date)

@router.get("/profit/summary")
def get_profit_summary_endpoint(
    milk_price: float = Query(500.0, ge=0.0),
    feed_cost: float = Query(1500.0, ge=0.0),
    target_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_dairy_profitability_summary(
        db, milk_price=milk_price, feed_cost=feed_cost, target_date=target_date
    )

@router.get("/profit/by-animal")
def get_profit_by_animal_endpoint(
    milk_price: float = Query(500.0, ge=0.0),
    feed_cost: float = Query(1500.0, ge=0.0),
    target_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return dairy_service.get_dairy_profitability_by_animal(
        db, milk_price=milk_price, feed_cost=feed_cost, target_date=target_date
    )
