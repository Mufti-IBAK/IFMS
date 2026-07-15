import urllib.request
import json

SUPABASE_URL = 'https://mhrhlkgouekkrqncewbb.supabase.co/rest/v1'
ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ocmhsa2dvdWVra3JxbmNld2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MzgxMzAsImV4cCI6MjA5ODMxNDEzMH0.wezUbIxZa2GXsCiYqTZwrpWUbvJzYy2F1vRv8mcF6Bo'

HEADERS = {
    'apikey': ANON_KEY,
    'Authorization': f'Bearer {ANON_KEY}'
}

def check_table(table_name):
    url = f"{SUPABASE_URL}/{table_name}?select=*"
    print(f"--- Querying {table_name} ---")
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req) as response:
            if response.status == 200:
                data = json.loads(response.read().decode('utf-8'))
                print(f"Total records in {table_name}: {len(data)}")
                if len(data) > 0:
                    print("First 3 records:")
                    for row in data[:3]:
                        print(row)
            else:
                print(f"Failed: {response.status}")
    except Exception as e:
        print(f"Error: {e}")
    print("\n")

def check_insert():
    print("--- Testing INSERT on animals ---")
    url = f"{SUPABASE_URL}/animals"
    data = {
        "id": "123e4567-e89b-12d3-a456-426614174002",
        "tag_id": "TEST-02",
        "species": "cattle",
        "sex": "female",
        "current_reproductive_status": "open",
        "status": "active",
        "acquisition_cost": None,
        "salvage_value": None
    }
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers={**HEADERS, "Content-Type": "application/json", "Prefer": "return=representation"})
    try:
        with urllib.request.urlopen(req) as response:
            print(f"Insert Status: {response.status}")
            print(response.read().decode('utf-8'))
        print("--- Querying animals after insert ---")
        req_get = urllib.request.Request(f"{SUPABASE_URL}/animals?select=*", headers=HEADERS)
        with urllib.request.urlopen(req_get) as response_get:
            data = json.loads(response_get.read().decode('utf-8'))
            print(f"Total records in animals after insert: {len(data)}")
    except urllib.error.HTTPError as e:
        print(f"HTTPError: {e.code} - {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"Error: {e}")
    print("\n")

    # Milk Records Insert Test
    print("--- Testing INSERT on milk_records ---")
    milk_url = f"{SUPABASE_URL}/milk_records"
    milk_data = {
        "id": "123e4567-e89b-12d3-a456-426614174003",
        "animal_id": "123e4567-e89b-12d3-a456-426614174000",
        "record_date": "2026-07-15",
        "milking_session": "morning",
        "quantity_liters": 10.5
    }
    req_milk = urllib.request.Request(milk_url, data=json.dumps(milk_data).encode('utf-8'), headers={**HEADERS, "Content-Type": "application/json", "Prefer": "return=representation"})
    try:
        with urllib.request.urlopen(req_milk) as res:
            print(f"Milk Insert Status: {res.status}")
    except urllib.error.HTTPError as e:
        print(f"Milk HTTPError: {e.code} - {e.read().decode('utf-8')}")

    # Transactions Insert Test
    print("--- Testing INSERT on transactions ---")
    trans_url = f"{SUPABASE_URL}/transactions"
    trans_data = {
        "id": "123e4567-e89b-12d3-a456-426614174004",
        "transaction_date": "2026-07-15",
        "transaction_type": "income",
        "category": "milk_sales",
        "amount": 1500.0,
        "currency": "NGN",
        "description": "Milk sale"
    }
    req_trans = urllib.request.Request(trans_url, data=json.dumps(trans_data).encode('utf-8'), headers={**HEADERS, "Content-Type": "application/json", "Prefer": "return=representation"})
    try:
        with urllib.request.urlopen(req_trans) as res:
            print(f"Transaction Insert Status: {res.status}")
    except urllib.error.HTTPError as e:
        print(f"Transaction HTTPError: {e.code} - {e.read().decode('utf-8')}")

if __name__ == '__main__':
    check_table('animals')
    check_table('milk_records')
    check_table('transactions')
    check_insert()

