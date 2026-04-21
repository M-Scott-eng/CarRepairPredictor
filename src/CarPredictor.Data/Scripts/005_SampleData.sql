-- =============================================
-- Script: 005_SampleData.sql
-- Description: Sample data for Used Car Repair Cost Predictor
-- =============================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- COUNTRIES
-- =============================================

SET IDENTITY_INSERT dbo.Countries ON;

INSERT INTO dbo.Countries (CountryId, CountryCode, CountryName, CurrencyCode, CurrencySymbol, LabourRatePerHour, VatRate, HasMotSystem, InspectionApiUrl, IsActive)
VALUES
    (1, 'GB', 'United Kingdom', 'GBP', '£', 85.00, 0.20, 1, 'https://beta.check-mot.service.gov.uk', 1),
    (2, 'US', 'United States', 'USD', '$', 95.00, 0.00, 0, NULL, 1),
    (3, 'DE', 'Germany', 'EUR', '€', 110.00, 0.19, 1, NULL, 1),
    (4, 'FR', 'France', 'EUR', '€', 90.00, 0.20, 1, NULL, 1),
    (5, 'IE', 'Ireland', 'EUR', '€', 80.00, 0.23, 1, NULL, 1),
    (6, 'AU', 'Australia', 'AUD', '$', 100.00, 0.10, 0, NULL, 0),
    (7, 'CA', 'Canada', 'CAD', '$', 90.00, 0.13, 0, NULL, 0);

SET IDENTITY_INSERT dbo.Countries OFF;
GO

-- =============================================
-- CAR MAKES
-- =============================================

SET IDENTITY_INSERT dbo.CarMakes ON;

INSERT INTO dbo.CarMakes (MakeId, MakeName, MakeCode, CountryOfOrigin, IsLuxuryBrand, IsActive)
VALUES
    (1, 'Ford', 'FORD', 'US', 0, 1),
    (2, 'Vauxhall', 'VAUX', 'GB', 0, 1),
    (3, 'Volkswagen', 'VW', 'DE', 0, 1),
    (4, 'BMW', 'BMW', 'DE', 1, 1),
    (5, 'Mercedes-Benz', 'MERC', 'DE', 1, 1),
    (6, 'Audi', 'AUDI', 'DE', 1, 1),
    (7, 'Toyota', 'TOYO', 'JP', 0, 1),
    (8, 'Honda', 'HOND', 'JP', 0, 1),
    (9, 'Nissan', 'NISS', 'JP', 0, 1),
    (10, 'Peugeot', 'PEUG', 'FR', 0, 1),
    (11, 'Renault', 'RENA', 'FR', 0, 1),
    (12, 'Fiat', 'FIAT', 'IT', 0, 1),
    (13, 'Hyundai', 'HYUN', 'KR', 0, 1),
    (14, 'Kia', 'KIA', 'KR', 0, 1),
    (15, 'Skoda', 'SKOD', 'CZ', 0, 1),
    (16, 'SEAT', 'SEAT', 'ES', 0, 1),
    (17, 'Mazda', 'MAZD', 'JP', 0, 1),
    (18, 'Volvo', 'VOLV', 'SE', 1, 1),
    (19, 'Land Rover', 'LANDR', 'GB', 1, 1),
    (20, 'Jaguar', 'JAG', 'GB', 1, 1),
    (21, 'Mini', 'MINI', 'GB', 0, 1),
    (22, 'Citroen', 'CITR', 'FR', 0, 1),
    (23, 'Suzuki', 'SUZU', 'JP', 0, 1),
    (24, 'Mitsubishi', 'MITS', 'JP', 0, 1),
    (25, 'Porsche', 'PORS', 'DE', 1, 1);

SET IDENTITY_INSERT dbo.CarMakes OFF;
GO

-- =============================================
-- CAR MODELS
-- =============================================

SET IDENTITY_INSERT dbo.CarModels ON;

INSERT INTO dbo.CarModels (ModelId, MakeId, ModelName, BodyType, FuelTypes, TransmissionTypes, ProductionStartYear, ProductionEndYear, IsActive)
VALUES
    -- Ford
    (1, 1, 'Focus', 'Hatchback', 'Petrol,Diesel', 'Manual,Automatic', 1998, NULL, 1),
    (2, 1, 'Fiesta', 'Hatchback', 'Petrol,Diesel', 'Manual,Automatic', 1976, 2023, 1),
    (3, 1, 'Mondeo', 'Saloon', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 1993, 2022, 1),
    (4, 1, 'Kuga', 'SUV', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 2008, NULL, 1),
    (5, 1, 'Puma', 'SUV', 'Petrol,Hybrid', 'Manual,Automatic', 2019, NULL, 1),
    
    -- Vauxhall
    (6, 2, 'Corsa', 'Hatchback', 'Petrol,Diesel,Electric', 'Manual,Automatic', 1982, NULL, 1),
    (7, 2, 'Astra', 'Hatchback', 'Petrol,Diesel', 'Manual,Automatic', 1979, NULL, 1),
    (8, 2, 'Insignia', 'Saloon', 'Petrol,Diesel', 'Manual,Automatic', 2008, 2022, 1),
    (9, 2, 'Mokka', 'SUV', 'Petrol,Diesel,Electric', 'Manual,Automatic', 2012, NULL, 1),
    
    -- Volkswagen
    (10, 3, 'Golf', 'Hatchback', 'Petrol,Diesel,Hybrid,Electric', 'Manual,Automatic', 1974, NULL, 1),
    (11, 3, 'Polo', 'Hatchback', 'Petrol,Diesel', 'Manual,Automatic', 1975, NULL, 1),
    (12, 3, 'Tiguan', 'SUV', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 2007, NULL, 1),
    (13, 3, 'Passat', 'Saloon', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 1973, NULL, 1),
    (14, 3, 'T-Roc', 'SUV', 'Petrol,Diesel', 'Manual,Automatic', 2017, NULL, 1),
    
    -- BMW
    (15, 4, '1 Series', 'Hatchback', 'Petrol,Diesel', 'Manual,Automatic', 2004, NULL, 1),
    (16, 4, '3 Series', 'Saloon', 'Petrol,Diesel,Hybrid,Electric', 'Manual,Automatic', 1975, NULL, 1),
    (17, 4, '5 Series', 'Saloon', 'Petrol,Diesel,Hybrid', 'Automatic', 1972, NULL, 1),
    (18, 4, 'X1', 'SUV', 'Petrol,Diesel,Hybrid', 'Automatic', 2009, NULL, 1),
    (19, 4, 'X3', 'SUV', 'Petrol,Diesel,Hybrid', 'Automatic', 2003, NULL, 1),
    (20, 4, 'X5', 'SUV', 'Petrol,Diesel,Hybrid', 'Automatic', 1999, NULL, 1),
    
    -- Mercedes-Benz
    (21, 5, 'A-Class', 'Hatchback', 'Petrol,Diesel,Hybrid', 'Automatic', 1997, NULL, 1),
    (22, 5, 'C-Class', 'Saloon', 'Petrol,Diesel,Hybrid', 'Automatic', 1993, NULL, 1),
    (23, 5, 'E-Class', 'Saloon', 'Petrol,Diesel,Hybrid', 'Automatic', 1993, NULL, 1),
    (24, 5, 'GLA', 'SUV', 'Petrol,Diesel', 'Automatic', 2013, NULL, 1),
    (25, 5, 'GLC', 'SUV', 'Petrol,Diesel,Hybrid', 'Automatic', 2015, NULL, 1),
    
    -- Audi
    (26, 6, 'A1', 'Hatchback', 'Petrol', 'Manual,Automatic', 2010, NULL, 1),
    (27, 6, 'A3', 'Hatchback', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 1996, NULL, 1),
    (28, 6, 'A4', 'Saloon', 'Petrol,Diesel', 'Manual,Automatic', 1994, NULL, 1),
    (29, 6, 'Q3', 'SUV', 'Petrol,Diesel', 'Manual,Automatic', 2011, NULL, 1),
    (30, 6, 'Q5', 'SUV', 'Petrol,Diesel,Hybrid', 'Automatic', 2008, NULL, 1),
    
    -- Toyota
    (31, 7, 'Yaris', 'Hatchback', 'Petrol,Hybrid', 'Manual,Automatic', 1999, NULL, 1),
    (32, 7, 'Corolla', 'Hatchback', 'Petrol,Hybrid', 'Manual,Automatic', 1966, NULL, 1),
    (33, 7, 'RAV4', 'SUV', 'Petrol,Hybrid', 'Manual,Automatic', 1994, NULL, 1),
    (34, 7, 'C-HR', 'SUV', 'Petrol,Hybrid', 'Automatic', 2016, NULL, 1),
    (35, 7, 'Prius', 'Hatchback', 'Hybrid', 'Automatic', 1997, NULL, 1),
    
    -- Honda
    (36, 8, 'Civic', 'Hatchback', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 1972, NULL, 1),
    (37, 8, 'Jazz', 'Hatchback', 'Petrol,Hybrid', 'Manual,Automatic', 2001, NULL, 1),
    (38, 8, 'CR-V', 'SUV', 'Petrol,Diesel,Hybrid', 'Manual,Automatic', 1995, NULL, 1),
    (39, 8, 'HR-V', 'SUV', 'Petrol,Hybrid', 'Manual,Automatic', 1998, NULL, 1);

SET IDENTITY_INSERT dbo.CarModels OFF;
GO

-- =============================================
-- MODEL YEARS (Sample variants)
-- =============================================

SET IDENTITY_INSERT dbo.ModelYears ON;

INSERT INTO dbo.ModelYears (ModelYearId, ModelId, [Year], Generation, EngineCode, EngineSize, EnginePower, FuelType, Transmission, DriveType, IsActive)
VALUES
    -- Ford Focus variants
    (1, 1, 2018, 'Mk4', 'EcoBoost', 1.0, 125, 'Petrol', 'Manual', 'FWD', 1),
    (2, 1, 2018, 'Mk4', 'EcoBoost', 1.5, 150, 'Petrol', 'Automatic', 'FWD', 1),
    (3, 1, 2019, 'Mk4', 'EcoBlue', 1.5, 120, 'Diesel', 'Manual', 'FWD', 1),
    (4, 1, 2020, 'Mk4', 'EcoBoost', 1.0, 125, 'Petrol', 'Manual', 'FWD', 1),
    (5, 1, 2021, 'Mk4', 'EcoBoost', 1.0, 155, 'Petrol', 'Automatic', 'FWD', 1),
    
    -- VW Golf variants
    (6, 10, 2017, 'Mk7.5', 'CZCA', 1.4, 125, 'Petrol', 'Manual', 'FWD', 1),
    (7, 10, 2018, 'Mk7.5', 'DFGA', 1.6, 115, 'Diesel', 'Manual', 'FWD', 1),
    (8, 10, 2019, 'Mk7.5', 'DKRF', 2.0, 150, 'Diesel', 'Automatic', 'FWD', 1),
    (9, 10, 2020, 'Mk8', 'DFYA', 1.5, 130, 'Petrol', 'Manual', 'FWD', 1),
    (10, 10, 2021, 'Mk8', 'DFYA', 1.5, 150, 'Petrol', 'Automatic', 'FWD', 1),
    
    -- BMW 3 Series variants
    (11, 16, 2017, 'F30', 'B47', 2.0, 150, 'Diesel', 'Automatic', 'RWD', 1),
    (12, 16, 2018, 'F30', 'B48', 2.0, 184, 'Petrol', 'Automatic', 'RWD', 1),
    (13, 16, 2019, 'G20', 'B47', 2.0, 150, 'Diesel', 'Automatic', 'RWD', 1),
    (14, 16, 2020, 'G20', 'B48', 2.0, 184, 'Petrol', 'Automatic', 'RWD', 1),
    (15, 16, 2021, 'G20', 'B48', 2.0, 258, 'Petrol', 'Automatic', 'AWD', 1),
    
    -- Mercedes C-Class variants
    (16, 22, 2018, 'W205', 'OM654', 2.0, 194, 'Diesel', 'Automatic', 'RWD', 1),
    (17, 22, 2019, 'W205', 'M264', 1.5, 184, 'Petrol', 'Automatic', 'RWD', 1),
    (18, 22, 2020, 'W205', 'M264', 2.0, 258, 'Petrol', 'Automatic', 'RWD', 1),
    (19, 22, 2021, 'W206', 'M254', 2.0, 204, 'Petrol', 'Automatic', 'RWD', 1),
    (20, 22, 2022, 'W206', 'OM654', 2.0, 200, 'Diesel', 'Automatic', 'RWD', 1),
    
    -- Toyota Corolla variants
    (21, 32, 2019, 'E210', 'M20A-FKS', 2.0, 170, 'Petrol', 'Automatic', 'FWD', 1),
    (22, 32, 2019, 'E210', '2ZR-FXE', 1.8, 122, 'Hybrid', 'Automatic', 'FWD', 1),
    (23, 32, 2020, 'E210', 'M20A-FXS', 2.0, 184, 'Hybrid', 'Automatic', 'FWD', 1),
    (24, 32, 2021, 'E210', '2ZR-FXE', 1.8, 122, 'Hybrid', 'Automatic', 'FWD', 1),
    (25, 32, 2022, 'E210', 'M20A-FXS', 2.0, 196, 'Hybrid', 'Automatic', 'FWD', 1);

SET IDENTITY_INSERT dbo.ModelYears OFF;
GO

-- =============================================
-- FAILURE CATEGORIES
-- =============================================

SET IDENTITY_INSERT dbo.FailureCategories ON;

INSERT INTO dbo.FailureCategories (CategoryId, CategoryCode, CategoryName, [Description], ParentCategoryId, DisplayOrder, IsActive)
VALUES
    (1, 'ENGINE', 'Engine', 'Engine and internal components', NULL, 1, 1),
    (2, 'TRANS', 'Transmission', 'Gearbox and drivetrain components', NULL, 2, 1),
    (3, 'BRAKES', 'Brakes', 'Braking system components', NULL, 3, 1),
    (4, 'SUSPENSION', 'Suspension', 'Suspension and steering components', NULL, 4, 1),
    (5, 'ELECTRICAL', 'Electrical', 'Electrical systems and components', NULL, 5, 1),
    (6, 'EXHAUST', 'Exhaust', 'Exhaust system and emissions', NULL, 6, 1),
    (7, 'COOLING', 'Cooling', 'Cooling system components', NULL, 7, 1),
    (8, 'FUEL', 'Fuel System', 'Fuel delivery and injection', NULL, 8, 1),
    (9, 'STEERING', 'Steering', 'Steering components', NULL, 9, 1),
    (10, 'TYRES', 'Tyres & Wheels', 'Tyres, wheels, and related', NULL, 10, 1),
    (11, 'LIGHTING', 'Lighting', 'Lights and indicators', NULL, 11, 1),
    (12, 'BODY', 'Body & Corrosion', 'Body panels and rust', NULL, 12, 1),
    (13, 'INTERIOR', 'Interior', 'Interior trim and components', NULL, 13, 1),
    (14, 'AC', 'Air Conditioning', 'Climate control system', NULL, 14, 1),
    (15, 'TURBO', 'Turbocharger', 'Turbo and intercooler', 1, 15, 1),
    (16, 'TIMING', 'Timing System', 'Timing belt/chain', 1, 16, 1),
    (17, 'CLUTCH', 'Clutch', 'Clutch assembly', 2, 17, 1),
    (18, 'DPF', 'DPF/Emissions', 'Diesel particulate filter', 6, 18, 1),
    (19, 'EGR', 'EGR System', 'Exhaust gas recirculation', 6, 19, 1),
    (20, 'BATTERY', 'Battery/Alternator', '12V system', 5, 20, 1);

SET IDENTITY_INSERT dbo.FailureCategories OFF;
GO

-- =============================================
-- FAILURE RULES (Sample rules)
-- =============================================

SET IDENTITY_INSERT dbo.FailureRules ON;

INSERT INTO dbo.FailureRules (RuleId, ModelYearId, ModelId, MakeId, CategoryId, RuleName, RuleCode, [Description], MinMileage, MaxMileage, MinAge, MaxAge, FuelTypeFilter, TransmissionFilter, BaseProbability, MileageMultiplier, AgeMultiplier, SeverityLevel, DataSource, ConfidenceLevel, SampleSize, IsRecall, IsActive)
VALUES
    -- VW Golf DSG Issues (Model specific)
    (1, NULL, 10, NULL, 2, 'DSG Mechatronic Unit Failure', 'VW-GOLF-DSG-001', 'DSG gearbox mechatronic unit failure causing jerky gear changes or complete failure', 60000, 120000, 4, 8, NULL, 'Automatic', 0.1500, 0.000010, 0.020000, 3, 'MOT_DATA', 0.85, 15000, 0, 1),
    
    -- BMW Timing Chain (Engine code specific - N47)
    (2, NULL, NULL, 4, 16, 'Timing Chain Tensioner Wear', 'BMW-N47-TC-001', 'Premature timing chain and tensioner wear on N47 diesel engines', 50000, 100000, 3, 7, 'Diesel', NULL, 0.2000, 0.000015, 0.025000, 4, 'MANUFACTURER', 0.90, 8500, 0, 1),
    
    -- Ford EcoBoost Coolant Loss
    (3, NULL, 1, NULL, 7, 'Coolant Loss - Head Gasket', 'FORD-ECO-CL-001', 'EcoBoost engine coolant loss due to head gasket failure', 40000, 80000, 2, 6, 'Petrol', NULL, 0.0800, 0.000008, 0.015000, 3, 'USER_REPORTS', 0.75, 3200, 0, 1),
    
    -- Mercedes Air Suspension
    (4, NULL, NULL, 5, 4, 'Air Suspension Compressor Failure', 'MERC-AIRSUSP-001', 'Air suspension compressor failure on Airmatic equipped vehicles', 80000, 150000, 5, 10, NULL, NULL, 0.1200, 0.000005, 0.018000, 2, 'MOT_DATA', 0.80, 5600, 0, 1),
    
    -- Universal DPF Issues (Diesel)
    (5, NULL, NULL, NULL, 18, 'DPF Blockage/Regeneration Issues', 'GEN-DPF-001', 'DPF blockage from short journeys requiring forced regeneration or replacement', 30000, 100000, 2, 8, 'Diesel', NULL, 0.2500, 0.000020, 0.022000, 2, 'MOT_DATA', 0.88, 45000, 0, 1),
    
    -- Toyota Hybrid Battery (Model specific)
    (6, NULL, 35, NULL, 5, 'Hybrid Battery Degradation', 'TOYO-PRIUS-HV-001', 'Hybrid battery capacity degradation requiring replacement', 100000, 200000, 8, 15, 'Hybrid', NULL, 0.0500, 0.000003, 0.008000, 3, 'MANUFACTURER', 0.92, 12000, 0, 1),
    
    -- Audi Oil Consumption
    (7, NULL, NULL, 6, 1, 'Excessive Oil Consumption', 'AUDI-TFSI-OIL-001', 'High oil consumption on TFSI engines requiring top-ups between services', 60000, 120000, 4, 10, 'Petrol', NULL, 0.1800, 0.000012, 0.020000, 2, 'USER_REPORTS', 0.82, 7800, 0, 1),
    
    -- Universal Brake Disc Wear
    (8, NULL, NULL, NULL, 3, 'Front Brake Disc Wear', 'GEN-BRAKE-FD-001', 'Front brake disc wear requiring replacement', 25000, 60000, 2, 5, NULL, NULL, 0.3500, 0.000025, 0.015000, 1, 'MOT_DATA', 0.95, 120000, 0, 1),
    
    -- Land Rover Electrical Gremlins
    (9, NULL, NULL, 19, 5, 'Infotainment System Faults', 'LANDR-ELEC-001', 'Touchscreen and infotainment system freezing or blank screens', 20000, 80000, 1, 6, NULL, NULL, 0.2200, 0.000008, 0.030000, 2, 'USER_REPORTS', 0.78, 4500, 0, 1),
    
    -- Vauxhall Corsa Steering
    (10, NULL, 6, NULL, 9, 'Electric Power Steering Failure', 'VAUX-CORSA-EPS-001', 'EPS motor or column failure causing heavy steering', 40000, 100000, 3, 8, NULL, NULL, 0.0900, 0.000007, 0.012000, 3, 'MOT_DATA', 0.80, 6700, 0, 1),
    
    -- Honda CVT Issues
    (11, NULL, 36, NULL, 2, 'CVT Shudder/Judder', 'HONDA-CVT-001', 'CVT transmission shudder during acceleration', 50000, 100000, 3, 7, NULL, 'Automatic', 0.0700, 0.000006, 0.010000, 2, 'USER_REPORTS', 0.72, 2800, 0, 1),
    
    -- Universal Clutch Wear (Manual)
    (12, NULL, NULL, NULL, 17, 'Clutch Wear', 'GEN-CLUTCH-001', 'Clutch friction plate wear requiring replacement', 60000, 120000, 4, 10, NULL, 'Manual', 0.4000, 0.000030, 0.025000, 2, 'MOT_DATA', 0.90, 85000, 0, 1),
    
    -- Turbo Failure (Diesel general)
    (13, NULL, NULL, NULL, 15, 'Turbocharger Failure', 'GEN-TURBO-001', 'Turbocharger failure from oil starvation or wear', 80000, 150000, 5, 12, 'Diesel', NULL, 0.0800, 0.000008, 0.012000, 3, 'MOT_DATA', 0.85, 35000, 0, 1),
    
    -- EGR Valve Issues (Diesel)
    (14, NULL, NULL, NULL, 19, 'EGR Valve Carbon Build-up', 'GEN-EGR-001', 'EGR valve sticking due to carbon deposits', 40000, 100000, 3, 8, 'Diesel', NULL, 0.2000, 0.000015, 0.018000, 2, 'MOT_DATA', 0.88, 42000, 0, 1),
    
    -- AC Compressor
    (15, NULL, NULL, NULL, 14, 'AC Compressor Failure', 'GEN-AC-001', 'Air conditioning compressor seizure or leak', 60000, 120000, 5, 10, NULL, NULL, 0.0600, 0.000005, 0.010000, 2, 'USER_REPORTS', 0.75, 15000, 0, 1);

SET IDENTITY_INSERT dbo.FailureRules OFF;
GO

-- =============================================
-- REPAIR COST RANGES (UK Prices)
-- =============================================

SET IDENTITY_INSERT dbo.RepairCostRanges ON;

INSERT INTO dbo.RepairCostRanges (CostRangeId, RuleId, CountryId, PartsMinCost, PartsMaxCost, PartsAvgCost, LabourMinHours, LabourMaxHours, LabourAvgHours, TotalMinCost, TotalMaxCost, TotalAvgCost, DealerPremium, EffectiveFrom, PriceSource)
VALUES
    -- DSG Mechatronic (UK)
    (1, 1, 1, 800.00, 1500.00, 1100.00, 3.0, 5.0, 4.0, 1055.00, 1925.00, 1440.00, 0.25, '2024-01-01', 'DEALER'),
    
    -- BMW Timing Chain (UK)
    (2, 2, 1, 400.00, 800.00, 600.00, 8.0, 12.0, 10.0, 1080.00, 1820.00, 1450.00, 0.30, '2024-01-01', 'INDEPENDENT'),
    
    -- Ford EcoBoost Head Gasket (UK)
    (3, 3, 1, 150.00, 300.00, 220.00, 10.0, 14.0, 12.0, 1000.00, 1490.00, 1240.00, 0.20, '2024-01-01', 'INDEPENDENT'),
    
    -- Mercedes Air Suspension (UK)
    (4, 4, 1, 600.00, 1200.00, 850.00, 2.0, 4.0, 3.0, 770.00, 1540.00, 1105.00, 0.35, '2024-01-01', 'DEALER'),
    
    -- DPF Replacement (UK)
    (5, 5, 1, 400.00, 1200.00, 700.00, 2.0, 4.0, 3.0, 570.00, 1540.00, 955.00, 0.20, '2024-01-01', 'INDEPENDENT'),
    
    -- Toyota Hybrid Battery (UK)
    (6, 6, 1, 1500.00, 3000.00, 2200.00, 3.0, 5.0, 4.0, 1755.00, 3425.00, 2540.00, 0.15, '2024-01-01', 'DEALER'),
    
    -- Audi Oil Consumption Fix (UK) - Piston rings
    (7, 7, 1, 300.00, 600.00, 450.00, 15.0, 20.0, 17.5, 1575.00, 2300.00, 1937.50, 0.25, '2024-01-01', 'INDEPENDENT'),
    
    -- Front Brake Discs & Pads (UK)
    (8, 8, 1, 80.00, 200.00, 130.00, 1.0, 2.0, 1.5, 165.00, 370.00, 257.50, 0.30, '2024-01-01', 'INDEPENDENT'),
    
    -- Land Rover Infotainment (UK)
    (9, 9, 1, 400.00, 1500.00, 800.00, 1.0, 3.0, 2.0, 485.00, 1755.00, 970.00, 0.40, '2024-01-01', 'DEALER'),
    
    -- Vauxhall EPS (UK)
    (10, 10, 1, 300.00, 700.00, 500.00, 2.0, 4.0, 3.0, 470.00, 1040.00, 755.00, 0.20, '2024-01-01', 'INDEPENDENT'),
    
    -- Honda CVT (UK)
    (11, 11, 1, 200.00, 400.00, 280.00, 4.0, 6.0, 5.0, 540.00, 910.00, 705.00, 0.25, '2024-01-01', 'DEALER'),
    
    -- Clutch Replacement (UK)
    (12, 12, 1, 150.00, 400.00, 250.00, 4.0, 8.0, 6.0, 490.00, 1080.00, 760.00, 0.20, '2024-01-01', 'INDEPENDENT'),
    
    -- Turbo Replacement (UK)
    (13, 13, 1, 500.00, 1500.00, 900.00, 4.0, 8.0, 6.0, 840.00, 2180.00, 1410.00, 0.25, '2024-01-01', 'INDEPENDENT'),
    
    -- EGR Valve (UK)
    (14, 14, 1, 150.00, 400.00, 250.00, 1.5, 3.0, 2.0, 277.50, 655.00, 420.00, 0.20, '2024-01-01', 'INDEPENDENT'),
    
    -- AC Compressor (UK)
    (15, 15, 1, 250.00, 600.00, 400.00, 3.0, 5.0, 4.0, 505.00, 1025.00, 740.00, 0.25, '2024-01-01', 'INDEPENDENT');

SET IDENTITY_INSERT dbo.RepairCostRanges OFF;
GO

-- =============================================
-- RELIABILITY SCORES (Sample)
-- =============================================

SET IDENTITY_INSERT dbo.ReliabilityScores ON;

INSERT INTO dbo.ReliabilityScores (ScoreId, ModelYearId, ModelId, MakeId, OverallScore, ScoreGrade, EngineScore, TransmissionScore, ElectricalScore, SuspensionScore, BrakesScore, TotalDataPoints, MotFailureRate, AvgAnnualRepairCost, VsBrandAverage, Ranking, TotalInClass)
VALUES
    -- Toyota Corolla Hybrid 2019 - Top reliability
    (1, 22, NULL, NULL, 92.50, 'A', 95.00, 94.00, 90.00, 91.00, 93.00, 8500, 0.0820, 280.00, 8.50, 1, 45),
    
    -- VW Golf 2020 - Good reliability
    (2, 9, NULL, NULL, 78.00, 'B', 80.00, 72.00, 82.00, 79.00, 85.00, 12000, 0.1250, 520.00, 2.00, 12, 45),
    
    -- BMW 3 Series 2019 - Average reliability
    (3, 13, NULL, NULL, 68.50, 'C', 65.00, 70.00, 62.00, 72.00, 80.00, 9200, 0.1580, 850.00, -5.50, 28, 45),
    
    -- Ford Focus 2018 - Good reliability
    (4, 1, NULL, NULL, 75.00, 'B', 72.00, 78.00, 76.00, 74.00, 82.00, 15000, 0.1180, 450.00, 3.00, 15, 45),
    
    -- Mercedes C-Class 2019 - Below average
    (5, 17, NULL, NULL, 62.00, 'C', 68.00, 65.00, 52.00, 70.00, 75.00, 7800, 0.1720, 1100.00, -8.00, 32, 45),
    
    -- Make-level scores
    (6, NULL, NULL, 7, 89.00, 'A', 92.00, 88.00, 86.00, 88.00, 90.00, 125000, 0.0950, 320.00, NULL, 1, 25),  -- Toyota
    (7, NULL, NULL, 8, 86.50, 'A', 90.00, 82.00, 85.00, 86.00, 88.00, 85000, 0.1020, 380.00, NULL, 2, 25),   -- Honda
    (8, NULL, NULL, 4, 65.00, 'C', 62.00, 68.00, 58.00, 70.00, 75.00, 95000, 0.1650, 920.00, NULL, 18, 25),  -- BMW
    (9, NULL, NULL, 5, 60.00, 'C', 65.00, 62.00, 48.00, 68.00, 72.00, 72000, 0.1780, 1150.00, NULL, 21, 25), -- Mercedes
    (10, NULL, NULL, 1, 72.00, 'B', 70.00, 75.00, 72.00, 71.00, 80.00, 180000, 0.1280, 480.00, NULL, 10, 25); -- Ford

SET IDENTITY_INSERT dbo.ReliabilityScores OFF;
GO

-- =============================================
-- SUBSCRIPTION PLANS
-- =============================================

SET IDENTITY_INSERT dbo.SubscriptionPlans ON;

INSERT INTO dbo.SubscriptionPlans (PlanId, PlanCode, PlanName, [Description], MonthlyPrice, AnnualPrice, CurrencyCode, MonthlySearches, MonthlyReports, HistoryDays, HasApiAccess, HasPdfExport, HasPrioritySupport, HasMotIntegration, HasBulkSearch, IsActive, DisplayOrder)
VALUES
    (1, 'FREE', 'Free', 'Basic access with limited searches', 0.00, NULL, 'GBP', 5, 1, 7, 0, 0, 0, 0, 0, 1, 1),
    (2, 'BASIC', 'Basic', 'Great for occasional car buyers', 4.99, 49.99, 'GBP', 20, 5, 30, 0, 1, 0, 1, 0, 1, 2),
    (3, 'PRO', 'Professional', 'Perfect for enthusiasts and regular buyers', 9.99, 99.99, 'GBP', 100, 20, 365, 0, 1, 1, 1, 0, 1, 3),
    (4, 'DEALER', 'Dealer', 'For car dealers and traders', 49.99, 499.99, 'GBP', NULL, NULL, NULL, 1, 1, 1, 1, 1, 1, 4);

SET IDENTITY_INSERT dbo.SubscriptionPlans OFF;
GO

-- =============================================
-- MOT DEFECT MAPPINGS (Sample UK MOT codes)
-- =============================================

SET IDENTITY_INSERT dbo.MotDefectMapping ON;

INSERT INTO dbo.MotDefectMapping (MappingId, DefectCode, DefectText, CategoryId, ProbabilityWeight, SeverityIndicator, IsActive)
VALUES
    (1, '1.1.1', 'Brake performance below requirements', 3, 0.8500, 3, 1),
    (2, '1.1.2', 'Brake pipe excessively corroded', 3, 0.7500, 3, 1),
    (3, '2.1.3', 'Steering rack gaiter damaged', 9, 0.4000, 1, 1),
    (4, '2.2.1', 'Steering wheel play excessive', 9, 0.6000, 2, 1),
    (5, '2.4.1', 'Suspension arm ball joint worn', 4, 0.6500, 2, 1),
    (6, '2.5.1', 'Shock absorber leaking', 4, 0.5500, 2, 1),
    (7, '3.1.1', 'Tyre tread depth below requirements', 10, 0.3000, 1, 1),
    (8, '4.1.1', 'Headlamp aim too high', 11, 0.2500, 1, 1),
    (9, '5.1.1', 'Engine MIL illuminated', 1, 0.4500, 2, 1),
    (10, '6.1.1', 'Exhaust emissions exceed limits', 6, 0.5000, 2, 1),
    (11, '6.2.1', 'Exhaust has major leak', 6, 0.4000, 2, 1),
    (12, '7.1.1', 'Body corrosion affecting structure', 12, 0.7000, 3, 1),
    (13, '8.1.1', 'Battery insecure', 20, 0.3000, 1, 1),
    (14, '8.2.1', 'Wiring insecure', 5, 0.3500, 2, 1);

SET IDENTITY_INSERT dbo.MotDefectMapping OFF;
GO

PRINT 'Sample data inserted successfully.';
GO
