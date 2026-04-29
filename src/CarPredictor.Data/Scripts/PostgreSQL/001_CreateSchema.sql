-- =============================================
-- Script: 001_CreateSchema.sql
-- Description: Creates all tables for Car Repair Predictor (PostgreSQL/Supabase)
-- =============================================

-- =============================================
-- Reference Tables
-- =============================================

CREATE TABLE IF NOT EXISTS region (
    region_id       SERIAL PRIMARY KEY,
    region_code     VARCHAR(10) NOT NULL UNIQUE,
    region_name     VARCHAR(100) NOT NULL,
    currency_code   VARCHAR(3) NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS manufacturer (
    manufacturer_id     SERIAL PRIMARY KEY,
    manufacturer_name   VARCHAR(100) NOT NULL,
    country_of_origin   VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS vehicle_model (
    vehicle_model_id    SERIAL PRIMARY KEY,
    manufacturer_id     INTEGER NOT NULL REFERENCES manufacturer(manufacturer_id),
    model_name          VARCHAR(100) NOT NULL,
    year_start          INTEGER NOT NULL,
    year_end            INTEGER,
    engine_types        VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS failure_category (
    failure_category_id SERIAL PRIMARY KEY,
    category_code       VARCHAR(50) NOT NULL UNIQUE,
    category_name       VARCHAR(100) NOT NULL,
    description         VARCHAR(500)
);

-- =============================================
-- Core Data Tables
-- =============================================

CREATE TABLE IF NOT EXISTS failure_pattern (
    failure_pattern_id  SERIAL PRIMARY KEY,
    vehicle_model_id    INTEGER NOT NULL REFERENCES vehicle_model(vehicle_model_id),
    failure_category_id INTEGER NOT NULL REFERENCES failure_category(failure_category_id),
    failure_name        VARCHAR(200) NOT NULL,
    description         VARCHAR(1000),
    min_mileage         INTEGER,
    max_mileage         INTEGER,
    min_age             INTEGER,
    max_age             INTEGER,
    base_probability    DECIMAL(5,4) NOT NULL CHECK (base_probability BETWEEN 0.0000 AND 1.0000),
    severity_level      SMALLINT NOT NULL CHECK (severity_level BETWEEN 1 AND 4),
    is_common           BOOLEAN NOT NULL DEFAULT FALSE,
    data_source         VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS repair_cost (
    repair_cost_id      SERIAL PRIMARY KEY,
    failure_pattern_id  INTEGER NOT NULL REFERENCES failure_pattern(failure_pattern_id),
    region_id           INTEGER NOT NULL REFERENCES region(region_id),
    min_cost            DECIMAL(10,2) NOT NULL,
    max_cost            DECIMAL(10,2) NOT NULL,
    average_cost        DECIMAL(10,2) NOT NULL,
    labour_hours        DECIMAL(5,2),
    parts_only_cost     DECIMAL(10,2),
    effective_from      DATE NOT NULL,
    effective_to        DATE,
    CONSTRAINT chk_repair_cost_min_max CHECK (min_cost <= max_cost)
);

CREATE TABLE IF NOT EXISTS mot_defect_mapping (
    mot_defect_mapping_id   SERIAL PRIMARY KEY,
    mot_defect_code         VARCHAR(20) NOT NULL,
    mot_defect_text         VARCHAR(500) NOT NULL,
    failure_category_id     INTEGER NOT NULL REFERENCES failure_category(failure_category_id),
    probability_weight      DECIMAL(5,4) NOT NULL
);

-- =============================================
-- Indexes for better query performance
-- =============================================

CREATE INDEX IF NOT EXISTS idx_vehicle_model_manufacturer ON vehicle_model(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_failure_pattern_vehicle ON failure_pattern(vehicle_model_id);
CREATE INDEX IF NOT EXISTS idx_failure_pattern_category ON failure_pattern(failure_category_id);
CREATE INDEX IF NOT EXISTS idx_repair_cost_pattern ON repair_cost(failure_pattern_id);
CREATE INDEX IF NOT EXISTS idx_repair_cost_region ON repair_cost(region_id);
CREATE INDEX IF NOT EXISTS idx_repair_cost_effective ON repair_cost(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_mot_defect_category ON mot_defect_mapping(failure_category_id);
