import pytest
import io
from datetime import date

def get_auth_headers(client):
    register_payload = {
        "name": "Import Admin",
        "phone": "+2348077773333",
        "role": "owner",
        "password": "importpass123"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    login_payload = {
        "username": "+2348077773333",
        "password": "importpass123"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_animal_csv_import_success_and_validation(client):
    headers = get_auth_headers(client)
    
    csv_content = """tag_id,species,sex,date_of_birth,breed,location,acquisition_cost,salvage_value
IMPORT-COW-01,cow,female,2021-06-15,Holstein,Paddock A,350000,70000
IMPORT-COW-02,cow,male,2020-03-10,Friesian,Paddock B,400000,80000
IMPORT-GOAT-01,goat,female,2022-11-20,Boer,Pen C,45000,10000"""
    
    # Upload CSV
    resp = client.post("/api/v1/import/animals", 
        files={"file": ("animals.csv", csv_content, "text/csv")},
        headers=headers
    )
    assert resp.status_code == 200
    result = resp.json()
    assert result["imported"] == 3
    assert result["errors_count"] == 0
    assert "IMPORT-COW-01" in result["imported_tags"]
    
    # Re-upload same CSV -> duplicates should be skipped
    resp2 = client.post("/api/v1/import/animals",
        files={"file": ("animals.csv", csv_content, "text/csv")},
        headers=headers
    )
    result2 = resp2.json()
    assert result2["imported"] == 0
    assert result2["skipped_duplicates"] == 3

def test_animal_csv_import_with_errors(client):
    headers = get_auth_headers(client)
    
    csv_content = """tag_id,species,sex,date_of_birth,acquisition_cost
IMPORT-ERR-01,cow,female,2021-06-15,350000
,cow,female,2021-06-15,350000
IMPORT-ERR-02,horse,female,2021-06-15,100000
IMPORT-ERR-03,cow,female,not-a-date,350000
IMPORT-ERR-04,cow,female,2021-06-15,-5000"""
    
    resp = client.post("/api/v1/import/animals",
        files={"file": ("animals_errors.csv", csv_content, "text/csv")},
        headers=headers
    )
    result = resp.json()
    assert result["imported"] == 1  # Only IMPORT-ERR-01 is valid
    assert result["errors_count"] >= 3  # Missing tag_id, invalid species, invalid date, negative cost

def test_transaction_csv_import(client):
    headers = get_auth_headers(client)
    
    csv_content = """transaction_type,category,amount,transaction_date,description
expense,feed,25000,2024-01-15,Monthly dairy feed
income,milk_sales,180000,2024-01-20,January milk sales
expense,medication,5000,2024-01-22,Antibiotic purchase"""
    
    resp = client.post("/api/v1/import/transactions",
        files={"file": ("transactions.csv", csv_content, "text/csv")},
        headers=headers
    )
    assert resp.status_code == 200
    result = resp.json()
    assert result["imported"] == 3
    assert result["errors_count"] == 0

def test_csv_templates(client):
    headers = get_auth_headers(client)
    
    resp1 = client.get("/api/v1/import/templates/animals", headers=headers)
    assert resp1.status_code == 200
    assert "tag_id" in resp1.text
    assert "species" in resp1.text
    
    resp2 = client.get("/api/v1/import/templates/transactions", headers=headers)
    assert resp2.status_code == 200
    assert "transaction_type" in resp2.text
    assert "category" in resp2.text
