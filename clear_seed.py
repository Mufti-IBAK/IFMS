import sys
import os

sys.path.append(os.getcwd())

from app.core.database import SessionLocal
from app.models.animal import Animal

def clear_seed():
    db = SessionLocal()
    try:
        # Delete dummy animals
        cow = db.query(Animal).filter(Animal.tag_id == "COW-402").first()
        if cow: db.delete(cow)
        
        goat = db.query(Animal).filter(Animal.tag_id == "GAT-089").first()
        if goat: db.delete(goat)
        
        db.commit()
        print("Seed data successfully removed from database!")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    clear_seed()
