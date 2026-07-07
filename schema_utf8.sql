BEGIN;

CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL, 
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- Running upgrade  -> 18a5ac29d879

CREATE TABLE events (
    entity_type VARCHAR(50) NOT NULL, 
    entity_id VARCHAR(50) NOT NULL, 
    event_type VARCHAR(50) NOT NULL, 
    payload JSON NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_events_id ON events (id);

CREATE TABLE users (
    name VARCHAR(100) NOT NULL, 
    phone VARCHAR(20) NOT NULL, 
    password_hash VARCHAR(255) NOT NULL, 
    role VARCHAR(7) NOT NULL, 
    is_active BOOLEAN NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_users_id ON users (id);

CREATE UNIQUE INDEX ix_users_phone ON users (phone);

INSERT INTO alembic_version (version_num) VALUES ('18a5ac29d879') RETURNING alembic_version.version_num;

-- Running upgrade 18a5ac29d879 -> beba59960b7b

CREATE TABLE animals (
    tag_id VARCHAR(50) NOT NULL, 
    species VARCHAR(5) NOT NULL, 
    breed VARCHAR(100), 
    sex VARCHAR(10) NOT NULL, 
    date_of_birth DATE NOT NULL, 
    date_of_acquisition DATE, 
    status VARCHAR(11) NOT NULL, 
    current_location_id VARCHAR(50), 
    current_reproductive_status VARCHAR(9) NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_animals_id ON animals (id);

CREATE UNIQUE INDEX ix_animals_tag_id ON animals (tag_id);

CREATE TABLE animal_events (
    animal_id UUID NOT NULL, 
    event_type VARCHAR(50) NOT NULL, 
    event_category VARCHAR(12) NOT NULL, 
    event_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    payload JSON NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(animal_id) REFERENCES animals (id) ON DELETE CASCADE, 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_animal_events_animal_id ON animal_events (animal_id);

CREATE INDEX ix_animal_events_event_category ON animal_events (event_category);

CREATE INDEX ix_animal_events_event_timestamp ON animal_events (event_timestamp);

CREATE INDEX ix_animal_events_event_type ON animal_events (event_type);

CREATE INDEX ix_animal_events_id ON animal_events (id);

UPDATE alembic_version SET version_num='beba59960b7b' WHERE alembic_version.version_num = '18a5ac29d879';

-- Running upgrade beba59960b7b -> 82605882581d

CREATE TABLE lactations (
    animal_id UUID NOT NULL, 
    start_date DATE NOT NULL, 
    end_date DATE, 
    lactation_number INTEGER NOT NULL, 
    status VARCHAR(20) NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(animal_id) REFERENCES animals (id) ON DELETE CASCADE
);

CREATE INDEX ix_lactations_animal_id ON lactations (animal_id);

CREATE INDEX ix_lactations_id ON lactations (id);

CREATE TABLE milk_records (
    animal_id UUID NOT NULL, 
    record_date DATE NOT NULL, 
    milking_session VARCHAR(20) NOT NULL, 
    quantity_liters FLOAT NOT NULL, 
    fat_percentage FLOAT, 
    protein_percentage FLOAT, 
    is_withdrawn BOOLEAN NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(animal_id) REFERENCES animals (id) ON DELETE CASCADE, 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_milk_records_animal_id ON milk_records (animal_id);

CREATE INDEX ix_milk_records_id ON milk_records (id);

CREATE INDEX ix_milk_records_record_date ON milk_records (record_date);

UPDATE alembic_version SET version_num='82605882581d' WHERE alembic_version.version_num = 'beba59960b7b';

-- Running upgrade 82605882581d -> 6d39b1942be1

CREATE TABLE breeding_events (
    animal_id UUID NOT NULL, 
    event_type VARCHAR(50) NOT NULL, 
    event_date DATE NOT NULL, 
    result VARCHAR(50), 
    notes VARCHAR(255), 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(animal_id) REFERENCES animals (id) ON DELETE CASCADE, 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_breeding_events_animal_id ON breeding_events (animal_id);

CREATE INDEX ix_breeding_events_event_date ON breeding_events (event_date);

CREATE INDEX ix_breeding_events_event_type ON breeding_events (event_type);

CREATE INDEX ix_breeding_events_id ON breeding_events (id);

ALTER TABLE animals ADD COLUMN sire_id UUID;

ALTER TABLE animals ADD COLUMN dam_id UUID;

ALTER TABLE animals ADD COLUMN genetic_line VARCHAR(100);

UPDATE alembic_version SET version_num='6d39b1942be1' WHERE alembic_version.version_num = '82605882581d';

-- Running upgrade 6d39b1942be1 -> 8a2cc0e71525

CREATE TABLE hatchery_batches (
    egg_source VARCHAR(100) NOT NULL, 
    egg_count INTEGER NOT NULL, 
    breed VARCHAR(100), 
    set_date DATE NOT NULL, 
    expected_hatch_date DATE NOT NULL, 
    fertile_eggs INTEGER, 
    hatched_chicks INTEGER, 
    failed_eggs INTEGER, 
    initial_egg_cost FLOAT NOT NULL, 
    status VARCHAR(20) NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_hatchery_batches_id ON hatchery_batches (id);

CREATE TABLE poultry_batches (
    batch_type VARCHAR(50) NOT NULL, 
    breed VARCHAR(100), 
    start_date DATE NOT NULL, 
    end_date DATE, 
    initial_count INTEGER NOT NULL, 
    current_count INTEGER NOT NULL, 
    status VARCHAR(20) NOT NULL, 
    location_id VARCHAR(50), 
    initial_chick_cost FLOAT NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_poultry_batches_id ON poultry_batches (id);

CREATE TABLE hatchery_events (
    batch_id UUID NOT NULL, 
    event_type VARCHAR(50) NOT NULL, 
    event_date DATE NOT NULL, 
    value_json JSON, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(batch_id) REFERENCES hatchery_batches (id) ON DELETE CASCADE, 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_hatchery_events_batch_id ON hatchery_events (batch_id);

CREATE INDEX ix_hatchery_events_event_date ON hatchery_events (event_date);

CREATE INDEX ix_hatchery_events_event_type ON hatchery_events (event_type);

CREATE INDEX ix_hatchery_events_id ON hatchery_events (id);

CREATE TABLE poultry_events (
    batch_id UUID NOT NULL, 
    event_type VARCHAR(50) NOT NULL, 
    event_date DATE NOT NULL, 
    quantity FLOAT NOT NULL, 
    value_json JSON, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(batch_id) REFERENCES poultry_batches (id) ON DELETE CASCADE, 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_poultry_events_batch_id ON poultry_events (batch_id);

CREATE INDEX ix_poultry_events_event_date ON poultry_events (event_date);

CREATE INDEX ix_poultry_events_event_type ON poultry_events (event_type);

CREATE INDEX ix_poultry_events_id ON poultry_events (id);

UPDATE alembic_version SET version_num='8a2cc0e71525' WHERE alembic_version.version_num = '6d39b1942be1';

-- Running upgrade 8a2cc0e71525 -> 153932ccd030

CREATE TABLE transactions (
    transaction_type VARCHAR(20) NOT NULL, 
    category VARCHAR(50) NOT NULL, 
    amount FLOAT NOT NULL, 
    currency VARCHAR(10) NOT NULL, 
    related_entity_type VARCHAR(50), 
    related_entity_id UUID, 
    description VARCHAR(255), 
    transaction_date DATE NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(created_by) REFERENCES users (id)
);

CREATE INDEX ix_transactions_id ON transactions (id);

CREATE INDEX ix_transactions_transaction_date ON transactions (transaction_date);

ALTER TABLE animals ADD COLUMN acquisition_cost FLOAT DEFAULT '0.0' NOT NULL;

ALTER TABLE animals ADD COLUMN salvage_value FLOAT DEFAULT '0.0' NOT NULL;

UPDATE alembic_version SET version_num='153932ccd030' WHERE alembic_version.version_num = '8a2cc0e71525';

-- Running upgrade 153932ccd030 -> af93c36e9b46

CREATE TABLE alerts (
    entity_type VARCHAR(50) NOT NULL, 
    entity_id UUID, 
    alert_type VARCHAR(50) NOT NULL, 
    severity VARCHAR(20) NOT NULL, 
    message VARCHAR(255) NOT NULL, 
    status VARCHAR(20) NOT NULL, 
    resolved_at TIMESTAMP WITHOUT TIME ZONE, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_alerts_id ON alerts (id);

CREATE TABLE rules (
    name VARCHAR(100) NOT NULL, 
    entity_type VARCHAR(50) NOT NULL, 
    condition_json JSON, 
    severity VARCHAR(20) NOT NULL, 
    action_type VARCHAR(20) NOT NULL, 
    active BOOLEAN NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_rules_id ON rules (id);

UPDATE alembic_version SET version_num='af93c36e9b46' WHERE alembic_version.version_num = '153932ccd030';

-- Running upgrade af93c36e9b46 -> c393e84d636c

CREATE INDEX ix_alerts_alert_type ON alerts (alert_type);

CREATE INDEX ix_alerts_entity_id ON alerts (entity_id);

CREATE INDEX ix_alerts_entity_lookup ON alerts (entity_type, entity_id, alert_type, status);

CREATE INDEX ix_alerts_entity_type ON alerts (entity_type);

CREATE INDEX ix_alerts_severity ON alerts (severity);

CREATE INDEX ix_alerts_status ON alerts (status);

CREATE INDEX ix_animal_events_composite ON animal_events (animal_id, event_type, event_timestamp);

CREATE INDEX ix_breeding_events_composite ON breeding_events (animal_id, event_type, event_date);

CREATE INDEX ix_milk_records_composite ON milk_records (animal_id, record_date);

ALTER TABLE transactions ADD COLUMN is_reconciled BOOLEAN DEFAULT '0' NOT NULL;

ALTER TABLE transactions ADD COLUMN approved_by VARCHAR(36);

ALTER TABLE transactions ADD COLUMN reversal_of VARCHAR(36);

CREATE INDEX ix_transactions_entity_date ON transactions (related_entity_type, related_entity_id, transaction_date);

UPDATE alembic_version SET version_num='c393e84d636c' WHERE alembic_version.version_num = 'af93c36e9b46';

-- Running upgrade c393e84d636c -> e55f7432b9f1

CREATE TABLE feed_items (
    name VARCHAR(100) NOT NULL, 
    category VARCHAR(50) NOT NULL, 
    unit VARCHAR(20) NOT NULL, 
    current_stock FLOAT NOT NULL, 
    reorder_threshold FLOAT NOT NULL, 
    cost_per_unit FLOAT NOT NULL, 
    currency VARCHAR(10) NOT NULL, 
    supplier VARCHAR(100), 
    is_active BOOLEAN NOT NULL, 
    created_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(created_by) REFERENCES users (id), 
    UNIQUE (name)
);

CREATE INDEX ix_feed_items_category ON feed_items (category);

CREATE INDEX ix_feed_items_id ON feed_items (id);

CREATE TABLE tasks (
    title VARCHAR(200) NOT NULL, 
    description TEXT, 
    priority VARCHAR(20) NOT NULL, 
    status VARCHAR(20) NOT NULL, 
    assigned_to UUID, 
    assigned_by UUID NOT NULL, 
    due_date DATE, 
    completed_at TIMESTAMP WITHOUT TIME ZONE, 
    related_entity_type VARCHAR(50), 
    related_entity_id UUID, 
    source_alert_id UUID, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(assigned_by) REFERENCES users (id), 
    FOREIGN KEY(assigned_to) REFERENCES users (id), 
    FOREIGN KEY(source_alert_id) REFERENCES alerts (id)
);

CREATE INDEX ix_tasks_assigned_status ON tasks (assigned_to, status);

CREATE INDEX ix_tasks_assigned_to ON tasks (assigned_to);

CREATE INDEX ix_tasks_due_date ON tasks (due_date, status);

CREATE INDEX ix_tasks_id ON tasks (id);

CREATE INDEX ix_tasks_status ON tasks (status);

CREATE TABLE inventory_logs (
    item_id UUID NOT NULL, 
    change_type VARCHAR(30) NOT NULL, 
    quantity_change FLOAT NOT NULL, 
    balance_after FLOAT NOT NULL, 
    related_entity_type VARCHAR(50), 
    related_entity_id UUID, 
    notes VARCHAR(255), 
    log_date DATE NOT NULL, 
    logged_by UUID NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(item_id) REFERENCES feed_items (id) ON DELETE CASCADE, 
    FOREIGN KEY(logged_by) REFERENCES users (id)
);

CREATE INDEX ix_inventory_logs_id ON inventory_logs (id);

CREATE INDEX ix_inventory_logs_item_date ON inventory_logs (item_id, log_date);

CREATE INDEX ix_inventory_logs_item_id ON inventory_logs (item_id);

CREATE INDEX ix_inventory_logs_log_date ON inventory_logs (log_date);

UPDATE alembic_version SET version_num='e55f7432b9f1' WHERE alembic_version.version_num = 'c393e84d636c';

-- Running upgrade e55f7432b9f1 -> fff24971f091

ALTER TABLE animals ADD COLUMN image_path VARCHAR(255);

ALTER TABLE animals ADD COLUMN weight FLOAT;

ALTER TABLE animals ADD COLUMN color VARCHAR(100);

ALTER TABLE animals ADD COLUMN unique_marks VARCHAR(255);

ALTER TABLE animals ADD COLUMN pedigree_type VARCHAR(50);

ALTER TABLE animals ADD COLUMN purpose VARCHAR(50);

ALTER TABLE animals ADD COLUMN vaccination_status VARCHAR(255);

ALTER TABLE transactions ALTER COLUMN approved_by TYPE UUID USING approved_by::uuid;

ALTER TABLE transactions ALTER COLUMN reversal_of TYPE UUID USING reversal_of::uuid;

ALTER TABLE transactions ADD FOREIGN KEY(approved_by) REFERENCES users (id);

ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(10);

UPDATE alembic_version SET version_num='fff24971f091' WHERE alembic_version.version_num = 'e55f7432b9f1';

-- Running upgrade fff24971f091 -> 68787272dd92

ALTER TABLE animals ADD COLUMN deworming_status VARCHAR(255);

ALTER TABLE animals ALTER COLUMN species TYPE VARCHAR(7);

ALTER TABLE transactions ALTER COLUMN approved_by TYPE UUID;

ALTER TABLE transactions ALTER COLUMN reversal_of TYPE UUID;

ALTER TABLE transactions ADD FOREIGN KEY(approved_by) REFERENCES users (id);

ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(10);

UPDATE alembic_version SET version_num='68787272dd92' WHERE alembic_version.version_num = 'fff24971f091';

-- Running upgrade 68787272dd92 -> 4fffaddfdab0

CREATE TABLE staff (
    name VARCHAR(100) NOT NULL, 
    role VARCHAR(50) NOT NULL, 
    phone VARCHAR(20), 
    base_salary FLOAT NOT NULL, 
    performance_rating FLOAT NOT NULL, 
    is_active BOOLEAN, 
    profile_pic VARCHAR(255), 
    gender VARCHAR(20), 
    date_of_birth VARCHAR(50), 
    address VARCHAR(255), 
    emergency_contact VARCHAR(255), 
    employment_type VARCHAR(50), 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id)
);

CREATE INDEX ix_staff_id ON staff (id);

CREATE TABLE staff_queries (
    staff_id UUID NOT NULL, 
    title VARCHAR(200) NOT NULL, 
    description TEXT, 
    deduction_amount FLOAT NOT NULL, 
    is_resolved BOOLEAN, 
    resolution_notes TEXT, 
    resolved_at TIMESTAMP WITHOUT TIME ZONE, 
    issue_date DATE NOT NULL, 
    id UUID NOT NULL, 
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(staff_id) REFERENCES staff (id) ON DELETE CASCADE
);

CREATE INDEX ix_staff_queries_id ON staff_queries (id);

ALTER TABLE breeding_events ADD COLUMN sire_id VARCHAR(50);

ALTER TABLE breeding_events ADD COLUMN semen_batch_id VARCHAR(100);

ALTER TABLE breeding_events ADD COLUMN technician VARCHAR(100);

UPDATE alembic_version SET version_num='4fffaddfdab0' WHERE alembic_version.version_num = '68787272dd92';

COMMIT;

