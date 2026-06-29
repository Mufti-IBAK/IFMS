import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    # Register & Login helper to get authorization headers
    register_payload = {
        "name": "Vet Admin",
        "phone": "+2348011112222",
        "role": "vet",
        "password": "vetpassword123"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348011112222",
        "password": "vetpassword123"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_create_animal_success(client):
    headers = get_auth_headers(client)
    animal_data = {
        "tag_id": "COW-001",
        "species": "cow",
        "breed": "Holstein",
        "sex": "female",
        "date_of_birth": "2023-01-01",
        "date_of_acquisition": "2024-01-01"
    }
    response = client.post("/api/v1/animals", json=animal_data, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["tag_id"] == "COW-001"
    assert data["species"] == "cow"
    assert data["breed"] == "Holstein"
    assert data["sex"] == "female"
    assert data["current_reproductive_status"] == "open"
    assert data["status"] == "active"
    assert "id" in data

def test_create_animal_duplicate_tag(client):
    headers = get_auth_headers(client)
    animal_data = {
        "tag_id": "COW-001",
        "species": "cow",
        "breed": "Holstein",
        "sex": "female",
        "date_of_birth": "2023-01-01"
    }
    resp1 = client.post("/api/v1/animals", json=animal_data, headers=headers)
    assert resp1.status_code == 201
    
    # Try again with same tag
    resp2 = client.post("/api/v1/animals", json=animal_data, headers=headers)
    assert resp2.status_code == 400
    assert "already exists" in resp2.json()["detail"]

def test_list_animals_and_filtering(client):
    headers = get_auth_headers(client)
    # Register 3 animals
    client.post("/api/v1/animals", json={
        "tag_id": "COW-F1", "species": "cow", "sex": "female", "date_of_birth": "2023-01-01"
    }, headers=headers)
    client.post("/api/v1/animals", json={
        "tag_id": "GOAT-M1", "species": "goat", "sex": "male", "date_of_birth": "2023-05-01"
    }, headers=headers)
    client.post("/api/v1/animals", json={
        "tag_id": "SHEEP-F1", "species": "sheep", "sex": "female", "date_of_birth": "2023-06-01"
    }, headers=headers)

    # List all
    resp_all = client.get("/api/v1/animals", headers=headers)
    assert resp_all.status_code == 200
    assert len(resp_all.json()) == 3

    # Filter by species = goat
    resp_goats = client.get("/api/v1/animals?species=goat", headers=headers)
    assert len(resp_goats.json()) == 1
    assert resp_goats.json()[0]["tag_id"] == "GOAT-M1"

    # Filter by sex = female
    resp_females = client.get("/api/v1/animals?sex=female", headers=headers)
    assert len(resp_females.json()) == 2

def test_gestation_and_reproduction_calculations(client):
    headers = get_auth_headers(client)
    
    # 1. Create a female cow, goat, and sheep
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-R1", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]

    goat = client.post("/api/v1/animals", json={
        "tag_id": "GOAT-R1", "species": "goat", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    goat_id = goat["id"]

    sheep = client.post("/api/v1/animals", json={
        "tag_id": "SHEEP-R1", "species": "sheep", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    sheep_id = sheep["id"]

    # 2. Record mating/AI event for cow
    mating_time = datetime.utcnow()
    mating_event_cow = {
        "event_type": "ai_insemination",
        "event_category": "reproduction",
        "event_timestamp": mating_time.isoformat(),
        "payload": {"inseminator": "Dr. Mufti", "semen_batch": "HOL-991"}
    }
    resp_cow_event = client.post(f"/api/v1/animals/{cow_id}/events", json=mating_event_cow, headers=headers)
    assert resp_cow_event.status_code == 201
    cow_payload = resp_cow_event.json()["payload"]
    
    # Check expected pregnancy check (+30 days) and calving (+283 days)
    expected_check_cow = (mating_time + timedelta(days=30)).date().isoformat()
    expected_calving_cow = (mating_time + timedelta(days=283)).date().isoformat()
    assert cow_payload["expected_pregnancy_check"] == expected_check_cow
    assert cow_payload["expected_calving_date"] == expected_calving_cow

    # 3. Record mating event for goat
    mating_event_goat = {
        "event_type": "mating",
        "event_category": "reproduction",
        "event_timestamp": mating_time.isoformat(),
        "payload": {"sire_id": "BUCK-007"}
    }
    resp_goat_event = client.post(f"/api/v1/animals/{goat_id}/events", json=mating_event_goat, headers=headers)
    assert resp_goat_event.status_code == 201
    goat_payload = resp_goat_event.json()["payload"]
    
    # Check goat expected calving (+150 days)
    expected_calving_goat = (mating_time + timedelta(days=150)).date().isoformat()
    assert goat_payload["expected_calving_date"] == expected_calving_goat

    # 4. Record mating event for sheep
    mating_event_sheep = {
        "event_type": "mating",
        "event_category": "reproduction",
        "event_timestamp": mating_time.isoformat(),
        "payload": {"sire_id": "RAM-001"}
    }
    resp_sheep_event = client.post(f"/api/v1/animals/{sheep_id}/events", json=mating_event_sheep, headers=headers)
    assert resp_sheep_event.status_code == 201
    sheep_payload = resp_sheep_event.json()["payload"]
    
    # Check sheep expected calving (+147 days)
    expected_calving_sheep = (mating_time + timedelta(days=147)).date().isoformat()
    assert sheep_payload["expected_calving_date"] == expected_calving_sheep

def test_reproduction_event_restriction_on_male(client):
    headers = get_auth_headers(client)
    # Create a male goat
    goat = client.post("/api/v1/animals", json={
        "tag_id": "GOAT-M2", "species": "goat", "sex": "male", "date_of_birth": "2023-01-01"
    }, headers=headers).json()
    goat_id = goat["id"]

    # Try recording mating event (reproductive category)
    mating_event = {
        "event_type": "mating",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {}
    }
    response = client.post(f"/api/v1/animals/{goat_id}/events", json=mating_event, headers=headers)
    assert response.status_code == 400
    assert "only be recorded for female animals" in response.json()["detail"]

def test_lifecycle_state_machine_transitions(client):
    headers = get_auth_headers(client)
    # Create female cow
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-L1", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]
    assert cow["current_reproductive_status"] == "open"

    # 1. Pregnancy confirmed -> status changes to pregnant
    check_event = {
        "event_type": "pregnancy_check",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {"result": "pregnant"}
    }
    client.post(f"/api/v1/animals/{cow_id}/events", json=check_event, headers=headers)
    
    # Verify reproductive status is now pregnant
    profile1 = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert profile1["current_reproductive_status"] == "pregnant"

    # 2. Calving -> status changes to lactating
    calving_event = {
        "event_type": "calving",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {"calf_tag": "CALF-001"}
    }
    client.post(f"/api/v1/animals/{cow_id}/events", json=calving_event, headers=headers)
    
    profile2 = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert profile2["current_reproductive_status"] == "lactating"

    # 3. Dry off -> status changes to dry
    dry_event = {
        "event_type": "dry_off",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {}
    }
    client.post(f"/api/v1/animals/{cow_id}/events", json=dry_event, headers=headers)
    
    profile3 = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert profile3["current_reproductive_status"] == "dry"

    # 4. Abortion -> status changes to open
    abort_event = {
        "event_type": "abortion",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {}
    }
    client.post(f"/api/v1/animals/{cow_id}/events", json=abort_event, headers=headers)
    
    profile4 = client.get(f"/api/v1/animals/{cow_id}", headers=headers).json()
    assert profile4["current_reproductive_status"] == "open"

def test_get_animal_timeline(client):
    headers = get_auth_headers(client)
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-T1", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers).json()
    cow_id = cow["id"]

    # Post 2 events at different timestamps
    now = datetime.utcnow()
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "weight_measurement",
        "event_category": "health",
        "event_timestamp": (now - timedelta(days=5)).isoformat(),
        "payload": {"weight_kg": 450}
    }, headers=headers)
    
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "treatment",
        "event_category": "health",
        "event_timestamp": now.isoformat(),
        "payload": {"drug": "Penicillin", "dose": "10ml"}
    }, headers=headers)

    # Get events timeline
    response = client.get(f"/api/v1/animals/{cow_id}/events", headers=headers)
    assert response.status_code == 200
    events = response.json()
    assert len(events) == 2
    # Check sorting (descending by event_timestamp)
    assert events[0]["event_type"] == "treatment"
    assert events[1]["event_type"] == "weight_measurement"

def test_get_herd_analytics(client):
    headers = get_auth_headers(client)
    
    # Create cow, goat, and sheep with various statuses
    client.post("/api/v1/animals", json={
        "tag_id": "COW-A1", "species": "cow", "sex": "female", "date_of_birth": "2022-01-01"
    }, headers=headers)
    
    client.post("/api/v1/animals", json={
        "tag_id": "GOAT-A1", "species": "goat", "sex": "female", "date_of_birth": "2023-01-01"
    }, headers=headers)

    goat2 = client.post("/api/v1/animals", json={
        "tag_id": "GOAT-A2", "species": "goat", "sex": "female", "date_of_birth": "2023-01-01"
    }, headers=headers).json()
    
    # Make goat2 pregnant
    client.post(f"/api/v1/animals/{goat2['id']}/events", json={
        "event_type": "confirmed_pregnant",
        "event_category": "reproduction",
        "event_timestamp": datetime.utcnow().isoformat(),
        "payload": {}
    }, headers=headers)

    # Call herd analytics
    response = client.get("/api/v1/animals/analytics/herd", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["total_animals"] == 3
    assert data["species_breakdown"]["cows"] == 1
    assert data["species_breakdown"]["goats"] == 2
    assert data["species_breakdown"]["sheep"] == 0
    assert data["reproductive_breakdown"]["pregnant"] == 1
    assert data["reproductive_breakdown"]["open"] == 2
