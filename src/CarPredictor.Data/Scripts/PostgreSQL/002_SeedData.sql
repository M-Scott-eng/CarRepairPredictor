-- =============================================
-- Script: 002_SeedData.sql
-- Description: Seeds reference data for Car Repair Predictor (PostgreSQL/Supabase)
-- =============================================

-- =============================================
-- Seed Regions
-- =============================================

INSERT INTO region (region_code, region_name, currency_code, is_active)
VALUES 
    ('UK', 'United Kingdom', 'GBP', TRUE),
    ('US', 'United States', 'USD', FALSE)
ON CONFLICT (region_code) DO NOTHING;

-- =============================================
-- Seed Failure Categories
-- =============================================

INSERT INTO failure_category (category_code, category_name, description)
VALUES 
    ('ENGINE', 'Engine', 'Engine components including pistons, valves, timing chains, and engine management'),
    ('TRANSMISSION', 'Transmission', 'Gearbox, clutch, and drivetrain components'),
    ('BRAKES', 'Brakes', 'Brake pads, discs, calipers, and brake lines'),
    ('SUSPENSION', 'Suspension', 'Shock absorbers, springs, bushings, and anti-roll bars'),
    ('ELECTRICAL', 'Electrical', 'Battery, alternator, starter motor, and wiring'),
    ('EXHAUST', 'Exhaust', 'Catalytic converter, DPF, exhaust manifold, and silencers'),
    ('COOLING', 'Cooling System', 'Radiator, water pump, thermostat, and hoses'),
    ('STEERING', 'Steering', 'Power steering pump, rack, track rods, and wheel bearings'),
    ('FUEL', 'Fuel System', 'Fuel pump, injectors, fuel filter, and fuel lines'),
    ('TYRES', 'Tyres', 'Tyres and wheel alignment'),
    ('LIGHTING', 'Lighting', 'Headlights, brake lights, indicators, and bulbs'),
    ('BODY', 'Body/Corrosion', 'Rust, panel damage, and structural issues')
ON CONFLICT (category_code) DO NOTHING;

-- =============================================
-- Seed Sample Manufacturers
-- =============================================

INSERT INTO manufacturer (manufacturer_name, country_of_origin)
VALUES 
    ('BMW', 'Germany'),
    ('Mercedes-Benz', 'Germany'),
    ('Audi', 'Germany'),
    ('Volkswagen', 'Germany'),
    ('Ford', 'USA'),
    ('Vauxhall', 'UK'),
    ('Toyota', 'Japan'),
    ('Honda', 'Japan'),
    ('Nissan', 'Japan'),
    ('Peugeot', 'France'),
    ('Renault', 'France'),
    ('Fiat', 'Italy'),
    ('Land Rover', 'UK'),
    ('Jaguar', 'UK'),
    ('Mini', 'UK'),
    ('Kia', 'South Korea'),
    ('Hyundai', 'South Korea'),
    ('Mazda', 'Japan'),
    ('Volvo', 'Sweden'),
    ('Skoda', 'Czech Republic')
ON CONFLICT DO NOTHING;

-- =============================================
-- Seed Sample Vehicle Models (BMW as example)
-- =============================================

-- Get BMW manufacturer ID
DO $$
DECLARE
    bmw_id INTEGER;
    vw_id INTEGER;
    ford_id INTEGER;
BEGIN
    SELECT manufacturer_id INTO bmw_id FROM manufacturer WHERE manufacturer_name = 'BMW';
    SELECT manufacturer_id INTO vw_id FROM manufacturer WHERE manufacturer_name = 'Volkswagen';
    SELECT manufacturer_id INTO ford_id FROM manufacturer WHERE manufacturer_name = 'Ford';

    -- BMW Models
    INSERT INTO vehicle_model (manufacturer_id, model_name, year_start, year_end, engine_types)
    VALUES 
        (bmw_id, '3 Series (E90)', 2005, 2011, '318i,320i,325i,330i,320d,325d,330d'),
        (bmw_id, '3 Series (F30)', 2011, 2019, '318i,320i,330i,340i,318d,320d,330d'),
        (bmw_id, '5 Series (E60)', 2003, 2010, '520i,525i,530i,535i,520d,525d,530d'),
        (bmw_id, '5 Series (F10)', 2010, 2017, '520i,528i,535i,550i,520d,525d,530d'),
        (bmw_id, '1 Series (E87)', 2004, 2011, '116i,118i,120i,130i,118d,120d'),
        (bmw_id, '1 Series (F20)', 2011, 2019, '116i,118i,120i,125i,M135i,116d,118d,120d')
    ON CONFLICT DO NOTHING;

    -- VW Models
    INSERT INTO vehicle_model (manufacturer_id, model_name, year_start, year_end, engine_types)
    VALUES 
        (vw_id, 'Golf Mk6', 2008, 2012, '1.4TSI,1.6TDI,2.0TDI,2.0TSI GTI'),
        (vw_id, 'Golf Mk7', 2012, 2019, '1.0TSI,1.4TSI,1.6TDI,2.0TDI,2.0TSI GTI'),
        (vw_id, 'Passat B7', 2010, 2014, '1.4TSI,1.8TSI,2.0TSI,1.6TDI,2.0TDI'),
        (vw_id, 'Polo Mk5', 2009, 2017, '1.0,1.2TSI,1.4TSI,1.4TDI,1.6TDI')
    ON CONFLICT DO NOTHING;

    -- Ford Models
    INSERT INTO vehicle_model (manufacturer_id, model_name, year_start, year_end, engine_types)
    VALUES 
        (ford_id, 'Focus Mk3', 2011, 2018, '1.0 EcoBoost,1.5 EcoBoost,1.6,1.5 TDCi,2.0 TDCi'),
        (ford_id, 'Fiesta Mk7', 2008, 2017, '1.0 EcoBoost,1.25,1.4,1.4 TDCi,1.6 TDCi'),
        (ford_id, 'Mondeo Mk4', 2007, 2014, '1.6,2.0,2.3,1.8 TDCi,2.0 TDCi')
    ON CONFLICT DO NOTHING;
END $$;

-- =============================================
-- Seed Sample Failure Patterns (BMW 3 Series E90)
-- =============================================

DO $$
DECLARE
    e90_id INTEGER;
    engine_cat_id INTEGER;
    cooling_cat_id INTEGER;
    suspension_cat_id INTEGER;
    electrical_cat_id INTEGER;
    uk_region_id INTEGER;
BEGIN
    SELECT vehicle_model_id INTO e90_id FROM vehicle_model WHERE model_name = '3 Series (E90)';
    SELECT failure_category_id INTO engine_cat_id FROM failure_category WHERE category_code = 'ENGINE';
    SELECT failure_category_id INTO cooling_cat_id FROM failure_category WHERE category_code = 'COOLING';
    SELECT failure_category_id INTO suspension_cat_id FROM failure_category WHERE category_code = 'SUSPENSION';
    SELECT failure_category_id INTO electrical_cat_id FROM failure_category WHERE category_code = 'ELECTRICAL';
    SELECT region_id INTO uk_region_id FROM region WHERE region_code = 'UK';

    -- Insert failure patterns
    INSERT INTO failure_pattern (vehicle_model_id, failure_category_id, failure_name, description, min_mileage, max_mileage, base_probability, severity_level, is_common, data_source)
    VALUES 
        (e90_id, engine_cat_id, 'Timing Chain Stretch', 'N47 diesel engines prone to timing chain stretch causing rough running and potential engine damage', 60000, 150000, 0.35, 4, TRUE, 'MOT History'),
        (e90_id, engine_cat_id, 'VANOS Solenoid Failure', 'Variable valve timing solenoids can fail causing rough idle and power loss', 80000, NULL, 0.25, 2, TRUE, 'Workshop Data'),
        (e90_id, cooling_cat_id, 'Water Pump Failure', 'Electric water pump prone to early failure, causing overheating', 60000, 120000, 0.40, 3, TRUE, 'MOT History'),
        (e90_id, cooling_cat_id, 'Thermostat Housing Leak', 'Plastic thermostat housing cracks causing coolant leaks', 50000, NULL, 0.30, 2, TRUE, 'Workshop Data'),
        (e90_id, suspension_cat_id, 'Front Control Arm Bushes', 'Worn bushes cause knocking and poor handling', 40000, 100000, 0.45, 2, TRUE, 'MOT History'),
        (e90_id, electrical_cat_id, 'Battery Registration Issues', 'Battery requires registration when replaced or can damage charging system', NULL, NULL, 0.15, 1, FALSE, 'Technical Bulletin')
    ON CONFLICT DO NOTHING;

    -- Insert repair costs for the patterns
    INSERT INTO repair_cost (failure_pattern_id, region_id, min_cost, max_cost, average_cost, labour_hours, parts_only_cost, effective_from)
    SELECT fp.failure_pattern_id, uk_region_id, 
           CASE 
               WHEN fp.failure_name = 'Timing Chain Stretch' THEN 1500.00
               WHEN fp.failure_name = 'VANOS Solenoid Failure' THEN 250.00
               WHEN fp.failure_name = 'Water Pump Failure' THEN 400.00
               WHEN fp.failure_name = 'Thermostat Housing Leak' THEN 150.00
               WHEN fp.failure_name = 'Front Control Arm Bushes' THEN 200.00
               WHEN fp.failure_name = 'Battery Registration Issues' THEN 80.00
           END,
           CASE 
               WHEN fp.failure_name = 'Timing Chain Stretch' THEN 3500.00
               WHEN fp.failure_name = 'VANOS Solenoid Failure' THEN 450.00
               WHEN fp.failure_name = 'Water Pump Failure' THEN 700.00
               WHEN fp.failure_name = 'Thermostat Housing Leak' THEN 350.00
               WHEN fp.failure_name = 'Front Control Arm Bushes' THEN 450.00
               WHEN fp.failure_name = 'Battery Registration Issues' THEN 150.00
           END,
           CASE 
               WHEN fp.failure_name = 'Timing Chain Stretch' THEN 2500.00
               WHEN fp.failure_name = 'VANOS Solenoid Failure' THEN 350.00
               WHEN fp.failure_name = 'Water Pump Failure' THEN 550.00
               WHEN fp.failure_name = 'Thermostat Housing Leak' THEN 250.00
               WHEN fp.failure_name = 'Front Control Arm Bushes' THEN 325.00
               WHEN fp.failure_name = 'Battery Registration Issues' THEN 115.00
           END,
           CASE 
               WHEN fp.failure_name = 'Timing Chain Stretch' THEN 8.0
               WHEN fp.failure_name = 'VANOS Solenoid Failure' THEN 1.5
               WHEN fp.failure_name = 'Water Pump Failure' THEN 2.5
               WHEN fp.failure_name = 'Thermostat Housing Leak' THEN 1.5
               WHEN fp.failure_name = 'Front Control Arm Bushes' THEN 2.0
               WHEN fp.failure_name = 'Battery Registration Issues' THEN 0.5
           END,
           CASE 
               WHEN fp.failure_name = 'Timing Chain Stretch' THEN 800.00
               WHEN fp.failure_name = 'VANOS Solenoid Failure' THEN 150.00
               WHEN fp.failure_name = 'Water Pump Failure' THEN 250.00
               WHEN fp.failure_name = 'Thermostat Housing Leak' THEN 80.00
               WHEN fp.failure_name = 'Front Control Arm Bushes' THEN 120.00
               WHEN fp.failure_name = 'Battery Registration Issues' THEN 0.00
           END,
           CURRENT_DATE
    FROM failure_pattern fp
    WHERE fp.vehicle_model_id = e90_id
    ON CONFLICT DO NOTHING;
END $$;
