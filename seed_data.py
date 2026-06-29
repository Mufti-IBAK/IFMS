import sys
import os
from datetime import datetime, date, timedelta
from uuid import uuid4

# Add the current directory to sys.path to import app
sys.path.append(os.getcwd())

from app.core.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.animal import Animal, AnimalSpecies, AnimalStatus, ReproductiveStatus
from app.models.poultry_batch import PoultryBatch
from app.models.task import Task
from app.models.alert import Alert
from app.models.device import DeviceToken
from app.models.milk_record import MilkRecord
from app.models.transaction import Transaction
from app.core.roles import UserRole
from app.core.security import get_password_hash

def seed():
    # Ensure tables are created
    print("Ensuring database tables exist...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # 1. Create Default User
        admin_phone = "08012345678"
        admin = db.query(User).filter(User.phone == admin_phone).first()
        if not admin:
            print("Creating default admin user...")
            admin = User(
                id=uuid4(),
                name="Farm Owner",
                phone=admin_phone,
                password_hash=get_password_hash("password123"),
                role=UserRole.OWNER,
                is_active=True
            )
            db.add(admin)
            db.commit()
            db.refresh(admin)

        # 2. Create Animals
        if db.query(Animal).count() == 0:
            print("Seeding animals...")
            animals = [
                Animal(
                    id=uuid4(),
                    tag_id="COW-402",
                    species=AnimalSpecies.COW,
                    breed="Holstein Friesian",
                    sex="female",
                    date_of_birth=date.today() - timedelta(days=800),
                    status=AnimalStatus.ACTIVE,
                    current_reproductive_status=ReproductiveStatus.LACTATING,
                    acquisition_cost=250000.0
                ),
                Animal(
                    id=uuid4(),
                    tag_id="GAT-089",
                    species=AnimalSpecies.GOAT,
                    breed="Boer Goat",
                    sex="male",
                    date_of_birth=date.today() - timedelta(days=400),
                    status=AnimalStatus.ACTIVE,
                    current_reproductive_status=ReproductiveStatus.OPEN,
                    acquisition_cost=45000.0
                ),
            ]
            db.add_all(animals)

        # 3. Create Poultry Batch
        if db.query(PoultryBatch).count() == 0:
            print("Seeding poultry...")
            batch = PoultryBatch(
                id=uuid4(),
                batch_type="broiler",
                breed="Cobb 500",
                start_date=date.today() - timedelta(days=28),
                initial_count=5000,
                current_count=4930,
                status="active",
                location_id="House A",
                created_by=admin.id
            )
            db.add(batch)

        # 4. Create Tasks
        if db.query(Task).count() == 0:
            print("Seeding tasks...")
            tasks = [
                Task(
                    id=uuid4(),
                    title="Vaccinate Herd",
                    description="Routine FMD vaccination for all cattle",
                    priority="high",
                    status="pending",
                    assigned_by=admin.id,
                    due_date=date.today() + timedelta(days=2)
                ),
                Task(
                    id=uuid4(),
                    title="Clean Poultry House A",
                    description="Standard weekly cleaning protocol",
                    priority="medium",
                    status="in_progress",
                    assigned_by=admin.id,
                    due_date=date.today()
                ),
            ]
            db.add_all(tasks)

        # 5. Create Alerts
        if db.query(Alert).count() == 0:
            print("Seeding alerts...")
            alerts = [
                Alert(
                    id=uuid4(),
                    entity_type="poultry_batch",
                    alert_type="health_alert",
                    severity="critical",
                    message="Poultry mortality spike in House A. ₦450k revenue at risk.",
                    status="open"
                ),
                Alert(
                    id=uuid4(),
                    entity_type="animal",
                    alert_type="production_alert",
                    severity="medium",
                    message="Anomalous milk drop for #COW-402 (-35%).",
                    status="open"
                ),
            ]
            db.add_all(alerts)

        db.commit()
        print("Seeding completed successfully!")
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed()
