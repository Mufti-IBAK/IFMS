from fastapi import APIRouter, Depends, HTTPException, status, Query, File, UploadFile
from sqlalchemy.orm import Session
from uuid import UUID
import os
import shutil
from typing import List, Optional

from app.core.database import get_db
from app.services.auth_service import get_current_active_user
from app.models.user import User
from app.models.animal import Animal, AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.schemas.animal import (
    AnimalCreate,
    AnimalUpdate,
    AnimalResponse,
    AnimalEventCreate,
    AnimalEventResponse
)
from app.services import animal_service

router = APIRouter()

@router.post("", response_model=AnimalResponse, status_code=status.HTTP_201_CREATED)
def create_animal_endpoint(
    animal_in: AnimalCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return animal_service.create_animal(db, animal_in)

@router.get("", response_model=List[AnimalResponse])
def list_animals_endpoint(
    species: Optional[AnimalSpecies] = None,
    status: Optional[AnimalStatus] = None,
    sex: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return animal_service.list_animals(
        db, species=species, status=status, sex=sex, skip=skip, limit=limit
    )

@router.post("/{id}/image")
def upload_animal_image(
    id: UUID,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_animal = animal_service.get_animal(db, id)
    if not db_animal:
        raise HTTPException(status_code=404, detail="Animal not found")

    file_extension = os.path.splitext(file.filename)[1]
    filename = f"animal_{id}{file_extension}"
    file_path = os.path.join("uploads", filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    db_animal.image_path = f"/uploads/{filename}"
    db.commit()

    return {"image_url": db_animal.image_path}

@router.get("/analytics/herd")
def get_herd_analytics_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    total_count = db.query(Animal).count()
    cows_count = db.query(Animal).filter(Animal.species == AnimalSpecies.COW).count()
    goats_count = db.query(Animal).filter(Animal.species == AnimalSpecies.GOAT).count()
    sheep_count = db.query(Animal).filter(Animal.species == AnimalSpecies.SHEEP).count()
    
    pregnant_count = db.query(Animal).filter(Animal.current_reproductive_status == ReproductiveStatus.PREGNANT).count()
    open_count = db.query(Animal).filter(Animal.current_reproductive_status == ReproductiveStatus.OPEN).count()
    lactating_count = db.query(Animal).filter(Animal.current_reproductive_status == ReproductiveStatus.LACTATING).count()
    dry_count = db.query(Animal).filter(Animal.current_reproductive_status == ReproductiveStatus.DRY).count()
    
    return {
        "total_animals": total_count,
        "species_breakdown": {
            "cows": cows_count,
            "goats": goats_count,
            "sheep": sheep_count
        },
        "reproductive_breakdown": {
            "pregnant": pregnant_count,
            "open": open_count,
            "lactating": lactating_count,
            "dry": dry_count
        }
    }

@router.get("/{id}", response_model=AnimalResponse)
def get_animal_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_animal = animal_service.get_animal(db, id)
    if not db_animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
    return db_animal

@router.patch("/{id}", response_model=AnimalResponse)
def update_animal_endpoint(
    id: UUID,
    animal_in: AnimalUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_animal = animal_service.get_animal(db, id)
    if not db_animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
    return animal_service.update_animal(db, db_animal, animal_in)

@router.post("/{id}/events", response_model=AnimalEventResponse, status_code=status.HTTP_201_CREATED)
def create_animal_event_endpoint(
    id: UUID,
    event_in: AnimalEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    return animal_service.create_animal_event(db, id, event_in, current_user.id)

@router.get("/{id}/events", response_model=List[AnimalEventResponse])
def get_animal_events_endpoint(
    id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Verify animal exists
    db_animal = animal_service.get_animal(db, id)
    if not db_animal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Animal not found."
        )
    return animal_service.get_animal_events(db, id)
