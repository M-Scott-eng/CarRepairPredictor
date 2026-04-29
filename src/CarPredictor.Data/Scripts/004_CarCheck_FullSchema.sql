-- =====================================================
-- CarCheck Platform - Core Database Schema
-- Parts Finder + Common Faults + Buyer's Guide
-- =====================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =====================================================
-- 1. CAR MAKES (Manufacturers)
-- =====================================================
IF OBJECT_ID('dbo.CarMakes', 'U') IS NOT NULL DROP TABLE dbo.CarMakes;
GO

CREATE TABLE dbo.CarMakes (
    MakeId INT IDENTITY(1,1) PRIMARY KEY,
    MakeName NVARCHAR(50) NOT NULL,
    MakeSlug NVARCHAR(50) NOT NULL,           -- URL-friendly: "mercedes-benz"
    CountryOfOrigin NVARCHAR(50),
    LogoUrl NVARCHAR(500),
    IsActive BIT NOT NULL DEFAULT 1,
    DisplayOrder INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT UQ_CarMakes_Slug UNIQUE (MakeSlug)
);

CREATE NONCLUSTERED INDEX IX_CarMakes_Active ON dbo.CarMakes(IsActive) INCLUDE (MakeName, MakeSlug);
GO

-- Sample Data
INSERT INTO dbo.CarMakes (MakeName, MakeSlug, CountryOfOrigin, DisplayOrder) VALUES
('BMW', 'bmw', 'Germany', 1),
('Audi', 'audi', 'Germany', 2),
('Mercedes-Benz', 'mercedes-benz', 'Germany', 3),
('Volkswagen', 'volkswagen', 'Germany', 4),
('Ford', 'ford', 'USA', 5),
('Vauxhall', 'vauxhall', 'UK', 6),
('Mini', 'mini', 'UK', 7),
('Nissan', 'nissan', 'Japan', 8),
('Toyota', 'toyota', 'Japan', 9),
('Honda', 'honda', 'Japan', 10),
('Mazda', 'mazda', 'Japan', 11),
('Peugeot', 'peugeot', 'France', 12),
('Renault', 'renault', 'France', 13),
('Skoda', 'skoda', 'Czech Republic', 14),
('Seat', 'seat', 'Spain', 15);
GO

-- =====================================================
-- 2. CAR MODELS
-- =====================================================
IF OBJECT_ID('dbo.CarModels', 'U') IS NOT NULL DROP TABLE dbo.CarModels;
GO

CREATE TABLE dbo.CarModels (
    ModelId INT IDENTITY(1,1) PRIMARY KEY,
    MakeId INT NOT NULL,
    ModelName NVARCHAR(100) NOT NULL,
    ModelSlug NVARCHAR(100) NOT NULL,         -- "3-series", "a4"
    Generation NVARCHAR(20),                   -- "E90", "B8", "Mk7"
    BodyStyle NVARCHAR(50),                    -- Saloon, Estate, Hatchback, SUV
    ProductionStart INT,
    ProductionEnd INT,
    IsActive BIT NOT NULL DEFAULT 1,
    ImageUrl NVARCHAR(500),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CarModels_Make FOREIGN KEY (MakeId) REFERENCES dbo.CarMakes(MakeId),
    CONSTRAINT UQ_CarModels_Slug UNIQUE (MakeId, ModelSlug, Generation)
);

CREATE NONCLUSTERED INDEX IX_CarModels_Make ON dbo.CarModels(MakeId) INCLUDE (ModelName, Generation);
GO

-- Sample Data
INSERT INTO dbo.CarModels (MakeId, ModelName, ModelSlug, Generation, BodyStyle, ProductionStart, ProductionEnd) VALUES
-- BMW
(1, '3 Series', '3-series', 'E90', 'Saloon', 2005, 2012),
(1, '3 Series', '3-series', 'F30', 'Saloon', 2012, 2019),
(1, '1 Series', '1-series', 'E87', 'Hatchback', 2004, 2011),
-- Audi
(2, 'A4', 'a4', 'B8', 'Saloon', 2008, 2015),
(2, 'A3', 'a3', '8P', 'Hatchback', 2003, 2012),
-- Mercedes
(3, 'C-Class', 'c-class', 'W204', 'Saloon', 2007, 2014),
-- VW
(4, 'Golf', 'golf', 'Mk6', 'Hatchback', 2008, 2012),
(4, 'Golf', 'golf', 'Mk7', 'Hatchback', 2012, 2019),
-- Ford
(5, 'Fiesta', 'fiesta', 'Mk7', 'Hatchback', 2008, 2017),
(5, 'Focus', 'focus', 'Mk3', 'Hatchback', 2011, 2018),
-- Vauxhall
(6, 'Corsa', 'corsa', 'D', 'Hatchback', 2006, 2014),
(6, 'Astra', 'astra', 'J', 'Hatchback', 2009, 2015),
-- Mini
(7, 'Cooper', 'cooper', 'R56', 'Hatchback', 2006, 2013),
-- Nissan
(8, 'Qashqai', 'qashqai', 'J10', 'SUV', 2007, 2013);
GO

-- =====================================================
-- 3. MODEL YEARS (Year-specific specs)
-- =====================================================
IF OBJECT_ID('dbo.ModelYears', 'U') IS NOT NULL DROP TABLE dbo.ModelYears;
GO

CREATE TABLE dbo.ModelYears (
    ModelYearId INT IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
    Year INT NOT NULL,
    Facelifted BIT NOT NULL DEFAULT 0,
    Notes NVARCHAR(500),
    
    CONSTRAINT FK_ModelYears_Model FOREIGN KEY (ModelId) REFERENCES dbo.CarModels(ModelId),
    CONSTRAINT UQ_ModelYears UNIQUE (ModelId, Year)
);

CREATE NONCLUSTERED INDEX IX_ModelYears_Model ON dbo.ModelYears(ModelId, Year);
GO

-- Sample Data (BMW 3 Series E90)
INSERT INTO dbo.ModelYears (ModelId, Year, Facelifted, Notes)
SELECT 1, Years.Year, 
       CASE WHEN Years.Year >= 2008 THEN 1 ELSE 0 END,
       CASE WHEN Years.Year >= 2008 THEN 'LCI facelift model' ELSE 'Pre-facelift' END
FROM (VALUES (2005),(2006),(2007),(2008),(2009),(2010),(2011),(2012)) AS Years(Year);

-- Audi A4 B8
INSERT INTO dbo.ModelYears (ModelId, Year, Facelifted, Notes)
SELECT 4, Years.Year, 
       CASE WHEN Years.Year >= 2012 THEN 1 ELSE 0 END,
       CASE WHEN Years.Year >= 2012 THEN 'Facelift B8.5' ELSE 'Pre-facelift' END
FROM (VALUES (2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015)) AS Years(Year);

-- Ford Fiesta Mk7
INSERT INTO dbo.ModelYears (ModelId, Year, Facelifted, Notes)
SELECT 9, Years.Year, 
       CASE WHEN Years.Year >= 2013 THEN 1 ELSE 0 END,
       NULL
FROM (VALUES (2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015),(2016),(2017)) AS Years(Year);
GO

-- =====================================================
-- 4. ENGINES
-- =====================================================
IF OBJECT_ID('dbo.Engines', 'U') IS NOT NULL DROP TABLE dbo.Engines;
GO

CREATE TABLE dbo.Engines (
    EngineId INT IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
    EngineCode NVARCHAR(20) NOT NULL,         -- "N47D20", "CAEB", "1.0 EcoBoost"
    EngineName NVARCHAR(100),                  -- "2.0 TDI", "320d", "1.0 EcoBoost"
    FuelType NVARCHAR(20) NOT NULL,            -- Petrol, Diesel, Hybrid, Electric
    Displacement INT,                          -- CC (e.g., 1998)
    DisplacementLabel NVARCHAR(10),            -- "2.0L"
    PowerBhp INT,
    PowerKw INT,
    TorqueNm INT,
    Cylinders INT,
    Aspiration NVARCHAR(20),                   -- Turbo, Supercharged, N/A
    Transmission NVARCHAR(50),                 -- Manual 6-speed, Auto 8-speed, DSG
    YearStart INT,
    YearEnd INT,
    IsCommon BIT NOT NULL DEFAULT 1,
    ReliabilityRating INT,                     -- 1-5 stars
    KnownIssuesCount INT DEFAULT 0,
    
    CONSTRAINT FK_Engines_Model FOREIGN KEY (ModelId) REFERENCES dbo.CarModels(ModelId)
);

CREATE NONCLUSTERED INDEX IX_Engines_Model ON dbo.Engines(ModelId) INCLUDE (EngineCode, FuelType);
GO

-- Sample Data
INSERT INTO dbo.Engines (ModelId, EngineCode, EngineName, FuelType, Displacement, DisplacementLabel, PowerBhp, TorqueNm, Aspiration, YearStart, YearEnd, ReliabilityRating, KnownIssuesCount) VALUES
-- BMW E90
(1, 'N47D20', '320d', 'Diesel', 1995, '2.0L', 177, 350, 'Turbo', 2007, 2012, 2, 5),
(1, 'N43B20', '320i', 'Petrol', 1995, '2.0L', 170, 210, 'N/A', 2007, 2011, 3, 3),
(1, 'N52B30', '330i', 'Petrol', 2996, '3.0L', 272, 320, 'N/A', 2005, 2012, 4, 2),
-- Audi A4 B8
(4, 'CAEB', '2.0 TFSI', 'Petrol', 1984, '2.0L', 211, 350, 'Turbo', 2008, 2012, 2, 4),
(4, 'CAGA', '2.0 TDI', 'Diesel', 1968, '2.0L', 143, 320, 'Turbo', 2008, 2015, 3, 3),
-- Ford Fiesta Mk7
(9, 'SFJA', '1.0 EcoBoost', 'Petrol', 999, '1.0L', 100, 170, 'Turbo', 2012, 2017, 3, 2),
(9, 'KVJA', '1.25 Duratec', 'Petrol', 1242, '1.25L', 82, 114, 'N/A', 2008, 2017, 4, 1),
-- Vauxhall Corsa D
(11, 'Z12XEP', '1.2 Twinport', 'Petrol', 1229, '1.2L', 80, 110, 'N/A', 2006, 2014, 2, 4),
(11, 'A14XER', '1.4', 'Petrol', 1398, '1.4L', 100, 130, 'N/A', 2010, 2014, 3, 3),
-- Mini R56
(13, 'N14B16', 'Cooper S', 'Petrol', 1598, '1.6L', 175, 240, 'Turbo', 2006, 2010, 2, 5),
(13, 'N12B16', 'Cooper', 'Petrol', 1598, '1.6L', 120, 160, 'N/A', 2006, 2010, 3, 3);
GO

-- =====================================================
-- 5. COMMON FAULTS
-- =====================================================
IF OBJECT_ID('dbo.CommonFaults', 'U') IS NOT NULL DROP TABLE dbo.CommonFaults;
GO

CREATE TABLE dbo.CommonFaults (
    FaultId INT IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
    EngineId INT,                              -- NULL = affects all engines
    FaultName NVARCHAR(200) NOT NULL,
    FaultSlug NVARCHAR(200) NOT NULL,
    Category NVARCHAR(50) NOT NULL,            -- Engine, Transmission, Suspension, etc.
    Description NVARCHAR(MAX),
    Symptoms NVARCHAR(MAX),                    -- JSON array of symptoms
    Causes NVARCHAR(MAX),
    MileageStart INT,                          -- Typical failure range start
    MileageEnd INT,                            -- Typical failure range end
    MileagePeak INT,                           -- Most common failure point
    Probability DECIMAL(5,2),                  -- 0.00 to 100.00%
    Severity INT NOT NULL,                     -- 1=Minor, 2=Moderate, 3=Major, 4=Critical, 5=Catastrophic
    RepairDifficulty INT,                      -- 1=DIY Easy, 2=DIY Moderate, 3=Garage, 4=Specialist, 5=Dealer
    LabourHoursMin DECIMAL(4,2),
    LabourHoursMax DECIMAL(4,2),
    PartsMinGbp DECIMAL(10,2),
    PartsMaxGbp DECIMAL(10,2),
    TotalCostMinGbp DECIMAL(10,2),
    TotalCostMaxGbp DECIMAL(10,2),
    AvoidanceTips NVARCHAR(MAX),
    IsRecall BIT NOT NULL DEFAULT 0,
    RecallReference NVARCHAR(50),
    DataSource NVARCHAR(200),
    ConfidenceScore DECIMAL(3,2),              -- 0.00 to 1.00
    SampleSize INT,
    ViewCount INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_CommonFaults_Model FOREIGN KEY (ModelId) REFERENCES dbo.CarModels(ModelId),
    CONSTRAINT FK_CommonFaults_Engine FOREIGN KEY (EngineId) REFERENCES dbo.Engines(EngineId)
);

CREATE NONCLUSTERED INDEX IX_CommonFaults_Model ON dbo.CommonFaults(ModelId) INCLUDE (Category, Severity);
CREATE NONCLUSTERED INDEX IX_CommonFaults_Engine ON dbo.CommonFaults(EngineId);
CREATE NONCLUSTERED INDEX IX_CommonFaults_Category ON dbo.CommonFaults(Category);
GO

-- Sample Data
INSERT INTO dbo.CommonFaults 
(ModelId, EngineId, FaultName, FaultSlug, Category, Description, Symptoms, MileageStart, MileageEnd, MileagePeak, Probability, Severity, RepairDifficulty, LabourHoursMin, LabourHoursMax, PartsMinGbp, PartsMaxGbp, TotalCostMinGbp, TotalCostMaxGbp, DataSource, ConfidenceScore, SampleSize)
VALUES
-- BMW E90 N47 Timing Chain
(1, 1, 'N47 Timing Chain Failure', 'n47-timing-chain-failure', 'Engine', 
 'The N47 diesel engine suffers from a poorly designed timing chain and tensioner that wears prematurely. If the chain snaps, the engine will suffer catastrophic damage requiring replacement.',
 '["Rattling noise on cold start", "Timing chain rattle at idle", "Check engine light", "Engine warning messages", "Rough running"]',
 50000, 180000, 100000, 85.00, 5, 4, 8, 12, 800, 1200, 1500, 2500, 'MOT Data Analysis / Workshop Reports', 0.92, 15000),

-- BMW E90 Swirl Flaps
(1, 1, 'Swirl Flap Failure', 'swirl-flap-failure', 'Engine',
 'Intake manifold swirl flaps can break and debris enters the engine causing serious damage. Common on diesel variants.',
 '["Loss of power", "Check engine light", "Rough idle", "Whistling noise from intake"]',
 80000, NULL, 120000, 60.00, 4, 3, 4, 6, 400, 800, 700, 1200, 'Workshop Data', 0.85, 8500),

-- Audi A4 B8 Oil Consumption
(4, 4, '2.0 TFSI Oil Consumption', '2-0-tfsi-oil-consumption', 'Engine',
 'Excessive oil consumption due to piston ring design. Some engines use 1L per 1000 miles. VAG issued TSB for piston ring replacement.',
 '["High oil consumption", "Oil level warning", "Blue smoke from exhaust", "Check engine light"]',
 40000, 150000, 80000, 75.00, 3, 5, 12, 18, 1200, 2500, 2000, 4000, 'VAG TSB / Owner Reports', 0.94, 25000),

-- Ford Fiesta PowerShift
(9, 6, 'PowerShift Transmission Failure', 'powershift-transmission-failure', 'Transmission',
 'The DPS6 dual-clutch automatic gearbox suffers from clutch shudder, juddering, and premature failure. Class action lawsuits filed in multiple countries.',
 '["Clutch shudder", "Jerky gear changes", "Hesitation when pulling away", "Grinding noises", "Gearbox warning light"]',
 30000, NULL, 60000, 80.00, 4, 5, 6, 10, 800, 2000, 1200, 3000, 'Class Action Data / DVSA Reports', 0.95, 35000),

-- Vauxhall Corsa D Timing Chain
(11, 8, 'Timing Chain Failure', 'timing-chain-failure', 'Engine',
 'Timing chain and tensioner wear causing rattle and potential engine damage. Very common issue on 1.0/1.2/1.4 petrol engines.',
 '["Rattling on cold start", "Timing chain rattle at idle", "Check engine light", "Poor running"]',
 40000, 150000, 80000, 85.00, 4, 3, 5, 8, 300, 600, 600, 1200, 'MOT Data / Workshop Reports', 0.94, 45000),

-- Mini R56 Timing Chain
(13, 10, 'N14 Timing Chain Failure', 'n14-timing-chain-failure', 'Engine',
 'The N14 turbocharged engine suffers from timing chain stretch and tensioner failure. Can cause catastrophic engine damage.',
 '["Rattling on startup", "Check engine light", "Rough idle", "Loss of power", "Engine stalling"]',
 40000, 150000, 80000, 78.00, 5, 4, 6, 12, 700, 1500, 1200, 2500, 'BMW TSB / Workshop Data', 0.92, 18000);
GO

-- =====================================================
-- 6. PARTS CATEGORIES
-- =====================================================
IF OBJECT_ID('dbo.PartsCategories', 'U') IS NOT NULL DROP TABLE dbo.PartsCategories;
GO

CREATE TABLE dbo.PartsCategories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    CategorySlug NVARCHAR(100) NOT NULL,
    ParentCategoryId INT,
    Description NVARCHAR(500),
    IconName NVARCHAR(50),
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_PartsCategories_Parent FOREIGN KEY (ParentCategoryId) REFERENCES dbo.PartsCategories(CategoryId),
    CONSTRAINT UQ_PartsCategories_Slug UNIQUE (CategorySlug)
);
GO

-- Sample Data
INSERT INTO dbo.PartsCategories (CategoryName, CategorySlug, ParentCategoryId, Description, IconName, DisplayOrder) VALUES
-- Root categories
('Engine', 'engine', NULL, 'Engine components and related parts', 'engine', 1),
('Transmission', 'transmission', NULL, 'Gearbox, clutch and drivetrain', 'gearbox', 2),
('Brakes', 'brakes', NULL, 'Brake pads, discs, calipers and hydraulics', 'brake', 3),
('Suspension', 'suspension', NULL, 'Springs, dampers, bushes and arms', 'suspension', 4),
('Steering', 'steering', NULL, 'Steering rack, pump and linkages', 'steering-wheel', 5),
('Electrical', 'electrical', NULL, 'Batteries, alternators, sensors and modules', 'lightning', 6),
('Cooling', 'cooling', NULL, 'Radiators, water pumps and thermostats', 'thermometer', 7),
('Exhaust', 'exhaust', NULL, 'Catalysts, DPF, exhaust systems', 'exhaust', 8),
('Filters', 'filters', NULL, 'Oil, air, fuel and cabin filters', 'filter', 9),
('Body', 'body', NULL, 'Panels, bumpers, mirrors and trim', 'car', 10);

-- Engine subcategories
INSERT INTO dbo.PartsCategories (CategoryName, CategorySlug, ParentCategoryId, Description, DisplayOrder) VALUES
('Timing Chain Kits', 'timing-chain-kits', 1, 'Complete timing chain kits with tensioners', 1),
('Timing Belt Kits', 'timing-belt-kits', 1, 'Complete cambelt kits with water pump', 2),
('Turbochargers', 'turbochargers', 1, 'Turbos and turbo accessories', 3),
('Fuel Injectors', 'fuel-injectors', 1, 'Petrol and diesel injectors', 4),
('Ignition', 'ignition', 1, 'Spark plugs, coil packs, leads', 5),
('Gaskets', 'gaskets', 1, 'Head gaskets, manifold gaskets, seals', 6),
('Sensors', 'sensors', 1, 'Engine sensors - MAF, MAP, O2, crank', 7);

-- Brake subcategories
INSERT INTO dbo.PartsCategories (CategoryName, CategorySlug, ParentCategoryId, Description, DisplayOrder) VALUES
('Brake Pads', 'brake-pads', 3, 'Front and rear brake pads', 1),
('Brake Discs', 'brake-discs', 3, 'Brake discs and rotors', 2),
('Brake Calipers', 'brake-calipers', 3, 'Calipers and carriers', 3);

-- Suspension subcategories
INSERT INTO dbo.PartsCategories (CategoryName, CategorySlug, ParentCategoryId, Description, DisplayOrder) VALUES
('Shock Absorbers', 'shock-absorbers', 4, 'Dampers and struts', 1),
('Springs', 'springs', 4, 'Coil springs', 2),
('Control Arms', 'control-arms', 4, 'Wishbones and arms', 3),
('Bushes', 'bushes', 4, 'Suspension bushes', 4),
('Wheel Bearings', 'wheel-bearings', 4, 'Wheel bearing kits', 5);
GO

-- =====================================================
-- 7. PARTS SOURCES (Suppliers/Retailers)
-- =====================================================
IF OBJECT_ID('dbo.PartsSources', 'U') IS NOT NULL DROP TABLE dbo.PartsSources;
GO

CREATE TABLE dbo.PartsSources (
    SourceId INT IDENTITY(1,1) PRIMARY KEY,
    SourceName NVARCHAR(100) NOT NULL,
    SourceCode NVARCHAR(20) NOT NULL,          -- EBAY, AMAZON, EUROCAR, etc.
    SourceType NVARCHAR(20) NOT NULL,          -- Marketplace, Retailer, Wholesaler
    WebsiteUrl NVARCHAR(500),
    ApiEndpoint NVARCHAR(500),
    ApiType NVARCHAR(50),                      -- REST, SOAP, Scrape, Affiliate
    LogoUrl NVARCHAR(500),
    TrustScore DECIMAL(3,2),                   -- 0.00 to 5.00
    ShipsToUk BIT NOT NULL DEFAULT 1,
    TypicalDeliveryDays INT,
    ReturnPolicyDays INT,
    AffiliateId NVARCHAR(100),
    AffiliateNetwork NVARCHAR(50),             -- AWIN, CJ, Amazon Associates
    CommissionRate DECIMAL(5,2),               -- Percentage
    IsActive BIT NOT NULL DEFAULT 1,
    Priority INT NOT NULL DEFAULT 5,           -- Search priority 1=highest
    RateLimitPerMinute INT DEFAULT 60,
    LastSyncAt DATETIME2,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT UQ_PartsSources_Code UNIQUE (SourceCode)
);
GO

-- Sample Data
INSERT INTO dbo.PartsSources 
(SourceName, SourceCode, SourceType, WebsiteUrl, ApiType, TrustScore, ShipsToUk, TypicalDeliveryDays, ReturnPolicyDays, AffiliateNetwork, CommissionRate, Priority)
VALUES
('eBay UK', 'EBAY', 'Marketplace', 'https://www.ebay.co.uk', 'REST', 4.20, 1, 3, 30, 'eBay Partner Network', 4.00, 1),
('Amazon UK', 'AMAZON', 'Marketplace', 'https://www.amazon.co.uk', 'REST', 4.50, 1, 2, 30, 'Amazon Associates', 3.00, 2),
('Euro Car Parts', 'EUROCAR', 'Retailer', 'https://www.eurocarparts.com', 'Affiliate', 4.30, 1, 1, 90, 'AWIN', 5.00, 3),
('Autodoc', 'AUTODOC', 'Retailer', 'https://www.autodoc.co.uk', 'REST', 4.10, 1, 4, 14, 'AWIN', 4.50, 4),
('GSF Car Parts', 'GSF', 'Retailer', 'https://www.gsfcarparts.com', 'Affiliate', 4.20, 1, 1, 365, 'AWIN', 4.00, 5),
('RockAuto', 'ROCKAUTO', 'Retailer', 'https://www.rockauto.com', 'Scrape', 4.00, 1, 10, 90, NULL, 0.00, 6),
('Halfords', 'HALFORDS', 'Retailer', 'https://www.halfords.com', 'Affiliate', 3.80, 1, 1, 28, 'AWIN', 3.00, 7);
GO

-- =====================================================
-- 8. PARTS RESULTS (Cached search results)
-- =====================================================
IF OBJECT_ID('dbo.PartsResults', 'U') IS NOT NULL DROP TABLE dbo.PartsResults;
GO

CREATE TABLE dbo.PartsResults (
    ResultId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
    EngineId INT,
    CategoryId INT NOT NULL,
    SourceId INT NOT NULL,
    ExternalId NVARCHAR(100),                  -- Supplier's product ID
    Title NVARCHAR(500) NOT NULL,
    Brand NVARCHAR(100),
    OemPartNumber NVARCHAR(100),
    SupplierPartNumber NVARCHAR(100),
    PriceGbp DECIMAL(10,2) NOT NULL,
    ShippingGbp DECIMAL(10,2),
    TotalPriceGbp AS (PriceGbp + ISNULL(ShippingGbp, 0)) PERSISTED,
    Currency NVARCHAR(3) NOT NULL DEFAULT 'GBP',
    Availability NVARCHAR(50),                 -- InStock, LowStock, OutOfStock, PreOrder
    StockQuantity INT,
    Condition NVARCHAR(20),                    -- New, Refurbished, Used
    SellerName NVARCHAR(200),
    SellerRating DECIMAL(3,2),
    SellerReviewCount INT,
    ProductUrl NVARCHAR(1000),
    ImageUrl NVARCHAR(1000),
    Description NVARCHAR(MAX),
    IsPrime BIT DEFAULT 0,                     -- Amazon Prime eligible
    IsFeatured BIT DEFAULT 0,
    QualityScore DECIMAL(5,2),                 -- Calculated relevance score
    FetchedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2 NOT NULL,
    
    CONSTRAINT FK_PartsResults_Model FOREIGN KEY (ModelId) REFERENCES dbo.CarModels(ModelId),
    CONSTRAINT FK_PartsResults_Engine FOREIGN KEY (EngineId) REFERENCES dbo.Engines(EngineId),
    CONSTRAINT FK_PartsResults_Category FOREIGN KEY (CategoryId) REFERENCES dbo.PartsCategories(CategoryId),
    CONSTRAINT FK_PartsResults_Source FOREIGN KEY (SourceId) REFERENCES dbo.PartsSources(SourceId)
);

CREATE NONCLUSTERED INDEX IX_PartsResults_Search ON dbo.PartsResults(ModelId, EngineId, CategoryId) INCLUDE (PriceGbp, Availability);
CREATE NONCLUSTERED INDEX IX_PartsResults_Expires ON dbo.PartsResults(ExpiresAt);
CREATE NONCLUSTERED INDEX IX_PartsResults_Price ON dbo.PartsResults(TotalPriceGbp);
GO

-- Sample Data (BMW E90 N47 Timing Chain Kits)
INSERT INTO dbo.PartsResults 
(ModelId, EngineId, CategoryId, SourceId, ExternalId, Title, Brand, OemPartNumber, PriceGbp, ShippingGbp, Availability, Condition, SellerName, SellerRating, ProductUrl, ImageUrl, ExpiresAt)
VALUES
(1, 1, 11, 1, 'ebay-123456', 'BMW N47 Timing Chain Kit - Complete with Tensioner', 'FAI', '11318506650', 189.99, 0, 'InStock', 'New', 'uk_car_parts', 4.85, 'https://www.ebay.co.uk/itm/123456', 'https://i.ebayimg.com/images/g/tc/s-l500.jpg', DATEADD(HOUR, 24, GETUTCDATE())),
(1, 1, 11, 1, 'ebay-789012', 'BMW N47 D20 Timing Chain Kit with Gears - OE Quality', 'SWAG', '20 94 6403', 145.00, 5.99, 'InStock', 'New', 'autoshop_direct', 4.92, 'https://www.ebay.co.uk/itm/789012', 'https://i.ebayimg.com/images/g/tc2/s-l500.jpg', DATEADD(HOUR, 24, GETUTCDATE())),
(1, 1, 11, 2, 'ASIN-B08XYZ', 'FAI AutoParts TCK133 Timing Chain Kit for BMW N47', 'FAI AutoParts', 'TCK133', 215.00, 0, 'InStock', 'New', 'Amazon', 4.40, 'https://www.amazon.co.uk/dp/B08XYZ', 'https://m.media-amazon.com/images/I/tc.jpg', DATEADD(HOUR, 24, GETUTCDATE())),
(1, 1, 11, 3, 'ECP-1234567', 'Timing Chain Kit BMW 1 3 Series N47 Engine Complete', 'Febi Bilstein', '103007', 175.99, 0, 'InStock', 'New', 'Euro Car Parts', 4.30, 'https://www.eurocarparts.com/p/1234567', 'https://www.eurocarparts.com/images/tc.jpg', DATEADD(HOUR, 24, GETUTCDATE())),
(1, 1, 11, 4, 'AUTODOC-45678', 'INA 559 0056 30 Timing Chain Kit BMW', 'INA', '559 0056 30', 132.50, 8.99, 'InStock', 'New', 'Autodoc', 4.10, 'https://www.autodoc.co.uk/ina/45678', 'https://www.autodoc.co.uk/images/tc.jpg', DATEADD(HOUR, 24, GETUTCDATE()));
GO

-- =====================================================
-- 9. AFFILIATE LINKS
-- =====================================================
IF OBJECT_ID('dbo.AffiliateLinks', 'U') IS NOT NULL DROP TABLE dbo.AffiliateLinks;
GO

CREATE TABLE dbo.AffiliateLinks (
    AffiliateLinkId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ResultId BIGINT NOT NULL,
    SourceId INT NOT NULL,
    OriginalUrl NVARCHAR(2000) NOT NULL,
    AffiliateUrl NVARCHAR(2000) NOT NULL,
    ShortCode NVARCHAR(20) NOT NULL,           -- Unique short code for tracking
    TrackingParams NVARCHAR(500),              -- JSON of tracking parameters
    ClickCount INT NOT NULL DEFAULT 0,
    ConversionCount INT NOT NULL DEFAULT 0,
    RevenueGbp DECIMAL(10,2) NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastClickedAt DATETIME2,
    ExpiresAt DATETIME2,
    
    CONSTRAINT FK_AffiliateLinks_Result FOREIGN KEY (ResultId) REFERENCES dbo.PartsResults(ResultId),
    CONSTRAINT FK_AffiliateLinks_Source FOREIGN KEY (SourceId) REFERENCES dbo.PartsSources(SourceId),
    CONSTRAINT UQ_AffiliateLinks_ShortCode UNIQUE (ShortCode)
);

CREATE NONCLUSTERED INDEX IX_AffiliateLinks_Result ON dbo.AffiliateLinks(ResultId);
CREATE NONCLUSTERED INDEX IX_AffiliateLinks_ShortCode ON dbo.AffiliateLinks(ShortCode);
GO

-- Sample Data
INSERT INTO dbo.AffiliateLinks (ResultId, SourceId, OriginalUrl, AffiliateUrl, ShortCode, TrackingParams)
VALUES
(1, 1, 'https://www.ebay.co.uk/itm/123456', 'https://www.ebay.co.uk/itm/123456?mkevt=1&mkcid=1&mkrid=710-53481-19255-0&campid=YOUR_CAMPAIGN&toolid=10001', 'tc-bmw-e90-01', '{"campaign": "timing-chain", "source": "fault-page"}'),
(2, 1, 'https://www.ebay.co.uk/itm/789012', 'https://www.ebay.co.uk/itm/789012?mkevt=1&mkcid=1&mkrid=710-53481-19255-0&campid=YOUR_CAMPAIGN&toolid=10001', 'tc-bmw-e90-02', '{"campaign": "timing-chain", "source": "search"}'),
(3, 2, 'https://www.amazon.co.uk/dp/B08XYZ', 'https://www.amazon.co.uk/dp/B08XYZ?tag=carcheck-21', 'tc-bmw-e90-03', '{"campaign": "timing-chain", "source": "amazon"}'),
(4, 3, 'https://www.eurocarparts.com/p/1234567', 'https://www.awin1.com/cread.php?awinmid=2714&awinaffid=YOUR_ID&ued=https://www.eurocarparts.com/p/1234567', 'tc-bmw-e90-04', '{"campaign": "timing-chain", "source": "eurocar"}');
GO

-- =====================================================
-- 10. USER SEARCH HISTORY
-- =====================================================
IF OBJECT_ID('dbo.UserSearchHistory', 'U') IS NOT NULL DROP TABLE dbo.UserSearchHistory;
GO

CREATE TABLE dbo.UserSearchHistory (
    SearchId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,                                -- NULL for anonymous
    SessionId NVARCHAR(100),                   -- Anonymous session tracking
    MakeId INT,
    ModelId INT,
    EngineId INT,
    Year INT,
    CategoryId INT,
    FaultId INT,                               -- If searching from fault page
    SearchQuery NVARCHAR(500),                 -- Free text search
    SearchType NVARCHAR(20) NOT NULL,          -- Parts, Faults, Guide, Vehicle
    ResultCount INT,
    LowestPriceGbp DECIMAL(10,2),
    HighestPriceGbp DECIMAL(10,2),
    ClickedResultId BIGINT,                    -- Which result they clicked
    IpAddress NVARCHAR(45),
    UserAgent NVARCHAR(500),
    Referrer NVARCHAR(500),
    DeviceType NVARCHAR(20),                   -- Mobile, Tablet, Desktop
    SearchedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_UserSearchHistory_Make FOREIGN KEY (MakeId) REFERENCES dbo.CarMakes(MakeId),
    CONSTRAINT FK_UserSearchHistory_Model FOREIGN KEY (ModelId) REFERENCES dbo.CarModels(ModelId),
    CONSTRAINT FK_UserSearchHistory_Engine FOREIGN KEY (EngineId) REFERENCES dbo.Engines(EngineId),
    CONSTRAINT FK_UserSearchHistory_Category FOREIGN KEY (CategoryId) REFERENCES dbo.PartsCategories(CategoryId),
    CONSTRAINT FK_UserSearchHistory_Fault FOREIGN KEY (FaultId) REFERENCES dbo.CommonFaults(FaultId)
);

CREATE NONCLUSTERED INDEX IX_UserSearchHistory_Date ON dbo.UserSearchHistory(SearchedAt) INCLUDE (SearchType);
CREATE NONCLUSTERED INDEX IX_UserSearchHistory_Model ON dbo.UserSearchHistory(ModelId, EngineId);
CREATE NONCLUSTERED INDEX IX_UserSearchHistory_User ON dbo.UserSearchHistory(UserId) WHERE UserId IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_UserSearchHistory_Session ON dbo.UserSearchHistory(SessionId);
GO

-- Sample Data
INSERT INTO dbo.UserSearchHistory 
(SessionId, MakeId, ModelId, EngineId, Year, CategoryId, FaultId, SearchType, ResultCount, LowestPriceGbp, HighestPriceGbp, DeviceType, SearchedAt)
VALUES
('sess_abc123', 1, 1, 1, 2010, 11, 1, 'Parts', 47, 132.50, 289.99, 'Desktop', DATEADD(HOUR, -2, GETUTCDATE())),
('sess_abc123', 1, 1, 1, 2010, NULL, 1, 'Faults', 5, NULL, NULL, 'Desktop', DATEADD(HOUR, -2, GETUTCDATE())),
('sess_def456', 2, 4, 4, 2012, NULL, NULL, 'Guide', 1, NULL, NULL, 'Mobile', DATEADD(HOUR, -5, GETUTCDATE())),
('sess_ghi789', 5, 9, 6, 2015, 2, NULL, 'Parts', 23, 45.00, 320.00, 'Tablet', DATEADD(DAY, -1, GETUTCDATE())),
('sess_jkl012', 6, 11, 8, 2013, 11, 5, 'Parts', 31, 180.00, 450.00, 'Desktop', DATEADD(DAY, -1, GETUTCDATE()));
GO

PRINT 'CarCheck database schema created successfully!';
GO
