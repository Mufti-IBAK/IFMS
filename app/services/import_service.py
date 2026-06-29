import csv
import io
from datetime import date, datetime
from uuid import UUID
from typing import List, Dict, Any, Tuple
from fastapi import HTTPException, status, UploadFile
from sqlalchemy.orm import Session

from app.models.animal import Animal, AnimalSpecies
from app.models.transaction import Transaction


ANIMAL_REQUIRED_FIELDS = ["tag_id", "species", "sex", "date_of_birth"]
ANIMAL_OPTIONAL_FIELDS = ["breed", "location", "acquisition_cost", "salvage_value", "genetic_line"]
ANIMAL_VALID_SPECIES = ["cow", "goat", "sheep"]
ANIMAL_VALID_SEX = ["male", "female"]


def _parse_csv(file_content: str) -> List[Dict[str, str]]:
    """Parse CSV content into list of row dictionaries."""
    reader = csv.DictReader(io.StringIO(file_content))
    rows = []
    for row in reader:
        # Strip whitespace from keys and values
        cleaned = {k.strip().lower(): v.strip() for k, v in row.items() if k}
        rows.append(cleaned)
    return rows


def _validate_animal_row(row: Dict[str, str], row_num: int) -> Tuple[bool, List[str]]:
    """Validate a single animal CSV row. Returns (is_valid, list_of_errors)."""
    errors = []
    
    # Check required fields
    for field in ANIMAL_REQUIRED_FIELDS:
        if field not in row or not row[field]:
            errors.append(f"Row {row_num}: Missing required field '{field}'")
    
    if errors:
        return False, errors
    
    # Validate species
    if row["species"].lower() not in ANIMAL_VALID_SPECIES:
        errors.append(f"Row {row_num}: Invalid species '{row['species']}'. Must be one of {ANIMAL_VALID_SPECIES}")
    
    # Validate sex
    if row["sex"].lower() not in ANIMAL_VALID_SEX:
        errors.append(f"Row {row_num}: Invalid sex '{row['sex']}'. Must be 'male' or 'female'")
    
    # Validate date format
    try:
        datetime.strptime(row["date_of_birth"], "%Y-%m-%d")
    except ValueError:
        errors.append(f"Row {row_num}: Invalid date_of_birth '{row['date_of_birth']}'. Expected YYYY-MM-DD")
    
    # Validate numeric fields if present
    for field in ["acquisition_cost", "salvage_value"]:
        if field in row and row[field]:
            try:
                val = float(row[field])
                if val < 0:
                    errors.append(f"Row {row_num}: {field} cannot be negative")
            except ValueError:
                errors.append(f"Row {row_num}: {field} must be a number, got '{row[field]}'")
    
    return len(errors) == 0, errors


def import_animals_from_csv(db: Session, file_content: str, user_id: UUID) -> Dict[str, Any]:
    """Import animals from CSV content. Returns summary with successes and errors."""
    rows = _parse_csv(file_content)
    
    if not rows:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="CSV file is empty or has no valid rows."
        )
    
    imported = []
    errors = []
    skipped_duplicates = []
    
    for idx, row in enumerate(rows, start=2):  # Start at 2 (row 1 is header)
        is_valid, row_errors = _validate_animal_row(row, idx)
        
        if not is_valid:
            errors.extend(row_errors)
            continue
        
        # Check for duplicate tag_id
        existing = db.query(Animal).filter(Animal.tag_id == row["tag_id"]).first()
        if existing:
            skipped_duplicates.append(f"Row {idx}: tag_id '{row['tag_id']}' already exists, skipped")
            continue
        
        # Create animal
        try:
            animal = Animal(
                tag_id=row["tag_id"],
                species=row["species"].lower(),
                sex=row["sex"].lower(),
                date_of_birth=datetime.strptime(row["date_of_birth"], "%Y-%m-%d").date(),
                breed=row.get("breed", "") or None,
                current_location_id=row.get("location", "") or None,
                acquisition_cost=float(row.get("acquisition_cost", 0) or 0),
                salvage_value=float(row.get("salvage_value", 0) or 0),
                genetic_line=row.get("genetic_line", "") or None
            )
            db.add(animal)
            db.flush()  # Flush to catch DB-level errors per row
            imported.append(row["tag_id"])
        except Exception as e:
            db.rollback()
            errors.append(f"Row {idx}: Database error - {str(e)}")
    
    if imported:
        db.commit()
    
    return {
        "total_rows": len(rows),
        "imported": len(imported),
        "skipped_duplicates": len(skipped_duplicates),
        "errors_count": len(errors),
        "imported_tags": imported,
        "duplicate_details": skipped_duplicates,
        "error_details": errors
    }


def import_transactions_from_csv(db: Session, file_content: str, user_id: UUID) -> Dict[str, Any]:
    """Import financial transactions from CSV."""
    rows = _parse_csv(file_content)
    
    if not rows:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="CSV file is empty or has no valid rows."
        )
    
    required = ["transaction_type", "category", "amount", "transaction_date"]
    valid_types = ["income", "expense"]
    valid_categories = ["milk_sales", "animal_sales", "poultry_sales", "hatchery_sales", "feed", "medication", "labor", "equipment", "utilities", "misc"]
    
    imported = []
    errors = []
    
    for idx, row in enumerate(rows, start=2):
        row_errors = []
        
        for field in required:
            if field not in row or not row[field]:
                row_errors.append(f"Row {idx}: Missing required field '{field}'")
        
        if row_errors:
            errors.extend(row_errors)
            continue
        
        if row["transaction_type"] not in valid_types:
            errors.append(f"Row {idx}: Invalid transaction_type '{row['transaction_type']}'")
            continue
        
        if row["category"] not in valid_categories:
            errors.append(f"Row {idx}: Invalid category '{row['category']}'")
            continue
        
        try:
            amount = float(row["amount"])
            if amount <= 0:
                errors.append(f"Row {idx}: amount must be positive")
                continue
        except ValueError:
            errors.append(f"Row {idx}: Invalid amount '{row['amount']}'")
            continue
        
        try:
            txn_date = datetime.strptime(row["transaction_date"], "%Y-%m-%d").date()
        except ValueError:
            errors.append(f"Row {idx}: Invalid date '{row['transaction_date']}'")
            continue
        
        try:
            txn = Transaction(
                transaction_type=row["transaction_type"],
                category=row["category"],
                amount=amount,
                description=row.get("description", "") or None,
                transaction_date=txn_date,
                created_by=user_id
            )
            db.add(txn)
            db.flush()
            imported.append(idx)
        except Exception as e:
            db.rollback()
            errors.append(f"Row {idx}: Database error - {str(e)}")
    
    if imported:
        db.commit()
    
    return {
        "total_rows": len(rows),
        "imported": len(imported),
        "errors_count": len(errors),
        "error_details": errors
    }


def get_animal_csv_template() -> str:
    """Return CSV template string for animal imports."""
    header = "tag_id,species,sex,date_of_birth,breed,location,acquisition_cost,salvage_value,genetic_line"
    example1 = "COW-001,cow,female,2020-03-15,Holstein,Paddock A,350000,70000,Holstein F1"
    example2 = "GOAT-001,goat,male,2022-01-10,Boer,Pen B,45000,10000,"
    return f"{header}\n{example1}\n{example2}"


def get_transaction_csv_template() -> str:
    """Return CSV template string for transaction imports."""
    header = "transaction_type,category,amount,transaction_date,description"
    example1 = "expense,feed,25000,2024-01-15,Monthly dairy feed purchase"
    example2 = "income,milk_sales,180000,2024-01-20,January milk sales"
    return f"{header}\n{example1}\n{example2}"
