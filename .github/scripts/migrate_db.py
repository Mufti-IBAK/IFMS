import urllib.request
import json
import os
import sys

supabase_url = os.environ.get('SUPABASE_URL', 'https://mhrhlkgouekkrqncewbb.supabase.co')
service_key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY')

if not service_key:
    print("WARNING: SUPABASE_SERVICE_ROLE_KEY not set. Skipping DB migration.")
    sys.exit(0)

sql_commands = """
ALTER TABLE public.staff ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ;

ALTER TABLE public.hatchery_batches ADD COLUMN IF NOT EXISTS crate_number TEXT;
ALTER TABLE public.hatchery_batches ADD COLUMN IF NOT EXISTS crate_section TEXT;

ALTER TABLE public.animals ADD COLUMN IF NOT EXISTS generation TEXT DEFAULT 'F1';

CREATE TABLE IF NOT EXISTS public.salary_advances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_id UUID REFERENCES public.staff(id) ON DELETE CASCADE,
    advance_amount NUMERIC NOT NULL,
    monthly_deduction NUMERIC NOT NULL,
    total_repaid NUMERIC DEFAULT 0.0,
    collection_date TIMESTAMPTZ NOT NULL,
    is_fully_repaid BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name TEXT NOT NULL,
    action_type TEXT NOT NULL,
    module_name TEXT NOT NULL,
    entity_id TEXT,
    entity_name TEXT,
    description TEXT NOT NULL,
    details_json TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.yoghurt_production_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_number TEXT NOT NULL,
    production_date TIMESTAMPTZ NOT NULL,
    milk_input_liters NUMERIC NOT NULL,
    milk_cost_per_liter NUMERIC NOT NULL DEFAULT 0.0,
    total_milk_cost NUMERIC NOT NULL DEFAULT 0.0,
    bottles_produced INTEGER NOT NULL,
    packs_produced INTEGER NOT NULL,
    bottles_remaining INTEGER NOT NULL,
    additional_costs NUMERIC DEFAULT 0.0,
    produced_by_name TEXT NOT NULL DEFAULT 'Staff',
    produced_by_role TEXT NOT NULL DEFAULT 'Production Lead (Producer)',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.yoghurt_sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_date TIMESTAMPTZ NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    description TEXT,
    sale_unit TEXT NOT NULL,
    quantity_units INTEGER NOT NULL,
    total_bottles INTEGER NOT NULL,
    unit_price NUMERIC NOT NULL,
    total_amount NUMERIC NOT NULL,
    amount_paid NUMERIC NOT NULL,
    balance_due NUMERIC DEFAULT 0.0,
    balance_payer TEXT NOT NULL,
    initiated_by_name TEXT NOT NULL DEFAULT 'Staff',
    initiated_by_role TEXT NOT NULL DEFAULT 'Yoghurt Sales & Distribution Manager',
    selected_batch_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.yoghurt_returns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    return_date TIMESTAMPTZ NOT NULL,
    customer_name TEXT NOT NULL,
    description TEXT,
    initial_bought_bottles INTEGER NOT NULL,
    returned_bottles INTEGER NOT NULL,
    replaced_bottles INTEGER NOT NULL,
    processed_by_name TEXT NOT NULL DEFAULT 'Staff',
    processed_by_role TEXT NOT NULL DEFAULT 'Operational Staff',
    selected_batch_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.yoghurt_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_date TIMESTAMPTZ NOT NULL,
    description TEXT NOT NULL,
    category TEXT DEFAULT 'other',
    amount NUMERIC NOT NULL,
    processed_by_name TEXT NOT NULL DEFAULT 'Staff',
    processed_by_role TEXT NOT NULL DEFAULT 'Operational Staff',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

GRANT ALL ON public.staff TO anon, authenticated, service_role;
GRANT ALL ON public.hatchery_batches TO anon, authenticated, service_role;
GRANT ALL ON public.salary_advances TO anon, authenticated, service_role;
GRANT ALL ON public.audit_logs TO anon, authenticated, service_role;
GRANT ALL ON public.animals TO anon, authenticated, service_role;
GRANT ALL ON public.yoghurt_production_batches TO anon, authenticated, service_role;
GRANT ALL ON public.yoghurt_sales TO anon, authenticated, service_role;
GRANT ALL ON public.yoghurt_returns TO anon, authenticated, service_role;
GRANT ALL ON public.yoghurt_expenses TO anon, authenticated, service_role;
"""

# Try executing via Supabase DB SQL endpoint
endpoints = [
    f"{supabase_url}/rest/v1/sql",
    f"{supabase_url}/pg",
    f"https://api.supabase.com/v1/projects/mhrhlkgouekkrqncewbb/db/query"
]

success = False
for ep in endpoints:
    try:
        req = urllib.request.Request(
            ep,
            data=json.dumps({"query": sql_commands}).encode('utf-8'),
            headers={
                'apikey': service_key,
                'Authorization': f'Bearer {service_key}',
                'Content-Type': 'application/json'
            }
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"Migration successful via {ep}: {resp.status}")
            success = True
            break
    except Exception as e:
        print(f"Failed via {ep}: {e}")

if not success:
    print("Could not run migration directly via REST SQL endpoint. Attempting PostgREST table verification...")
