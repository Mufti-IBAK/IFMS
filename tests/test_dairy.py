import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    # Register & Login helper
    register_payload = {
        "name": "Vet Admin M2",
        "phone": "+2348022223333",
        "role": "vet",
        "password": "vetpassword456"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348022223333",
        "password": "vetpassword456"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_lactation_triggers_on_calving_and_dryoff(client):
    headers = get_auth_headers(client)
    
    # 1. Register a female cow
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-LAC-01", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # Verify no lactation exists yet
    history_resp = client.get(f"/api/v1/dairy/lactation/{cow_id}", headers=headers)
    assert history_resp.status_code == 200
    assert len(history_resp.json()) == 0

    # 2. Post calving event -> start lactation 1
    calving_date = date.today() - timedelta(days=10)
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(calving_date, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)
    
    history1 = client.get(f"/api/v1/dairy/lactation/{cow_id}", headers=headers).json()
    assert len(history1) == 1
    assert history1[0]["lactation_number"] == 1
    assert history1[0]["status"] == "active"
    assert history1[0]["start_date"] == calving_date.isoformat()
    assert history1[0]["end_date"] is None

    # 3. Post another calving event -> close lactation 1, start lactation 2
    calving_date2 = date.today() - timedelta(days=2)
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(calving_date2, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)
    
    history2 = client.get(f"/api/v1/dairy/lactation/{cow_id}", headers=headers).json()
    assert len(history2) == 2
    # Ordered descending by lactation number
    assert history2[0]["lactation_number"] == 2
    assert history2[0]["status"] == "active"
    assert history2[0]["start_date"] == calving_date2.isoformat()
    
    assert history2[1]["lactation_number"] == 1
    assert history2[1]["status"] == "completed"
    assert history2[1]["end_date"] == (calving_date2 - timedelta(days=1)).isoformat()

    # 4. Post dry off event -> close lactation 2
    dry_date = date.today()
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "dry_off",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(dry_date, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)
    
    history3 = client.get(f"/api/v1/dairy/lactation/{cow_id}", headers=headers).json()
    assert len(history3) == 2
    assert history3[0]["lactation_number"] == 2
    assert history3[0]["status"] == "completed"
    assert history3[0]["end_date"] == dry_date.isoformat()

def test_milk_logging_and_drug_withdrawal(client):
    headers = get_auth_headers(client)
    
    # Register cow
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-MILK-01", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # 1. Log a normal milk record
    milk1 = {
        "animal_id": cow_id,
        "record_date": date.today().isoformat(),
        "milking_session": "morning",
        "quantity_liters": 12.5
    }
    resp1 = client.post("/api/v1/dairy/milk", json=milk1, headers=headers)
    assert resp1.status_code == 201
    assert resp1.json()["is_withdrawn"] is False
    
    # 2. Record antibiotic treatment on day 1 (active for 5 withdrawal days)
    treatment_date = date.today()
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "treatment",
        "event_category": "health",
        "event_timestamp": datetime.combine(treatment_date, datetime.min.time()).isoformat(),
        "payload": {
            "treatment_type": "antibiotic",
            "drug": "Mastilac Penicillin",
            "withdrawal_days": 5
        }
    }, headers=headers)
    
    # 3. Log a milk record on day 3 (within withdrawal period)
    milk2 = {
        "animal_id": cow_id,
        "record_date": (treatment_date + timedelta(days=3)).isoformat(),
        "milking_session": "evening",
        "quantity_liters": 10.0
    }
    resp2 = client.post("/api/v1/dairy/milk", json=milk2, headers=headers)
    assert resp2.status_code == 201
    assert resp2.json()["is_withdrawn"] is True

    # 4. Log a milk record on day 7 (outside withdrawal period)
    milk3 = {
        "animal_id": cow_id,
        "record_date": (treatment_date + timedelta(days=7)).isoformat(),
        "milking_session": "morning",
        "quantity_liters": 11.5
    }
    resp3 = client.post("/api/v1/dairy/milk", json=milk3, headers=headers)
    assert resp3.status_code == 201
    assert resp3.json()["is_withdrawn"] is False

def test_dairy_kpis_and_drop_alerts(client):
    headers = get_auth_headers(client)
    
    calving_date = date.today() - timedelta(days=10)
    # Register & Calve
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-KPI-01", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.combine(calving_date, datetime.min.time()).isoformat(),
        "payload": {}
    }, headers=headers)

    # Log stable milk records for past 7 days (e.g. 10 liters each day)
    for i in range(1, 8):
        record_date = date.today() - timedelta(days=i)
        client.post("/api/v1/dairy/milk", json={
            "animal_id": cow_id,
            "record_date": record_date.isoformat(),
            "milking_session": "total_day",
            "quantity_liters": 10.0
        }, headers=headers)
        
    # Check KPIs before drop
    kpi_resp1 = client.get(f"/api/v1/dairy/kpi/animal/{cow_id}", headers=headers).json()
    assert kpi_resp1["days_in_milk"] == 10
    assert kpi_resp1["rolling_average_7d"] == 10.0
    assert kpi_resp1["peak_lactation_yield"] == 10.0
    assert kpi_resp1["alerts"]["milk_drop_detected"] is False

    # Log today's yield at 7.0 liters (a 30% drop from 10.0L rolling average)
    client.post("/api/v1/dairy/milk", json={
        "animal_id": cow_id,
        "record_date": date.today().isoformat(),
        "milking_session": "total_day",
        "quantity_liters": 7.0
    }, headers=headers)

    # Check KPIs after drop
    kpi_resp2 = client.get(f"/api/v1/dairy/kpi/animal/{cow_id}", headers=headers).json()
    assert kpi_resp2["alerts"]["milk_drop_detected"] is True
    # Mastitis alert should still be false since no disease event exists
    assert kpi_resp2["alerts"]["risk_mastitis"] is False

    # Log a disease diagnosis event for abnormal milk today
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "disease_diagnosis",
        "event_category": "health",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {"diagnosis": "mastitis risk", "notes": "clots seen in milk"}
    }, headers=headers)

    # Check KPIs now -> Mastitis risk should be True
    kpi_resp3 = client.get(f"/api/v1/dairy/kpi/animal/{cow_id}", headers=headers).json()
    assert kpi_resp3["alerts"]["milk_drop_detected"] is True
    assert kpi_resp3["alerts"]["risk_mastitis"] is True

def test_profitability_summary_and_by_animal(client):
    headers = get_auth_headers(client)
    
    # Create two cows
    cow1 = client.post("/api/v1/animals", json={
        "tag_id": "COW-PR-01", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow2 = client.post("/api/v1/animals", json={
        "tag_id": "COW-PR-02", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    
    # Cow 1 produces 10 liters today (Normal)
    client.post("/api/v1/dairy/milk", json={
        "animal_id": cow1["id"],
        "record_date": date.today().isoformat(),
        "milking_session": "total_day",
        "quantity_liters": 10.0
    }, headers=headers)

    # Cow 2 produces 2 liters today (Underperforming/Loss making)
    client.post("/api/v1/dairy/milk", json={
        "animal_id": cow2["id"],
        "record_date": date.today().isoformat(),
        "milking_session": "total_day",
        "quantity_liters": 2.0
    }, headers=headers)

    # Query summary with default pricing: milk=500/L, feed=1500/cow
    # Cow 1 revenue: 10 * 500 = 5000 -> profit = 5000 - 1500 = 3500 (profitable)
    # Cow 2 revenue: 2 * 500 = 1000 -> profit = 1000 - 1500 = -500 (loss-making)
    # Total revenue: 6000, Total feed: 3000, Total profit: 3000
    
    sum_resp = client.get("/api/v1/dairy/profit/summary", headers=headers).json()
    assert sum_resp["total_revenue"] == 6000.0
    assert sum_resp["total_feed_cost"] == 3000.0
    assert sum_resp["total_profit"] == 3000.0
    assert sum_resp["cows_count"] == 2
    assert sum_resp["loss_making_cows_count"] == 1

    by_cow_resp = client.get("/api/v1/dairy/profit/by-animal", headers=headers).json()
    assert len(by_cow_resp) == 2
    # Ordered ascending by profit (lowest profit first)
    assert by_cow_resp[0]["tag_id"] == "COW-PR-02"
    assert by_cow_resp[0]["profit"] == -500.0
    assert by_cow_resp[0]["is_loss_making"] is True

    assert by_cow_resp[1]["tag_id"] == "COW-PR-01"
    assert by_cow_resp[1]["profit"] == 3500.0
    assert by_cow_resp[1]["is_loss_making"] is False
