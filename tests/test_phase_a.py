import pytest
from datetime import datetime, timedelta, date

def get_auth_headers(client):
    register_payload = {
        "name": "Vet Phase A",
        "phone": "+2348055559999",
        "role": "vet",
        "password": "vetpassphaseA"
    }
    client.post("/api/v1/auth/register", json=register_payload)
    
    login_payload = {
        "username": "+2348055559999",
        "password": "vetpassphaseA"
    }
    resp = client.post("/api/v1/auth/login", data=login_payload).json()
    return {"Authorization": f"Bearer {resp['access_token']}"}

def test_withdrawal_blocks_milk_sales(client):
    """SAFETY: Milk sales for a cow under antibiotic withdrawal must be blocked."""
    headers = get_auth_headers(client)
    
    # 1. Register a cow
    dob = date.today() - timedelta(days=int(3 * 365.25))
    cow = client.post("/api/v1/animals", json={
        "tag_id": "COW-SAFETY-01",
        "species": "cow",
        "sex": "female",
        "date_of_birth": dob.isoformat(),
        "acquisition_cost": 300000.0,
        "salvage_value": 60000.0
    }, headers=headers).json()
    cow_id = cow["id"]
    
    # 2. Log an antibiotic treatment with 5-day withdrawal period
    treatment_date = date.today() - timedelta(days=2)  # Treated 2 days ago
    client.post(f"/api/v1/animals/{cow_id}/events", json={
        "event_type": "treatment",
        "event_category": "health",
        "event_timestamp": datetime.combine(treatment_date, datetime.min.time()).isoformat(),
        "payload": {
            "treatment_type": "antibiotic",
            "drug_name": "Oxytetracycline",
            "withdrawal_days": 5
        }
    }, headers=headers)
    
    # 3. Attempt milk sales TODAY (within withdrawal window: treated 2 days ago, withdrawal = 5 days)
    resp = client.post("/api/v1/finance/transaction", json={
        "transaction_type": "income",
        "category": "milk_sales",
        "amount": 50000.0,
        "related_entity_type": "animal",
        "related_entity_id": cow_id,
        "transaction_date": date.today().isoformat(),
        "description": "Milk sales attempt during withdrawal"
    }, headers=headers)
    assert resp.status_code == 400
    assert "antibiotic withdrawal" in resp.json()["detail"].lower()
    
    # 4. Attempt milk sales AFTER withdrawal window (6 days after treatment)
    safe_date = treatment_date + timedelta(days=6)
    resp2 = client.post("/api/v1/finance/transaction", json={
        "transaction_type": "income",
        "category": "milk_sales",
        "amount": 50000.0,
        "related_entity_type": "animal",
        "related_entity_id": cow_id,
        "transaction_date": safe_date.isoformat(),
        "description": "Milk sales after withdrawal cleared"
    }, headers=headers)
    assert resp2.status_code == 201  # Allowed

def test_transaction_reconciliation_and_reversal(client):
    """Test reconciliation marking and immutable reversal pattern."""
    headers = get_auth_headers(client)
    
    # 1. Create a transaction
    resp = client.post("/api/v1/finance/transaction", json={
        "transaction_type": "expense",
        "category": "feed",
        "amount": 25000.0,
        "transaction_date": date.today().isoformat(),
        "description": "Bulk feed purchase"
    }, headers=headers)
    assert resp.status_code == 201
    txn = resp.json()
    txn_id = txn["id"]
    assert txn["is_reconciled"] is False
    assert txn["reversal_of"] is None
    
    # 2. Reconcile the transaction
    resp2 = client.patch(f"/api/v1/finance/transactions/{txn_id}/reconcile", headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["message"] == "Transaction reconciled successfully."
    
    # 3. Attempt to reconcile again -> should fail
    resp3 = client.patch(f"/api/v1/finance/transactions/{txn_id}/reconcile", headers=headers)
    assert resp3.status_code == 400
    assert "already reconciled" in resp3.json()["detail"].lower()
    
    # 4. Reverse the transaction
    resp4 = client.post(f"/api/v1/finance/transactions/{txn_id}/reverse", headers=headers)
    assert resp4.status_code == 201
    reversal = resp4.json()
    assert reversal["transaction_type"] == "income"  # Opposite of original "expense"
    assert reversal["amount"] == 25000.0
    assert reversal["category"] == "feed"
    assert reversal["reversal_of"] == txn_id
    assert "REVERSAL" in reversal["description"]
    
    # 5. Attempt to reverse again -> should fail (already reversed)
    resp5 = client.post(f"/api/v1/finance/transactions/{txn_id}/reverse", headers=headers)
    assert resp5.status_code == 400
    assert "already been reversed" in resp5.json()["detail"].lower()
