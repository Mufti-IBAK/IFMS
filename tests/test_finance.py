import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Finance M5",
        "phone": "+2348055556666",
        "role": "vet",
        "password": "vetpasswordxyz"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348055556666",
        "password": "vetpasswordxyz"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_depreciation_and_overhead_allocation(client):
    headers = get_auth_headers(client)
    
    # 1. Register a female cow with financial metrics, born exactly 4 years ago
    dob = date.today() - timedelta(days=int(4 * 365.25))
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-FIN-01", 
        "species": "cow", 
        "sex": "female", 
        "date_of_birth": dob.isoformat(),
        "acquisition_cost": 400000.0,
        "salvage_value": 80000.0
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # Useful life = 8 years, age = 4.0 years
    # Annual depr = (400,000 - 80,000) / 8 = 40,000
    # Cumulative depr = 4 * 40,000 = 160,000
    # Book value = 400,000 - 160,000 = 240,000
    
    summary = client.get(f"/api/v1/finance/profit/animal/{cow_id}", headers=headers).json()
    assert summary["depreciation"]["current_book_value"] == 240000.0
    assert summary["depreciation"]["annual_depreciation"] == 40000.0
    assert summary["total_costs"] == 0.0

    # 2. Log general labor overhead expense of 100,000 NGN today (related_entity_type = None)
    client.post("/api/v1/finance/transaction", json={
        "transaction_type": "expense",
        "category": "labor",
        "amount": 100000.0,
        "transaction_date": date.today().isoformat(),
        "description": "General farm labor wages"
    }, headers=headers)
    
    # Since COW-FIN-01 is the only active unit, 100% of the overhead is allocated to her
    summary2 = client.get(f"/api/v1/finance/profit/animal/{cow_id}", headers=headers).json()
    assert summary2["labor_cost"] == 100000.0
    assert summary2["total_costs"] == 100000.0
    assert summary2["net_profit"] == -100000.0

def test_direct_transactions_and_culling_warnings(client):
    headers = get_auth_headers(client)
    
    # Register cow, born 2 years ago
    dob = date.today() - timedelta(days=int(2 * 365.25))
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-FIN-02", 
        "species": "cow", 
        "sex": "female", 
        "date_of_birth": dob.isoformat(),
        "acquisition_cost": 200000.0,
        "salvage_value": 40000.0
    }, headers=headers).json()
    cow_id = cow["id"]

    # 1. Log direct feed expense of 20,000 NGN on the cow
    client.post("/api/v1/finance/transaction", json={
        "transaction_type": "expense",
        "category": "feed",
        "amount": 20000.0,
        "related_entity_type": "animal",
        "related_entity_id": cow_id,
        "transaction_date": date.today().isoformat(),
        "description": "Premium dairy feed"
    }, headers=headers)

    # 2. Log direct milk sales income of 150,000 NGN on the cow
    client.post("/api/v1/finance/transaction", json={
        "transaction_type": "income",
        "category": "milk_sales",
        "amount": 150000.0,
        "related_entity_type": "animal",
        "related_entity_id": cow_id,
        "transaction_date": date.today().isoformat(),
        "description": "Milk production sales"
    }, headers=headers)

    summary = client.get(f"/api/v1/finance/profit/animal/{cow_id}", headers=headers).json()
    assert summary["feed_cost"] == 20000.0
    assert summary["direct_revenue"] == 150000.0
    
    # 3. Log health treatment expense of 110,000 NGN (exceeds 50% of 200,000 acquisition cost)
    client.post("/api/v1/finance/transaction", json={
        "transaction_type": "expense",
        "category": "medication",
        "amount": 110000.0,
        "related_entity_type": "animal",
        "related_entity_id": cow_id,
        "transaction_date": date.today().isoformat(),
        "description": "Mastitis complex treatment"
    }, headers=headers)

    # Check culling board
    culling_board = client.get("/api/v1/finance/culling-analysis", headers=headers).json()
    # Find COW-FIN-02
    target = next((c for c in culling_board if c["tag_id"] == "COW-FIN-02"), None)
    assert target is not None
    assert target["health_loss"] is True
    assert "Chronic Health Costs" in target["reasons"]

    # 4. Log calving event and wait 160 days -> reproductive failure warning
    calving_date = date.today() - timedelta(days=160)
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(calving_date, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)

    culling_board_post = client.get("/api/v1/finance/culling-analysis", headers=headers).json()
    target_post = next((c for c in culling_board_post if c["tag_id"] == "COW-FIN-02"), None)
    assert target_post is not None
    assert target_post["reproductive_failure"] is True
    assert "Extended Open Days (>150d)" in target_post["reasons"]
