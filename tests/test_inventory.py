import pytest
from datetime import date, timedelta

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Inventory",
        "phone": "+2348077771111",
        "role": "vet",
        "password": "vetpassinv123"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    login_payload = {
        "username": "+2348077771111",
        "password": "vetpassinv123"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_feed_item_crud_and_duplicate_check(client):
    headers = get_auth_headers(client)
    
    # Create a feed item
    resp = client.post("/api/v1/inventory/items", json={
        "name": "Dairy Pellets Premium",
        "category": "feed",
        "unit": "kg",
        "current_stock": 500.0,
        "reorder_threshold": 100.0,
        "cost_per_unit": 350.0,
        "supplier": "AgriFeeds Nigeria"
    }, headers=headers)
    assert resp.status_code == 201
    item = resp.json()
    assert item["name"] == "Dairy Pellets Premium"
    assert item["current_stock"] == 500.0
    item_id = item["id"]
    
    # Duplicate name should fail
    resp2 = client.post("/api/v1/inventory/items", json={
        "name": "Dairy Pellets Premium",
        "category": "feed",
        "unit": "kg"
    }, headers=headers)
    assert resp2.status_code == 400
    
    # List items
    resp3 = client.get("/api/v1/inventory/items", headers=headers)
    assert resp3.status_code == 200
    assert len(resp3.json()) >= 1
    
    # Get single item
    resp4 = client.get(f"/api/v1/inventory/items/{item_id}", headers=headers)
    assert resp4.status_code == 200
    assert resp4.json()["name"] == "Dairy Pellets Premium"
    
    # Update item
    resp5 = client.patch(f"/api/v1/inventory/items/{item_id}", json={
        "cost_per_unit": 400.0,
        "supplier": "AgriFeeds Premium"
    }, headers=headers)
    assert resp5.status_code == 200
    assert resp5.json()["cost_per_unit"] == 400.0

def test_inventory_log_stock_tracking(client):
    headers = get_auth_headers(client)
    
    # Create a drug item with low initial stock
    resp = client.post("/api/v1/inventory/items", json={
        "name": "Oxytetracycline 20%",
        "category": "drug",
        "unit": "bottles",
        "current_stock": 5.0,
        "reorder_threshold": 10.0,
        "cost_per_unit": 2500.0
    }, headers=headers)
    assert resp.status_code == 201
    item_id = resp.json()["id"]
    
    # Purchase 20 bottles
    resp2 = client.post("/api/v1/inventory/log", json={
        "item_id": item_id,
        "change_type": "purchase",
        "quantity_change": 20.0,
        "log_date": date.today().isoformat(),
        "notes": "Monthly restock"
    }, headers=headers)
    assert resp2.status_code == 201
    assert resp2.json()["balance_after"] == 25.0  # 5 + 20
    
    # Consume 3 bottles for a cow
    resp3 = client.post("/api/v1/inventory/log", json={
        "item_id": item_id,
        "change_type": "consumption",
        "quantity_change": 3.0,
        "related_entity_type": "animal",
        "log_date": date.today().isoformat(),
        "notes": "Treatment for COW-001"
    }, headers=headers)
    assert resp3.status_code == 201
    assert resp3.json()["balance_after"] == 22.0  # 25 - 3
    
    # Verify stock updated on item
    resp4 = client.get(f"/api/v1/inventory/items/{item_id}", headers=headers)
    assert resp4.json()["current_stock"] == 22.0
    
    # Try to consume more than available
    resp5 = client.post("/api/v1/inventory/log", json={
        "item_id": item_id,
        "change_type": "consumption",
        "quantity_change": 50.0,
        "log_date": date.today().isoformat()
    }, headers=headers)
    assert resp5.status_code == 400
    assert "insufficient stock" in resp5.json()["detail"].lower()

def test_low_stock_alerts_and_consumption_summary(client):
    headers = get_auth_headers(client)
    
    # Create item below reorder threshold
    client.post("/api/v1/inventory/items", json={
        "name": "Albendazole Suspension",
        "category": "drug",
        "unit": "liters",
        "current_stock": 2.0,
        "reorder_threshold": 5.0,
        "cost_per_unit": 3000.0
    }, headers=headers)
    
    # Check low stock alerts
    resp = client.get("/api/v1/inventory/low-stock", headers=headers)
    assert resp.status_code == 200
    alerts = resp.json()
    low_items = [a for a in alerts if a["name"] == "Albendazole Suspension"]
    assert len(low_items) == 1
    assert low_items[0]["deficit"] == 3.0  # 5.0 - 2.0
    
    # Check consumption summary
    resp2 = client.get("/api/v1/inventory/consumption-summary?days=30", headers=headers)
    assert resp2.status_code == 200
    assert "consumption_by_item" in resp2.json()
    assert "total_estimated_cost" in resp2.json()
