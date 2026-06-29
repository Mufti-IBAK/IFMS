import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Alerts M6",
        "phone": "+2348066667777",
        "role": "vet",
        "password": "vetpassword123"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348066667777",
        "password": "vetpassword123"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_milk_drop_and_anomaly_alerts(client):
    headers = get_auth_headers(client)
    
    # 1. Register a female cow
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-AL-01", 
        "species": "cow", 
        "sex": "female", 
        "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]

    # Post a calving event 20 days ago to start a lactation
    calving_date = date.today() - timedelta(days=20)
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(calving_date, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)

    # 2. Seed 14 days of stable milk records preceding today (alternating 10.0 L and 12.0 L)
    today = date.today()
    for i in range(1, 15):
        rec_date = today - timedelta(days=i)
        val = 10.0 if i % 2 == 0 else 12.0
        client.post("/api/v1/dairy/milk", json={
            "animal_id": cow_id,
            "record_date": rec_date.isoformat(),
            "milking_session": "morning",
            "quantity_liters": val
        }, headers=headers)

    # 3. Log an extreme milk drop today (only 2.0 L)
    client.post("/api/v1/dairy/milk", json={
        "animal_id": cow_id,
        "record_date": today.isoformat(),
        "milking_session": "morning",
        "quantity_liters": 2.0
    }, headers=headers)

    # 4. Trigger alert evaluation
    client.post(f"/api/v1/alerts/evaluate?reference_date={today.isoformat()}", headers=headers)

    # Fetch alerts
    alerts = client.get("/api/v1/alerts", headers=headers).json()
    
    # We expect two production alerts:
    # - Medium severity (deterministic drop > 20%)
    # - High severity (statistical deviation > 2 std dev)
    prod_alerts = [a for a in alerts if a["alert_type"] == "production_alert" and a["entity_id"] == cow_id]
    assert len(prod_alerts) == 2
    assert any(a["severity"] == "medium" for a in prod_alerts)
    assert any(a["severity"] == "high" for a in prod_alerts)

def test_chronic_illness_and_poultry_mortality_alerts(client):
    headers = get_auth_headers(client)
    
    # Register animal
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-AL-02", 
        "species": "cow", 
        "sex": "female", 
        "date_of_birth": "2023-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]

    # 1. Log 3 health treatments in the last 3 days
    today = date.today()
    for i in range(3):
        t_date = today - timedelta(days=i)
        client.post(f"/api/v1/animals/{cow_id}/events", json={
            "event_type": "treatment_antibiotic",
            "event_category": "health",
            "event_timestamp": datetime.combine(t_date, datetime.min.time()).isoformat(),
            "payload": {"treatment_type": "antibiotic", "cost": 5000.0}
        }, headers=headers)

    # 2. Create poultry batch of 1000 chicks
    batch = client.post("/api/v1/poultry/batch", json={
        "batch_type": "broiler",
        "breed": "Arbor Acres",
        "start_date": today.isoformat(),
        "initial_count": 1000,
        "initial_chick_cost": 50000.0
    }, headers=headers).json()
    batch_id = batch["id"]

    # 3. Log poultry mortality of 25 dead birds today (2.5% > 2%)
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "mortality",
        "event_date": today.isoformat(),
        "quantity": 25.0
    }, headers=headers)

    # Evaluate
    client.post(f"/api/v1/alerts/evaluate?reference_date={today.isoformat()}", headers=headers)

    # Verify chronic illness alert
    alerts = client.get("/api/v1/alerts", headers=headers).json()
    health_alerts = [a for a in alerts if a["alert_type"] == "health_alert" and a["status"] == "open"]
    assert len(health_alerts) >= 2 # one chronic animal, one critical poultry
    
    # Critical poultry alert verify
    poultry_alert = next((a for a in health_alerts if a["entity_type"] == "poultry_batch"), None)
    assert poultry_alert is not None
    assert poultry_alert["severity"] == "critical"
    
    # Resolve the critical alert
    r_alert = client.patch(f"/api/v1/alerts/{poultry_alert['id']}/resolve", headers=headers).json()
    assert r_alert["status"] == "resolved"
    assert r_alert["resolved_at"] is not None

def test_insights_recommendations(client):
    headers = get_auth_headers(client)
    
    # Trigger evaluate to clear/run on current state, which leaves some alerts open
    today = date.today()
    client.post(f"/api/v1/alerts/evaluate?reference_date={today.isoformat()}", headers=headers)
    
    # Fetch insights
    recs = client.get("/api/v1/alerts/insights/recommendations", headers=headers).json()
    # Check that recommendation suggestions contains actionable lists
    if len(recs) > 0:
        first = recs[0]
        assert "recommendations" in first
        assert len(first["recommendations"]) > 0
