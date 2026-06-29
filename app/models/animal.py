from sqlalchemy import Column, String, Date, Enum as SQLEnum, ForeignKey, Float
from app.models.base import BaseModel, GUID
import enum

class AnimalSpecies(str, enum.Enum):
    COW = "cow"
    GOAT = "goat"
    SHEEP = "sheep"

class AnimalStatus(str, enum.Enum):
    ACTIVE = "active"
    SOLD = "sold"
    DEAD = "dead"
    QUARANTINED = "quarantined"

class ReproductiveStatus(str, enum.Enum):
    OPEN = "open"
    PREGNANT = "pregnant"
    LACTATING = "lactating"
    DRY = "dry"
    HEIFER = "heifer"
    IN_HEAT = "in_heat"
    SERVICED = "serviced"
    JUVENILE = "juvenile"

class Animal(BaseModel):
    __tablename__ = "animals"
    
    tag_id = Column(String(50), unique=True, index=True, nullable=False)
    species = Column(SQLEnum(AnimalSpecies, native_enum=False), nullable=False)
    breed = Column(String(100), nullable=True)
    sex = Column(String(10), nullable=False) # "male" or "female"
    date_of_birth = Column(Date, nullable=False)
    date_of_acquisition = Column(Date, nullable=True)
    status = Column(SQLEnum(AnimalStatus, native_enum=False), nullable=False, default=AnimalStatus.ACTIVE)
    
    current_location_id = Column(String(50), nullable=True)
    current_reproductive_status = Column(
        SQLEnum(ReproductiveStatus, native_enum=False), 
        nullable=False, 
        default=ReproductiveStatus.OPEN
    )
    
    sire_id = Column(GUID(), nullable=True)
    dam_id = Column(GUID(), nullable=True)
    genetic_line = Column(String(100), nullable=True)
    
    acquisition_cost = Column(Float, nullable=False, default=0.0)
    salvage_value = Column(Float, nullable=False, default=0.0)
    image_path = Column(String(255), nullable=True)
