import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Breeding M3",
        "phone": "+2348033334444",
        "role": "vet",
        "password": "vetpassword789"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348033334444",
        "password": "vetpassword789"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_pedigree_validation_checks(client):
    headers = get_auth_headers(client)
    
    # 1. Register a valid male cow (Sire)
    sire = client.post("/api/v1/animals", json={
        "tag_id": "SIRE-01", "species": "cow", "sex": "male", "date_of_birth": "2020-01-01"
    }, headers=headers).json()
    sire_id = sire["id"]
    
    # 2. Register a valid female cow (Dam)
    dam = client.post("/api/v1/animals", json={
        "tag_id": "DAM-01", "species": "cow", "sex": "female", "date_of_birth": "2020-01-01"
    }, headers=headers).json()
    dam_id = dam["id"]
    
    # 3. Register offspring with valid parents -> should succeed
    offspring = client.post("/api/v1/animals", json={
        "tag_id": "CALF-01", "species": "cow", "sex": "female", "date_of_birth": "2023-01-01",
        "sire_id": sire_id, "dam_id": dam_id, "genetic_line": "Jersey-A"
    }, headers=headers)
    assert offspring.status_code == 201
    assert offspring.json()["sire_id"] == sire_id
    assert offspring.json()["dam_id"] == dam_id
    assert offspring.json()["genetic_line"] == "Jersey-A"
    
    # 4. Attempt to use female as a sire -> should fail (400)
    failed1 = client.post("/api/v1/animals", json={
        "tag_id": "CALF-FAILED-1", "species": "cow", "sex": "female", "date_of_birth": "2023-01-01",
        "sire_id": dam_id # dam is female!
    }, headers=headers)
    assert failed1.status_code == 400
    assert "must be a male animal" in failed1.json()["detail"]
    
    # 5. Attempt to use male goat as a cow's sire -> should fail (400)
    goat_sire = client.post("/api/v1/animals", json={
        "tag_id": "GOAT-SIRE-01", "species": "goat", "sex": "male", "date_of_birth": "2020-01-01"
    }, headers=headers).json()
    
    failed2 = client.post("/api/v1/animals", json={
        "tag_id": "CALF-FAILED-2", "species": "cow", "sex": "female", "date_of_birth": "2023-01-01",
        "sire_id": goat_sire["id"] # different species!
    }, headers=headers)
    assert failed2.status_code == 400
    assert "must be of the same species" in failed2.json()["detail"]

def test_breeding_events_and_reproductive_transitions(client):
    headers = get_auth_headers(client)
    
    # Register cow
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-B-01", "species": "cow", "sex": "female", "date_of_birth": "2021-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # 1. Log Heat event -> IN_HEAT
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "heat", "event_date": date.today().isoformat()
    }, headers=headers)
    
    animal = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert animal["current_reproductive_status"] == "in_heat"
    
    # 2. Log Mating event -> SERVICED
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "mating", "event_date": date.today().isoformat()
    }, headers=headers)
    
    animal = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert animal["current_reproductive_status"] == "serviced"

    # 3. Log Pregnancy Check (Result: pregnant) -> PREGNANT
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "pregnancy_check", "event_date": date.today().isoformat(),
        "result": "pregnant", "notes": "Ultrasound confirmed"
    }, headers=headers)
    
    animal = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert animal["current_reproductive_status"] == "pregnant"

    # 4. Log Abortion -> OPEN
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "abortion", "event_date": date.today().isoformat()
    }, headers=headers)
    
    animal = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert animal["current_reproductive_status"] == "open"

    # 5. Log Calving -> LACTATING (starts lactation cycle in dairy)
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "calving", "event_date": date.today().isoformat()
    }, headers=headers)
    
    animal = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert animal["current_reproductive_status"] == "lactating"
    
    # Verify lactation record was automatically triggered
    lact_resp = client.get(f"/api/v1/dairy/lactation/{cow_id}", headers=headers).json()
    assert len(lact_resp) == 1
    assert lact_resp[0]["lactation_number"] == 1
    assert lact_resp[0]["status"] == "active"

def test_breeding_calendar_engine(client):
    headers = get_auth_headers(client)
    
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-CAL-01", "species": "cow", "sex": "female", "date_of_birth": "2021-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # 1. Log AI event today
    today = date.today()
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "ai_insemination", "event_date": today.isoformat()
    }, headers=headers)
    
    # Check calendar today -> check not due yet (check is due in 30 days)
    cal_today = client.get("/api/v1/breeding/calendar", headers=headers).json()
    assert len(cal_today["pregnancy_checks_due"]) == 0
    
    # Check calendar in 30 days -> pregnancy check is due
    ref_date_30 = (today + timedelta(days=30)).isoformat()
    cal_30 = client.get(f"/api/v1/breeding/calendar?reference_date={ref_date_30}", headers=headers).json()
    assert len(cal_30["pregnancy_checks_due"]) == 1
    assert cal_30["pregnancy_checks_due"][0]["tag_id"] == "COW-CAL-01"

    # 2. Confirm pregnant
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "confirmed_pregnant", "event_date": (today + timedelta(days=30)).isoformat()
    }, headers=headers)
    
    # Check calendar today + 30 days -> pregnancy check due is now 0 (since check has been done)
    cal_30_post = client.get(f"/api/v1/breeding/calendar?reference_date={ref_date_30}", headers=headers).json()
    assert len(cal_30_post["pregnancy_checks_due"]) == 0
    
    # Expected calving for cow: today + 283 days.
    # Check upcoming calving in 270 days (which is within 30 days of EDD today+283)
    ref_date_270 = (today + timedelta(days=270)).isoformat()
    cal_270 = client.get(f"/api/v1/breeding/calendar?reference_date={ref_date_270}", headers=headers).json()
    assert len(cal_270["upcoming_calvings"]) == 1
    assert cal_270["upcoming_calvings"][0]["tag_id"] == "COW-CAL-01"
    
    # Overdue calving (dystocia risk) at today + 295 days (more than 7 days past today+283)
    ref_date_295 = (today + timedelta(days=295)).isoformat()
    cal_295 = client.get(f"/api/v1/breeding/calendar?reference_date={ref_date_295}", headers=headers).json()
    assert len(cal_295["overdue_calvings_alert"]) == 1
    assert cal_295["overdue_calvings_alert"][0]["tag_id"] == "COW-CAL-01"

    # 3. Log calving and wait 100 days -> open cow alert
    calving_day = today + timedelta(days=283)
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "calving", "event_date": calving_day.isoformat()
    }, headers=headers)
    
    # Reference date is calving + 100 days (383 days from today)
    ref_date_383 = (today + timedelta(days=383)).isoformat()
    cal_383 = client.get(f"/api/v1/breeding/calendar?reference_date={ref_date_383}", headers=headers).json()
    assert len(cal_383["open_cows_alert"]) == 1
    assert cal_383["open_cows_alert"][0]["tag_id"] == "COW-CAL-01"

def test_breeding_kpis(client):
    headers = get_auth_headers(client)
    
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-KPI-BR", "species": "cow", "sex": "female", "date_of_birth": "2021-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # Services: log 2 mating events
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "mating", "event_date": (date.today() - timedelta(days=40)).isoformat()
    }, headers=headers)
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "mating", "event_date": (date.today() - timedelta(days=20)).isoformat()
    }, headers=headers)
    
    # Conception check success
    client.post("/api/v1/breeding/event", json={
        "animal_id": cow_id, "event_type": "pregnancy_check", "event_date": date.today().isoformat(),
        "result": "pregnant"
    }, headers=headers)
    
    # Herd KPIs: total services = 2, conceptions = 1 -> rate = 50%
    herd_kpi = client.get("/api/v1/breeding/kpi/herd", headers=headers).json()
    assert herd_kpi["overall_conception_rate_percent"] == 50.0
    assert herd_kpi["total_services_logged"] == 2
    assert herd_kpi["total_conceptions_logged"] == 1
    
    # Individual KPIs
    cow_kpi = client.get(f"/api/v1/breeding/kpi/animal/{cow_id}", headers=headers).json()
    assert cow_kpi["total_services"] == 2
    assert cow_kpi["conceptions"] == 1
    assert cow_kpi["services_per_conception"] == 2.0
    assert cow_kpi["conception_rate_percent"] == 50.0
