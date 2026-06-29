from datetime import datetime, timedelta, date
from uuid import UUID
from typing import Optional, List
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.models.animal import Animal, AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.models.animal_event import AnimalEvent, EventCategory
from app.schemas.animal import AnimalCreate, AnimalUpdate, AnimalEventCreate

def get_animal(db: Session, animal_id: UUID) -> Optional[Animal]:
    return db.query(Animal).filter(Animal.id == animal_id).first()

def get_animal_by_tag(db: Session, tag_id: str) -> Optional[Animal]:
    return db.query(Animal).filter(Animal.tag_id == tag_id).first()

def create_animal(db: Session, animal_in: AnimalCreate) -> Animal:
    if get_animal_by_tag(db, animal_in.tag_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Animal with Tag ID {animal_in.tag_id} already exists."
        )
    
    # Validate pedigree
    from app.services.breeding_service import validate_pedigree
    validate_pedigree(db, animal_in.species, animal_in.sire_id, animal_in.dam_id)
    
    db_animal = Animal(
        tag_id=animal_in.tag_id,
        species=animal_in.species,
        breed=animal_in.breed,
        sex=animal_in.sex,
        date_of_birth=animal_in.date_of_birth,
        date_of_acquisition=animal_in.date_of_acquisition,
        status=AnimalStatus.ACTIVE,
        current_reproductive_status=ReproductiveStatus.OPEN,
        sire_id=animal_in.sire_id,
        dam_id=animal_in.dam_id,
        genetic_line=animal_in.genetic_line,
        acquisition_cost=animal_in.acquisition_cost,
        salvage_value=animal_in.salvage_value
    )
    db.add(db_animal)
    db.commit()
    db.refresh(db_animal)
    return db_animal

def list_animals(
    db: Session,
    species: Optional[AnimalSpecies] = None,
    status: Optional[AnimalStatus] = None,
    sex: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
) -> List[Animal]:
    query = db.query(Animal)
    if species:
        query = query.filter(Animal.species == species)
    if status:
        query = query.filter(Animal.status == status)
    if sex:
        query = query.filter(Animal.sex == sex)
    return query.offset(skip).limit(limit).all()

def update_animal(db: Session, db_animal: Animal, animal_in: AnimalUpdate) -> Animal:
    update_data = animal_in.model_dump(exclude_unset=True)
    
    # If tag_id is being changed, check for uniqueness
    if "tag_id" in update_data and update_data["tag_id"] != db_animal.tag_id:
        if get_animal_by_tag(db, update_data["tag_id"]):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Animal with Tag ID {update_data['tag_id']} already exists."
            )
            
    # If pedigree is changing, validate it
    if "sire_id" in update_data or "dam_id" in update_data:
        sire_val = update_data.get("sire_id", db_animal.sire_id)
        dam_val = update_data.get("dam_id", db_animal.dam_id)
        from app.services.breeding_service import validate_pedigree
        validate_pedigree(db, db_animal.species, sire_val, dam_val)
        
    for field, value in update_data.items():
        setattr(db_animal, field, value)
        
    db.commit()
    db.refresh(db_animal)
    return db_animal

def create_animal_event(db: Session, animal_id: UUID, event_in: AnimalEventCreate, user_id: UUID) -> AnimalEvent:
    db_animal = get_animal(db, animal_id)
    if not db_animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
        
    # Copy payload to mutate it if needed
    payload = event_in.payload.copy()
    event_type = event_in.event_type.lower()
    
    # Validation and Reproductive calculations for females
    repro_event_types = ["mating", "ai_insemination", "calving", "pregnancy_check", "confirmed_pregnant", "abortion", "lactation_end", "dry_off"]
    if event_type in repro_event_types or event_in.event_category == EventCategory.REPRODUCTION:
        if db_animal.sex != "female":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Reproductive events can only be recorded for female animals."
            )
            
    # Mating and AI insemination calculations
    if event_type in ["mating", "ai_insemination"]:
        # Expected pregnancy check: +30 days
        check_date = event_in.event_timestamp + timedelta(days=30)
        payload["expected_pregnancy_check"] = check_date.date().isoformat()
        
        # Gestation calculations based on species
        if db_animal.species == AnimalSpecies.COW:
            calving_date = event_in.event_timestamp + timedelta(days=283)
        elif db_animal.species == AnimalSpecies.GOAT:
            calving_date = event_in.event_timestamp + timedelta(days=150)
        elif db_animal.species == AnimalSpecies.SHEEP:
            calving_date = event_in.event_timestamp + timedelta(days=147)
        else:
            calving_date = event_in.event_timestamp
            
        payload["expected_calving_date"] = calving_date.date().isoformat()
        payload["risk_flag"] = "low"
        
    # State transitions
    if event_type == "calving":
        db_animal.current_reproductive_status = ReproductiveStatus.LACTATING
        if db_animal.species == AnimalSpecies.COW:
            from app.services.dairy_service import start_lactation
            start_lactation(db, animal_id, event_in.event_timestamp.date())
    elif event_type == "confirmed_pregnant" or (event_type == "pregnancy_check" and payload.get("result") == "pregnant"):
        db_animal.current_reproductive_status = ReproductiveStatus.PREGNANT
    elif event_type in ["lactation_end", "dry_off"]:
        db_animal.current_reproductive_status = ReproductiveStatus.DRY
        if db_animal.species == AnimalSpecies.COW:
            from app.services.dairy_service import close_lactation
            close_lactation(db, animal_id, event_in.event_timestamp.date())
    elif event_type in ["abortion", "heat_detected"]:
        db_animal.current_reproductive_status = ReproductiveStatus.OPEN
        
    db_event = AnimalEvent(
        animal_id=animal_id,
        event_type=event_in.event_type,
        event_category=event_in.event_category,
        event_timestamp=event_in.event_timestamp,
        payload=payload,
        created_by=user_id
    )
    
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

def get_animal_events(db: Session, animal_id: UUID) -> List[AnimalEvent]:
    return db.query(AnimalEvent).filter(AnimalEvent.animal_id == animal_id).order_by(AnimalEvent.event_timestamp.desc()).all()

def get_reproduction_events(db: Session) -> List[AnimalEvent]:
    return db.query(AnimalEvent).filter(AnimalEvent.event_category == EventCategory.REPRODUCTION).order_by(AnimalEvent.event_timestamp.desc()).all()
