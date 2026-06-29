import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Poultry M4",
        "phone": "+2348044445555",
        "role": "vet",
        "password": "vetpasswordabc"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348044445555",
        "password": "vetpasswordabc"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_poultry_batch_counts_and_validation(client):
    headers = get_auth_headers(client)
    
    # 1. Create a poultry batch
    batch = client.post("/api/v1/poultry/batch", json={
        "batch_type": "broiler",
        "breed": "Cobb 500",
        "start_date": "2026-06-01",
        "initial_count": 1000,
        "initial_chick_cost": 50000.0
    }, headers=headers).json()
    batch_id = batch["id"]
    assert batch["current_count"] == 1000
    
    # 2. Log mortality of 10 -> current count becomes 990
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "mortality",
        "event_date": "2026-06-02",
        "quantity": 10.0
    }, headers=headers)
    
    b_updated1 = client.get(f"/api/v1/poultry/batch/{batch_id}", headers=headers).json()
    assert b_updated1["current_count"] == 990

    # 3. Log sale of 50 -> current count becomes 940
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "sale",
        "event_date": "2026-06-03",
        "quantity": 50.0,
        "value_json": {"avg_weight_kg": 1.5, "revenue": 60000.0}
    }, headers=headers)
    
    b_updated2 = client.get(f"/api/v1/poultry/batch/{batch_id}", headers=headers).json()
    assert b_updated2["current_count"] == 940

    # 4. Attempt to log mortality that exceeds current count -> should fail (400)
    failed_mortality = client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "mortality",
        "event_date": "2026-06-04",
        "quantity": 1000.0
    }, headers=headers)
    assert failed_mortality.status_code == 400

def test_poultry_kpis_fcr_and_outbreak_alerts(client):
    headers = get_auth_headers(client)
    
    # Create batch
    batch = client.post("/api/v1/poultry/batch", json={
        "batch_type": "broiler",
        "breed": "Cobb 500",
        "start_date": "2026-06-01",
        "initial_count": 1000,
        "initial_chick_cost": 50000.0
    }, headers=headers).json()
    batch_id = batch["id"]
    
    # 1. Log feed: 2000 kg (price 150/kg -> cost = 300,000)
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "feed",
        "event_date": "2026-06-05",
        "quantity": 2000.0,
        "value_json": {"price_per_kg": 150.0}
    }, headers=headers)
    
    # 2. Log weight sample: avg weight 1.5 kg
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "weight_sample",
        "event_date": "2026-06-06",
        "quantity": 1.0,
        "value_json": {"avg_weight_kg": 1.5}
    }, headers=headers)
    
    # 3. Log sale of 100 birds (avg weight 1.5 kg, revenue = 120,000)
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "sale",
        "event_date": "2026-06-07",
        "quantity": 100.0,
        "value_json": {"avg_weight_kg": 1.5, "revenue": 120000.0}
    }, headers=headers)
    
    # Current live count = 900 birds.
    # Total live weight = 900 * 1.5 = 1350 kg.
    # Total sold weight = 100 * 1.5 = 150 kg.
    # Initial weight = 1000 * 0.04 = 40 kg.
    # Weight Gain = 1350 + 150 - 40 = 1460 kg.
    # FCR = 2000 kg / 1460 kg = 1.37
    # Total Cost = Chick cost (50,000) + Feed cost (300,000) = 350,000.
    # Net Profit = Revenue (120,000) - Total Cost (350,000) = -230,000.
    
    kpi = client.get(f"/api/v1/poultry/batch/{batch_id}/kpi", headers=headers).json()
    assert kpi["feed_conversion_ratio"] == 1.37
    assert kpi["net_profit"] == -230000.0
    assert kpi["total_costs"] == 350000.0
    assert kpi["alerts"]["disease_outbreak_risk"] is False

    # 4. Log high mortality within last 48 hours to trigger outbreak alert (30 deaths, today is June 8)
    client.post(f"/api/v1/poultry/batch/{batch_id}/event", json={
        "event_type": "mortality",
        "event_date": "2026-06-08",
        "quantity": 30.0
    }, headers=headers)
    
    kpi_post = client.get(f"/api/v1/poultry/batch/{batch_id}/kpi?reference_date=2026-06-08", headers=headers).json()
    assert kpi_post["alerts"]["disease_outbreak_risk"] is True
    assert kpi_post["alerts"]["high_mortality_alert"] is False # mortality rate is 30/1000 = 3% (< 5%)

def test_hatchery_incubation_lifecycle(client):
    headers = get_auth_headers(client)
    
    # 1. Create hatchery batch (set_date = June 1 -> Expected hatch = June 22)
    batch = client.post("/api/v1/hatchery/batch", json={
        "egg_source": "Coop House A",
        "egg_count": 1000,
        "breed": "Ross 308",
        "set_date": "2026-06-01",
        "initial_egg_cost": 20000.0 # 20 per egg
    }, headers=headers).json()
    batch_id = batch["id"]
    assert batch["expected_hatch_date"] == "2026-06-22"
    assert batch["status"] == "incubating"
    
    # 2. Log candling check at day 10: 900 fertile eggs
    client.post(f"/api/v1/hatchery/batch/{batch_id}/event", json={
        "event_type": "candling",
        "event_date": "2026-06-11",
        "value_json": {"fertile_eggs": 900}
    }, headers=headers)
    
    kpi1 = client.get(f"/api/v1/hatchery/batch/{batch_id}/kpi", headers=headers).json()
    assert kpi1["fertility_rate_percent"] == 90.0
    
    # 3. Log hatch completed at day 21: 810 hatched chicks
    # Operational utilities cost = 5000
    client.post(f"/api/v1/hatchery/batch/{batch_id}/event", json={
        "event_type": "hatch_complete",
        "event_date": "2026-06-22",
        "value_json": {"hatched_chicks": 810, "cost": 5000.0}
    }, headers=headers)
    
    b_closed = client.get(f"/api/v1/hatchery/batch/{batch_id}", headers=headers).json()
    assert b_closed["status"] == "completed"
    assert b_closed["fertile_eggs"] == 900
    assert b_closed["hatched_chicks"] == 810
    assert b_closed["failed_eggs"] == 190

    # KPI check:
    # Fertility = 90.0%
    # Hatchability = 810 / 900 = 90.0%
    # Total Cost = Egg cost (20,000) + Operational cost (5,000) = 25,000.
    # Cost per chick = 25000 / 810 = 30.86
    
    kpi2 = client.get(f"/api/v1/hatchery/batch/{batch_id}/kpi", headers=headers).json()
    assert kpi2["fertility_rate_percent"] == 90.0
    assert kpi2["hatchability_rate_percent"] == 90.0
    assert kpi2["total_cost"] == 25000.0
    assert kpi2["cost_per_chick"] == 30.86
