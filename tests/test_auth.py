import pytest
from fastapi import Depends
from app.main import app
from app.core.roles import UserRole
from app.services.auth_service import RoleChecker

# Define a temporary test route to test the RoleChecker dependency
@app.get("/test-vet-only-route")
def vet_only_route_endpoint(current_user=Depends(RoleChecker([UserRole.VET]))):
    return {"message": "success"}

def test_user_registration_success(client):
    register_payload = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    }
    response = client.post("/api/v1/auth/register", json=register_payload)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Dr. Mufti"
    assert data["phone"] == "+2348012345678"
    assert data["role"] == "vet"
    assert "id" in data
    assert data["is_active"] is True

def test_user_registration_duplicate_phone(client):
    register_payload = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    }
    # Register once
    response1 = client.post("/api/v1/auth/register", json=register_payload)
    assert response1.status_code == 201
    
    # Register again with same phone
    response2 = client.post("/api/v1/auth/register", json=register_payload)
    assert response2.status_code == 400
    assert response2.json()["detail"] == "A user with this phone number already exists."

def test_user_registration_invalid_input(client):
    # Password too short (less than 6 chars)
    payload_short_pw = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "123"
    }
    response = client.post("/api/v1/auth/register", json=payload_short_pw)
    assert response.status_code == 422

    # Invalid phone format (not E.164)
    payload_bad_phone = {
        "name": "Dr. Mufti",
        "phone": "0801234abcd",
        "role": "vet",
        "password": "strongpassword123"
    }
    response = client.post("/api/v1/auth/register", json=payload_bad_phone)
    assert response.status_code == 422

def test_user_login_success(client):
    # Register user first
    register_payload = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    }
    client.post("/api/v1/auth/register", json=register_payload)

    # Login
    login_payload = {
        "username": "+2348012345678",
        "password": "strongpassword123"
    }
    response = client.post("/api/v1/auth/login", data=login_payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"

def test_user_login_failure(client):
    login_payload = {
        "username": "+2348012345678",
        "password": "wrongpassword"
    }
    response = client.post("/api/v1/auth/login", data=login_payload)
    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect phone number or password"

def test_read_users_me(client):
    # Register and login
    register_payload = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    }
    client.post("/api/v1/auth/register", json=register_payload)

    login_payload = {
        "username": "+2348012345678",
        "password": "strongpassword123"
    }
    login_resp = client.post("/api/v1/auth/login", data=login_payload).json()
    token = login_resp["access_token"]

    # Access /me
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/v1/auth/me", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Dr. Mufti"
    assert data["phone"] == "+2348012345678"

def test_read_users_me_unauthorized(client):
    response = client.get("/api/v1/auth/me")
    assert response.status_code == 401

def test_refresh_token_endpoint(client):
    # Register and login
    register_payload = {
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    }
    client.post("/api/v1/auth/register", json=register_payload)

    login_payload = {
        "username": "+2348012345678",
        "password": "strongpassword123"
    }
    login_resp = client.post("/api/v1/auth/login", data=login_payload).json()
    refresh_token = login_resp["refresh_token"]

    # Call /refresh
    response = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh_token})
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data

def test_role_checker_authorization(client):
    # Register a Vet and a Worker
    client.post("/api/v1/auth/register", json={
        "name": "Dr. Mufti",
        "phone": "+2348012345678",
        "role": "vet",
        "password": "strongpassword123"
    })
    client.post("/api/v1/auth/register", json={
        "name": "John Worker",
        "phone": "+2348087654321",
        "role": "worker",
        "password": "strongpassword123"
    })

    # Log in both
    vet_token = client.post("/api/v1/auth/login", data={
        "username": "+2348012345678",
        "password": "strongpassword123"
    }).json()["access_token"]
    
    worker_token = client.post("/api/v1/auth/login", data={
        "username": "+2348087654321",
        "password": "strongpassword123"
    }).json()["access_token"]

    # Vet access -> Success
    resp_vet = client.get("/test-vet-only-route", headers={"Authorization": f"Bearer {vet_token}"})
    assert resp_vet.status_code == 200
    assert resp_vet.json() == {"message": "success"}

    # Worker access -> Forbidden
    resp_worker = client.get("/test-vet-only-route", headers={"Authorization": f"Bearer {worker_token}"})
    assert resp_worker.status_code == 403
    assert resp_worker.json()["detail"] == "You do not have permission to access this resource"
