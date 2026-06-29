from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.animal import Animal, AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.models.breeding_event import BreedingEvent
from app.models.animal_event import AnimalEvent, EventCategory
from app.schemas.breeding import BreedingEventCreate
from app.services import animal_service

def validate_pedigree(db: Session, species: AnimalSpecies, sire_id: Optional[UUID], dam_id: Optional[UUID]) -> None:
    if sire_id:
        sire = db.query(Animal).filter(Animal.id == sire_id).first()
        if not sire:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Sire with ID {sire_id} not found."
            )
        if sire.sex != "male":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Sire (ID {sire_id}) must be a male animal."
            )
        if sire.species != species:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Sire (ID {sire_id}) must be of the same species ({species.value})."
            )
            
    if dam_id:
        dam = db.query(Animal).filter(Animal.id == dam_id).first()
        if not dam:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Dam with ID {dam_id} not found."
            )
        if dam.sex != "female":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Dam (ID {dam_id}) must be a female animal."
            )
        if dam.species != species:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Dam (ID {dam_id}) must be of the same species ({species.value})."
            )

def create_breeding_event(db: Session, event_in: BreedingEventCreate, user_id: UUID) -> BreedingEvent:
    # 1. Verify animal exists and is female
    animal = db.query(Animal).filter(Animal.id == event_in.animal_id).first()
    if not animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
        
    if animal.sex != "female":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Reproductive/breeding events can only be recorded for female animals."
        )
        
    # 2. Write corresponding AnimalEvent row (timeline) via animal_service.
    # This automatically runs reproductive state transitions and calving/dry-off triggers.
    from app.schemas.animal import AnimalEventCreate
    
    payload = {}
    if event_in.result:
        payload["result"] = event_in.result
    if event_in.notes:
        payload["notes"] = event_in.notes
        
    animal_event_in = AnimalEventCreate(
        event_type=event_in.event_type,
        event_category=EventCategory.REPRODUCTION,
        event_timestamp=datetime.combine(event_in.event_date, datetime.utcnow().time()),
        payload=payload
    )
    
    # This call performs gestation calculations and updates current_reproductive_status
    db_animal_event = animal_service.create_animal_event(db, event_in.animal_id, animal_event_in, user_id)
    
    # Override current_reproductive_status based on BGS lifecycle flow
    e_type = event_in.event_type.lower()
    if e_type == "heat":
        animal.current_reproductive_status = ReproductiveStatus.IN_HEAT
    elif e_type in ["mating", "ai_insemination"]:
        animal.current_reproductive_status = ReproductiveStatus.SERVICED
    elif e_type == "confirmed_pregnant" or (e_type == "pregnancy_check" and event_in.result == "pregnant"):
        animal.current_reproductive_status = ReproductiveStatus.PREGNANT
    elif e_type == "abortion" or (e_type == "pregnancy_check" and event_in.result == "open"):
        animal.current_reproductive_status = ReproductiveStatus.OPEN
    elif e_type == "calving":
        animal.current_reproductive_status = ReproductiveStatus.LACTATING
        
    # 3. Create the normalized BreedingEvent
    db_breeding_event = BreedingEvent(
        animal_id=event_in.animal_id,
        event_type=event_in.event_type,
        event_date=event_in.event_date,
        result=event_in.result,
        notes=event_in.notes,
        created_by=user_id
    )
    db.add(db_breeding_event)
    db.commit()
    db.refresh(db_breeding_event)
    return db_breeding_event

def get_animal_breeding_timeline(db: Session, animal_id: UUID) -> List[BreedingEvent]:
    return db.query(BreedingEvent).filter(BreedingEvent.animal_id == animal_id).order_by(BreedingEvent.event_date.desc()).all()

def get_breeding_calendar(db: Session, reference_date: Optional[date] = None) -> Dict[str, Any]:
    if not reference_date:
        reference_date = date.today()
        
    pregnancy_checks_due = []
    upcoming_calvings = []
    overdue_calvings = []
    open_cows = []
    
    # Query all active female animals
    females = db.query(Animal).filter(
        Animal.status == AnimalStatus.ACTIVE,
        Animal.sex == "female"
    ).all()
    
    for f in females:
        # Load latest reproduction events
        latest_service_event = db.query(AnimalEvent).filter(
            AnimalEvent.animal_id == f.id,
            AnimalEvent.event_category == EventCategory.REPRODUCTION,
            (
                func.lower(AnimalEvent.event_type) == "mating" or
                func.lower(AnimalEvent.event_type) == "ai_insemination"
            )
        ).order_by(AnimalEvent.event_timestamp.desc()).first()
        
        # 1. Pregnancy Check Due
        if f.current_reproductive_status == ReproductiveStatus.SERVICED and latest_service_event:
            payload = latest_service_event.payload or {}
            check_date_str = payload.get("expected_pregnancy_check")
            if check_date_str:
                check_date = date.fromisoformat(check_date_str)
                # Check is due if the date is today or has passed
                if check_date <= reference_date:
                    # Verify no pregnancy check has been done since the service date
                    latest_check = db.query(AnimalEvent).filter(
                        AnimalEvent.animal_id == f.id,
                        func.lower(AnimalEvent.event_type) == "pregnancy_check",
                        AnimalEvent.event_timestamp > latest_service_event.event_timestamp
                    ).first()
                    
                    if not latest_check:
                        pregnancy_checks_due.append({
                            "animal_id": f.id,
                            "tag_id": f.tag_id,
                            "species": f.species,
                            "service_date": latest_service_event.event_timestamp.date().isoformat(),
                            "pregnancy_check_due_date": check_date.isoformat(),
                            "days_since_service": (reference_date - latest_service_event.event_timestamp.date()).days
                        })
                        
        # 2. Upcoming Calving & Dystocia Risk
        if f.current_reproductive_status == ReproductiveStatus.PREGNANT and latest_service_event:
            payload = latest_service_event.payload or {}
            calving_date_str = payload.get("expected_calving_date")
            if calving_date_str:
                calving_date = date.fromisoformat(calving_date_str)
                
                # Overdue by > 7 days -> Dystocia risk
                if calving_date + timedelta(days=7) < reference_date:
                    overdue_calvings.append({
                        "animal_id": f.id,
                        "tag_id": f.tag_id,
                        "species": f.species,
                        "expected_calving_date": calving_date.isoformat(),
                        "days_overdue": (reference_date - calving_date).days
                    })
                # Upcoming within 30 days
                elif reference_date <= calving_date <= reference_date + timedelta(days=30):
                    upcoming_calvings.append({
                        "animal_id": f.id,
                        "tag_id": f.tag_id,
                        "species": f.species,
                        "expected_calving_date": calving_date.isoformat(),
                        "days_until_calving": (calving_date - reference_date).days
                    })
                    
        # Female is open if she calved > 90 days ago and is still OPEN / not serviced (lactating counts as open for breeding)
        if f.current_reproductive_status in [ReproductiveStatus.OPEN, ReproductiveStatus.IN_HEAT, ReproductiveStatus.LACTATING]:
            latest_calving = db.query(AnimalEvent).filter(
                AnimalEvent.animal_id == f.id,
                func.lower(AnimalEvent.event_type) == "calving"
            ).order_by(AnimalEvent.event_timestamp.desc()).first()
            
            if latest_calving:
                calving_day = latest_calving.event_timestamp.date()
                days_open = (reference_date - calving_day).days
                if days_open > 90:
                    open_cows.append({
                        "animal_id": f.id,
                        "tag_id": f.tag_id,
                        "species": f.species,
                        "last_calving_date": calving_day.isoformat(),
                        "days_open": days_open
                    })
                    
    return {
        "pregnancy_checks_due": pregnancy_checks_due,
        "upcoming_calvings": upcoming_calvings,
        "overdue_calvings_alert": overdue_calvings,
        "open_cows_alert": open_cows
    }

def get_breeding_kpi_herd(db: Session) -> Dict[str, Any]:
    # Conception Rate: total successful pregnancy checks / total mating or AI events
    total_services = db.query(BreedingEvent).filter(
        BreedingEvent.event_type.in_(["mating", "ai_insemination"])
    ).count()
    
    total_conceptions = db.query(BreedingEvent).filter(
        BreedingEvent.event_type == "pregnancy_check",
        BreedingEvent.result == "pregnant"
    ).count()
    
    conception_rate = (total_conceptions / total_services * 100.0) if total_services > 0 else 0.0
    
    # Heat events count (heat detection efficiency indicator)
    total_heats = db.query(BreedingEvent).filter(BreedingEvent.event_type == "heat").count()
    
    # Pregnancy rate
    total_females = db.query(Animal).filter(Animal.sex == "female", Animal.status == AnimalStatus.ACTIVE).count()
    pregnant_females = db.query(Animal).filter(Animal.sex == "female", Animal.current_reproductive_status == ReproductiveStatus.PREGNANT).count()
    pregnancy_rate = (pregnant_females / total_females * 100.0) if total_females > 0 else 0.0
    
    return {
        "overall_conception_rate_percent": round(conception_rate, 2),
        "total_services_logged": total_services,
        "total_conceptions_logged": total_conceptions,
        "total_heat_events_logged": total_heats,
        "herd_pregnancy_rate_percent": round(pregnancy_rate, 2),
        "total_active_breeding_females": total_females
    }

def get_breeding_kpi_animal(db: Session, animal_id: UUID) -> Dict[str, Any]:
    # Query all mating / AI services for this animal
    services = db.query(BreedingEvent).filter(
        BreedingEvent.animal_id == animal_id,
        BreedingEvent.event_type.in_(["mating", "ai_insemination"])
    ).order_by(BreedingEvent.event_date.desc()).all()
    
    total_services = len(services)
    
    # Conception count
    conceptions = db.query(BreedingEvent).filter(
        BreedingEvent.animal_id == animal_id,
        BreedingEvent.event_type == "pregnancy_check",
        BreedingEvent.result == "pregnant"
    ).count()
    
    services_per_conception = total_services / conceptions if conceptions > 0 else total_services
    conception_rate = (conceptions / total_services * 100.0) if total_services > 0 else 0.0
    
    # Days Open
    days_open = 0
    # Find latest calving
    latest_calving = db.query(BreedingEvent).filter(
        BreedingEvent.animal_id == animal_id,
        BreedingEvent.event_type == "calving"
    ).order_by(BreedingEvent.event_date.desc()).first()
    
    # Find latest confirmed pregnancy after that calving
    if latest_calving:
        latest_conception = db.query(BreedingEvent).filter(
            BreedingEvent.animal_id == animal_id,
            BreedingEvent.event_type == "pregnancy_check",
            BreedingEvent.result == "pregnant",
            BreedingEvent.event_date > latest_calving.event_date
        ).order_by(BreedingEvent.event_date.asc()).first()
        
        if latest_conception:
            days_open = (latest_conception.event_date - latest_calving.event_date).days
        else:
            days_open = (date.today() - latest_calving.event_date).days
            
    return {
        "total_services": total_services,
        "conceptions": conceptions,
        "services_per_conception": round(services_per_conception, 2),
        "conception_rate_percent": round(conception_rate, 2),
        "days_open": days_open
    }
