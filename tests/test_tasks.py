import pytest
from datetime import date, timedelta

def get_auth_headers(client):
    register_payload = {
        "name": "Manager Tasks",
        "phone": "+2348077772222",
        "role": "manager",
        "password": "managerpass123"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    login_payload = {
        "username": "+2348077772222",
        "password": "managerpass123"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_task_crud_and_assignment(client):
    headers = get_auth_headers(client)
    
    # Get current user ID
    me = client.get("/api/v1/auth/me", headers=headers).json()
    user_id = me["id"]
    
    # Create a task assigned to self
    resp = client.post("/api/v1/tasks", json={
        "title": "Vaccinate Batch B-001",
        "description": "Administer Newcastle vaccine to broiler batch",
        "priority": "high",
        "assigned_to": user_id,
        "due_date": (date.today() + timedelta(days=3)).isoformat()
    }, headers=headers)
    assert resp.status_code == 201
    task = resp.json()
    assert task["title"] == "Vaccinate Batch B-001"
    assert task["status"] == "pending"
    assert task["priority"] == "high"
    task_id = task["id"]
    
    # Get task by ID
    resp2 = client.get(f"/api/v1/tasks/{task_id}", headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["title"] == "Vaccinate Batch B-001"
    
    # List all tasks
    resp3 = client.get("/api/v1/tasks", headers=headers)
    assert resp3.status_code == 200
    assert len(resp3.json()) >= 1
    
    # Get my tasks
    resp4 = client.get("/api/v1/tasks/my-tasks", headers=headers)
    assert resp4.status_code == 200
    assert any(t["id"] == task_id for t in resp4.json())

def test_task_status_transitions(client):
    headers = get_auth_headers(client)
    
    # Create task
    resp = client.post("/api/v1/tasks", json={
        "title": "Check water troughs",
        "priority": "medium"
    }, headers=headers)
    assert resp.status_code == 201
    task_id = resp.json()["id"]
    assert resp.json()["status"] == "pending"
    
    # Transition: pending -> in_progress
    resp2 = client.patch(f"/api/v1/tasks/{task_id}/status", json={
        "status": "in_progress"
    }, headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["status"] == "in_progress"
    
    # Transition: in_progress -> completed
    resp3 = client.patch(f"/api/v1/tasks/{task_id}/status", json={
        "status": "completed"
    }, headers=headers)
    assert resp3.status_code == 200
    assert resp3.json()["status"] == "completed"
    assert resp3.json()["completed_at"] is not None
    
    # Invalid transition: completed -> in_progress
    resp4 = client.patch(f"/api/v1/tasks/{task_id}/status", json={
        "status": "in_progress"
    }, headers=headers)
    assert resp4.status_code == 400

def test_overdue_detection_and_summary(client):
    headers = get_auth_headers(client)
    
    # Create a task with past due date
    resp = client.post("/api/v1/tasks", json={
        "title": "Overdue feed delivery check",
        "priority": "urgent",
        "due_date": (date.today() - timedelta(days=5)).isoformat()
    }, headers=headers)
    assert resp.status_code == 201
    task_id = resp.json()["id"]
    
    # Mark overdue tasks
    resp2 = client.post("/api/v1/tasks/mark-overdue", headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["message"].startswith("1") or int(resp2.json()["message"].split()[0]) >= 1
    
    # Check task is now overdue
    resp3 = client.get(f"/api/v1/tasks/{task_id}", headers=headers)
    assert resp3.json()["status"] == "overdue"
    
    # Get summary
    resp4 = client.get("/api/v1/tasks/summary", headers=headers)
    assert resp4.status_code == 200
    summary = resp4.json()
    assert summary["overdue"] >= 1
    assert summary["by_priority"]["urgent"] >= 1
