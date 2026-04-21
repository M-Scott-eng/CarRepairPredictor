-- =============================================
-- Script: 003_SeedReferenceData.sql
-- Description: Seeds reference data for the Car Repair Predictor database
-- =============================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Seed Regions
-- =============================================

IF NOT EXISTS (SELECT 1 FROM dbo.Region WHERE RegionCode = 'UK')
BEGIN
    INSERT INTO dbo.Region (RegionCode, RegionName, CurrencyCode, IsActive)
    VALUES ('UK', 'United Kingdom', 'GBP', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.Region WHERE RegionCode = 'US')
BEGIN
    INSERT INTO dbo.Region (RegionCode, RegionName, CurrencyCode, IsActive)
    VALUES ('US', 'United States', 'USD', 0); -- Inactive for now, for future expansion
END
GO

-- =============================================
-- Seed Failure Categories
-- =============================================

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'ENGINE')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('ENGINE', 'Engine', 'Engine components including pistons, valves, timing chains, and engine management');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'TRANSMISSION')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('TRANSMISSION', 'Transmission', 'Gearbox, clutch, and drivetrain components');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'BRAKES')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('BRAKES', 'Brakes', 'Brake pads, discs, calipers, and brake lines');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'SUSPENSION')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('SUSPENSION', 'Suspension', 'Shock absorbers, springs, bushings, and anti-roll bars');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'ELECTRICAL')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('ELECTRICAL', 'Electrical', 'Battery, alternator, starter motor, and wiring');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'EXHAUST')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('EXHAUST', 'Exhaust', 'Catalytic converter, DPF, exhaust manifold, and silencers');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'COOLING')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('COOLING', 'Cooling System', 'Radiator, water pump, thermostat, and hoses');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'STEERING')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('STEERING', 'Steering', 'Power steering pump, rack, track rods, and wheel bearings');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'FUEL')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('FUEL', 'Fuel System', 'Fuel pump, injectors, fuel filter, and fuel lines');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'TYRES')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('TYRES', 'Tyres', 'Tyres and wheel alignment');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'LIGHTING')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('LIGHTING', 'Lighting', 'Headlights, brake lights, indicators, and bulbs');
END

IF NOT EXISTS (SELECT 1 FROM dbo.FailureCategory WHERE CategoryCode = 'BODY')
BEGIN
    INSERT INTO dbo.FailureCategory (CategoryCode, CategoryName, [Description])
    VALUES ('BODY', 'Body/Corrosion', 'Rust, panel damage, and structural issues');
END
GO

-- =============================================
-- Seed Manufacturers
-- =============================================

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Ford')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Ford', 'USA');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Vauxhall')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Vauxhall', 'UK');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Volkswagen')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Volkswagen', 'Germany');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'BMW')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('BMW', 'Germany');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Mercedes-Benz')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Mercedes-Benz', 'Germany');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Audi')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Audi', 'Germany');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Toyota')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Toyota', 'Japan');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Honda')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Honda', 'Japan');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Nissan')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Nissan', 'Japan');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Peugeot')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Peugeot', 'France');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Renault')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Renault', 'France');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Kia')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Kia', 'South Korea');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Hyundai')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Hyundai', 'South Korea');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'MINI')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('MINI', 'UK');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Land Rover')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Land Rover', 'UK');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Jaguar')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Jaguar', 'UK');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Fiat')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Fiat', 'Italy');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Skoda')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Skoda', 'Czech Republic');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'SEAT')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('SEAT', 'Spain');

IF NOT EXISTS (SELECT 1 FROM dbo.Manufacturer WHERE ManufacturerName = 'Mazda')
    INSERT INTO dbo.Manufacturer (ManufacturerName, CountryOfOrigin) VALUES ('Mazda', 'Japan');
GO

-- =============================================
-- Seed Sample Vehicle Models (Popular UK Cars)
-- =============================================

DECLARE @FordId INT, @VauxhallId INT, @VWId INT, @BMWId INT, @ToyotaId INT;

SELECT @FordId = ManufacturerId FROM dbo.Manufacturer WHERE ManufacturerName = 'Ford';
SELECT @VauxhallId = ManufacturerId FROM dbo.Manufacturer WHERE ManufacturerName = 'Vauxhall';
SELECT @VWId = ManufacturerId FROM dbo.Manufacturer WHERE ManufacturerName = 'Volkswagen';
SELECT @BMWId = ManufacturerId FROM dbo.Manufacturer WHERE ManufacturerName = 'BMW';
SELECT @ToyotaId = ManufacturerId FROM dbo.Manufacturer WHERE ManufacturerName = 'Toyota';

-- Ford Models
IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @FordId AND ModelName = 'Fiesta')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@FordId, 'Fiesta', 2008, 2023, '["1.0 EcoBoost","1.25 Petrol","1.5 TDCi","1.6 TDCi"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @FordId AND ModelName = 'Focus')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@FordId, 'Focus', 2011, NULL, '["1.0 EcoBoost","1.5 EcoBoost","1.5 TDCi","2.0 TDCi"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @FordId AND ModelName = 'Kuga')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@FordId, 'Kuga', 2013, NULL, '["1.5 EcoBoost","2.0 TDCi","2.5 PHEV"]');

-- Vauxhall Models
IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @VauxhallId AND ModelName = 'Corsa')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@VauxhallId, 'Corsa', 2006, NULL, '["1.0 Petrol","1.2 Petrol","1.4 Petrol","1.3 CDTi"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @VauxhallId AND ModelName = 'Astra')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@VauxhallId, 'Astra', 2010, NULL, '["1.4 Turbo","1.6 Petrol","1.6 CDTi","2.0 CDTi"]');

-- Volkswagen Models
IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @VWId AND ModelName = 'Golf')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@VWId, 'Golf', 2009, NULL, '["1.0 TSI","1.4 TSI","2.0 TSI","1.6 TDI","2.0 TDI"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @VWId AND ModelName = 'Polo')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@VWId, 'Polo', 2009, NULL, '["1.0 TSI","1.2 TSI","1.4 TDI","1.6 TDI"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @VWId AND ModelName = 'Tiguan')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@VWId, 'Tiguan', 2016, NULL, '["1.4 TSI","2.0 TSI","2.0 TDI"]');

-- BMW Models
IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @BMWId AND ModelName = '3 Series')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@BMWId, '3 Series', 2012, NULL, '["318i","320i","330i","316d","318d","320d","330d"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @BMWId AND ModelName = '1 Series')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@BMWId, '1 Series', 2011, NULL, '["116i","118i","120i","116d","118d","120d"]');

-- Toyota Models
IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @ToyotaId AND ModelName = 'Yaris')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@ToyotaId, 'Yaris', 2011, NULL, '["1.0 VVT-i","1.33 VVT-i","1.5 Hybrid"]');

IF NOT EXISTS (SELECT 1 FROM dbo.VehicleModel WHERE ManufacturerId = @ToyotaId AND ModelName = 'Corolla')
    INSERT INTO dbo.VehicleModel (ManufacturerId, ModelName, YearStart, YearEnd, EngineTypes)
    VALUES (@ToyotaId, 'Corolla', 2019, NULL, '["1.2 Turbo","1.8 Hybrid","2.0 Hybrid"]');
GO

PRINT 'Reference data seeded successfully.';
GO
