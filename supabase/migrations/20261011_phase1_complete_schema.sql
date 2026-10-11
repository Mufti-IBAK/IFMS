-- 20261011_phase1_complete_schema.sql
-- Create all missing tables, fix column drift, and ensure parity with mobile app models

-- 1. YOGHURT MODULE
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
    produced_by_role TEXT NOT NULL DEFAULT 'Production Lead',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.yoghurt_sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_date TIMESTAMPTZ NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    description TEXT,
    sale_unit TEXT NOT NULL DEFAULT 'bottles',
    quantity_units INTEGER NOT NULL,
    total_bottles INTEGER NOT NULL,
    unit_price NUMERIC NOT NULL,
    total_amount NUMERIC NOT NULL,
    amount_paid NUMERIC NOT NULL,
    balance_due NUMERIC DEFAULT 0.0,
    balance_payer TEXT NOT NULL DEFAULT 'cleared',
    initiated_by_name TEXT NOT NULL DEFAULT 'Staff',
    initiated_by_role TEXT NOT NULL DEFAULT 'Cashier',
    selected_batch_id UUID REFERENCES public.yoghurt_production_batches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
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
    processed_by_role TEXT NOT NULL DEFAULT 'Officer',
    selected_batch_id UUID REFERENCES public.yoghurt_production_batches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.yoghurt_expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_date TIMESTAMPTZ NOT NULL,
    description TEXT NOT NULL,
    category TEXT DEFAULT 'other',
    amount NUMERIC NOT NULL,
    processed_by_name TEXT NOT NULL DEFAULT 'Staff',
    processed_by_role TEXT NOT NULL DEFAULT 'Officer',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- 2. POULTRY & BROODING EXTENSIONS
CREATE TABLE IF NOT EXISTS public.brooding_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_name TEXT NOT NULL,
    breed TEXT NOT NULL,
    source TEXT NOT NULL,
    initial_chicks INTEGER NOT NULL,
    current_chicks INTEGER NOT NULL,
    brooder_house TEXT NOT NULL,
    chick_cost_per_unit NUMERIC DEFAULT 0.0,
    total_chick_cost NUMERIC DEFAULT 0.0,
    start_date TIMESTAMPTZ NOT NULL,
    graduated_date TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'brooding',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.brooding_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID REFERENCES public.brooding_batches(id) ON DELETE CASCADE,
    log_date TIMESTAMPTZ NOT NULL,
    mortality INTEGER DEFAULT 0,
    target_temperature NUMERIC,
    actual_temperature NUMERIC,
    feed_consumed_kg NUMERIC DEFAULT 0.0,
    water_consumed_liters NUMERIC DEFAULT 0.0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.poultry_treatments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID REFERENCES public.poultry_batches(id) ON DELETE CASCADE,
    medication_id TEXT,
    medication_name TEXT NOT NULL,
    quantity_used NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    cost_per_unit NUMERIC DEFAULT 0.0,
    total_cost NUMERIC DEFAULT 0.0,
    treatment_date TIMESTAMPTZ NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.poultry_feed_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID REFERENCES public.poultry_batches(id) ON DELETE CASCADE,
    feed_source_type TEXT NOT NULL,
    feed_item_id TEXT,
    formula_id TEXT,
    feed_name TEXT NOT NULL,
    quantity_kg NUMERIC NOT NULL,
    cost_per_kg NUMERIC DEFAULT 0.0,
    total_cost NUMERIC DEFAULT 0.0,
    log_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.poultry_logs (
    id SERIAL PRIMARY KEY,
    batch_id UUID REFERENCES public.poultry_batches(id) ON DELETE CASCADE,
    log_date TIMESTAMPTZ NOT NULL,
    feed_bags INTEGER DEFAULT 0,
    mortality INTEGER DEFAULT 0,
    average_weight NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. FEED FORMULAS & FEEDING
CREATE TABLE IF NOT EXISTS public.feed_formulas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    target_species TEXT NOT NULL,
    production_stage TEXT NOT NULL,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.formula_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    formula_id UUID REFERENCES public.feed_formulas(id) ON DELETE CASCADE,
    feed_item_id UUID REFERENCES public.feed_items(id) ON DELETE RESTRICT,
    inclusion_percentage NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.feed_consumption_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID REFERENCES public.animals(id) ON DELETE CASCADE,
    feed_item_id UUID REFERENCES public.feed_items(id) ON DELETE RESTRICT,
    date TIMESTAMPTZ NOT NULL,
    quantity_kg NUMERIC NOT NULL,
    cost NUMERIC DEFAULT 0.0,
    logged_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.feeding_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID REFERENCES public.animals(id) ON DELETE CASCADE,
    formula_id UUID REFERENCES public.feed_formulas(id) ON DELETE RESTRICT,
    daily_ration_kg NUMERIC NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PHARMACY & MEDICAL
CREATE TABLE IF NOT EXISTS public.medication_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    animal_id UUID REFERENCES public.animals(id) ON DELETE CASCADE,
    medication_id UUID REFERENCES public.medications(id) ON DELETE RESTRICT,
    dose_given NUMERIC NOT NULL,
    administered_date TIMESTAMPTZ NOT NULL,
    administered_by TEXT NOT NULL,
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.farm_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    severity TEXT NOT NULL DEFAULT 'info',
    related_module TEXT,
    related_entity_id TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. COLUMN DRIFT FIXES
ALTER TABLE public.medications ADD COLUMN IF NOT EXISTS concentration_mg_per_ml NUMERIC;
ALTER TABLE public.medications ADD COLUMN IF NOT EXISTS concentration_value NUMERIC;
ALTER TABLE public.medications ADD COLUMN IF NOT EXISTS concentration_unit TEXT;

ALTER TABLE public.poultry_batches ADD COLUMN IF NOT EXISTS batch_name TEXT;
ALTER TABLE public.poultry_batches ADD COLUMN IF NOT EXISTS house_name TEXT;
ALTER TABLE public.poultry_batches ADD COLUMN IF NOT EXISTS target_weight NUMERIC;
ALTER TABLE public.poultry_batches ADD COLUMN IF NOT EXISTS mortality_count INTEGER DEFAULT 0;

ALTER TABLE public.hatchery_batches ADD COLUMN IF NOT EXISTS crate_number TEXT;
ALTER TABLE public.hatchery_batches ADD COLUMN IF NOT EXISTS crate_section TEXT;

ALTER TABLE public.animals ADD COLUMN IF NOT EXISTS generation TEXT DEFAULT 'F1';
ALTER TABLE public.staff ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ;

-- 6. GRANT PERMISSIONS TO EVERYONE FOR NOW (Open Roles)
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- 7. ENABLE RLS POLICIES FOR NEW TABLES (Allow All for now, tightened later)
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t);
        EXECUTE format('DROP POLICY IF EXISTS "Allow All" ON public.%I;', t);
        EXECUTE format('CREATE POLICY "Allow All" ON public.%I FOR ALL USING (true) WITH CHECK (true);', t);
    END LOOP;
END $$;
