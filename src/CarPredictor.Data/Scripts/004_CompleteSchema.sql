-- =============================================
-- Script: 004_CompleteSchema.sql
-- Description: Complete database schema for Used Car Repair Cost Predictor
-- Author: Auto-generated
-- Date: 2026-04-21
-- =============================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- DROP EXISTING TABLES (for clean install only)
-- Uncomment if starting fresh
-- =============================================
/*
DROP TABLE IF EXISTS dbo.UserReportVotes;
DROP TABLE IF EXISTS dbo.UserReports;
DROP TABLE IF EXISTS dbo.SubscriptionFeatures;
DROP TABLE IF EXISTS dbo.UserSubscriptions;
DROP TABLE IF EXISTS dbo.SubscriptionPlans;
DROP TABLE IF EXISTS dbo.Users;
DROP TABLE IF EXISTS dbo.PredictionHistory;
DROP TABLE IF EXISTS dbo.ReliabilityScores;
DROP TABLE IF EXISTS dbo.RepairCostRanges;
DROP TABLE IF EXISTS dbo.FailureRules;
DROP TABLE IF EXISTS dbo.MotDefectMapping;
DROP TABLE IF EXISTS dbo.ModelYears;
DROP TABLE IF EXISTS dbo.CarModels;
DROP TABLE IF EXISTS dbo.CarMakes;
DROP TABLE IF EXISTS dbo.FailureCategories;
DROP TABLE IF EXISTS dbo.Countries;
DROP TYPE IF EXISTS dbo.IntIdList;
*/
GO

-- =============================================
-- USER-DEFINED TABLE TYPES
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'IntIdList' AND is_table_type = 1)
BEGIN
    CREATE TYPE dbo.IntIdList AS TABLE (Id INT NOT NULL);
END
GO

-- =============================================
-- TABLE: Countries
-- Stores supported countries/regions with currency info
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Countries') AND type = 'U')
BEGIN
    CREATE TABLE dbo.Countries
    (
        CountryId           INT IDENTITY(1,1) NOT NULL,
        CountryCode         CHAR(2) NOT NULL,               -- ISO 3166-1 alpha-2 (UK, US, DE)
        CountryName         NVARCHAR(100) NOT NULL,
        CurrencyCode        CHAR(3) NOT NULL,               -- ISO 4217 (GBP, USD, EUR)
        CurrencySymbol      NVARCHAR(5) NOT NULL,           -- £, $, €
        LabourRatePerHour   DECIMAL(10,2) NOT NULL,         -- Average labour rate
        VatRate             DECIMAL(5,2) NOT NULL,          -- VAT/Tax rate (0.20 = 20%)
        HasMotSystem        BIT NOT NULL DEFAULT (0),       -- Has MOT-style inspection
        InspectionApiUrl    NVARCHAR(500) NULL,             -- API URL for vehicle history
        IsActive            BIT NOT NULL DEFAULT (1),
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_Countries PRIMARY KEY CLUSTERED (CountryId),
        CONSTRAINT UQ_Countries_Code UNIQUE (CountryCode),
        CONSTRAINT CK_Countries_VatRate CHECK (VatRate >= 0 AND VatRate <= 1)
    );
    
    CREATE NONCLUSTERED INDEX IX_Countries_Active 
    ON dbo.Countries (IsActive) INCLUDE (CountryCode, CountryName, CurrencyCode);
END
GO

-- =============================================
-- TABLE: CarMakes (Manufacturers)
-- Stores vehicle manufacturers/brands
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CarMakes') AND type = 'U')
BEGIN
    CREATE TABLE dbo.CarMakes
    (
        MakeId              INT IDENTITY(1,1) NOT NULL,
        MakeName            NVARCHAR(100) NOT NULL,
        MakeCode            NVARCHAR(20) NOT NULL,          -- Short code (BMW, FORD, VW)
        CountryOfOrigin     CHAR(2) NULL,                   -- FK to Countries
        LogoUrl             NVARCHAR(500) NULL,
        IsLuxuryBrand       BIT NOT NULL DEFAULT (0),
        IsActive            BIT NOT NULL DEFAULT (1),
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_CarMakes PRIMARY KEY CLUSTERED (MakeId),
        CONSTRAINT UQ_CarMakes_Code UNIQUE (MakeCode),
        CONSTRAINT UQ_CarMakes_Name UNIQUE (MakeName)
    );
    
    CREATE NONCLUSTERED INDEX IX_CarMakes_Active 
    ON dbo.CarMakes (IsActive) INCLUDE (MakeName, MakeCode);
END
GO

-- =============================================
-- TABLE: CarModels
-- Stores vehicle models linked to makes
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CarModels') AND type = 'U')
BEGIN
    CREATE TABLE dbo.CarModels
    (
        ModelId             INT IDENTITY(1,1) NOT NULL,
        MakeId              INT NOT NULL,
        ModelName           NVARCHAR(100) NOT NULL,
        ModelCode           NVARCHAR(50) NULL,              -- Internal code
        BodyType            NVARCHAR(50) NULL,              -- Hatchback, Saloon, SUV, Estate
        FuelTypes           NVARCHAR(200) NULL,             -- Petrol, Diesel, Hybrid, Electric
        TransmissionTypes   NVARCHAR(100) NULL,             -- Manual, Automatic, CVT
        ProductionStartYear INT NOT NULL,
        ProductionEndYear   INT NULL,                       -- NULL = still in production
        IsActive            BIT NOT NULL DEFAULT (1),
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_CarModels PRIMARY KEY CLUSTERED (ModelId),
        CONSTRAINT FK_CarModels_Make FOREIGN KEY (MakeId) 
            REFERENCES dbo.CarMakes(MakeId),
        CONSTRAINT CK_CarModels_Years CHECK (ProductionEndYear IS NULL OR ProductionEndYear >= ProductionStartYear)
    );
    
    CREATE NONCLUSTERED INDEX IX_CarModels_MakeId 
    ON dbo.CarModels (MakeId) INCLUDE (ModelName, ProductionStartYear, ProductionEndYear);
    
    CREATE NONCLUSTERED INDEX IX_CarModels_Active 
    ON dbo.CarModels (IsActive, MakeId);
END
GO

-- =============================================
-- TABLE: ModelYears
-- Stores specific year variants with engine options
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ModelYears') AND type = 'U')
BEGIN
    CREATE TABLE dbo.ModelYears
    (
        ModelYearId         INT IDENTITY(1,1) NOT NULL,
        ModelId             INT NOT NULL,
        [Year]              INT NOT NULL,
        Generation          NVARCHAR(50) NULL,              -- Mk1, Mk2, F30, W205
        FaceLift            NVARCHAR(50) NULL,              -- Pre-facelift, Post-facelift
        EngineCode          NVARCHAR(50) NULL,              -- N47, EA888, etc.
        EngineSize          DECIMAL(3,1) NULL,              -- 1.6, 2.0, 3.0
        EnginePower         INT NULL,                       -- HP/BHP
        FuelType            NVARCHAR(30) NULL,              -- Petrol, Diesel, Hybrid, Electric
        Transmission        NVARCHAR(30) NULL,              -- Manual, Automatic
        DriveType           NVARCHAR(30) NULL,              -- FWD, RWD, AWD
        CommonIssuesJson    NVARCHAR(MAX) NULL,             -- JSON array of known issues
        IsActive            BIT NOT NULL DEFAULT (1),
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        
        CONSTRAINT PK_ModelYears PRIMARY KEY CLUSTERED (ModelYearId),
        CONSTRAINT FK_ModelYears_Model FOREIGN KEY (ModelId) 
            REFERENCES dbo.CarModels(ModelId),
        CONSTRAINT UQ_ModelYears_Variant UNIQUE (ModelId, [Year], EngineCode, Transmission)
    );
    
    CREATE NONCLUSTERED INDEX IX_ModelYears_ModelId 
    ON dbo.ModelYears (ModelId, [Year]);
    
    CREATE NONCLUSTERED INDEX IX_ModelYears_Year 
    ON dbo.ModelYears ([Year]) INCLUDE (ModelId, FuelType);
END
GO

-- =============================================
-- TABLE: FailureCategories
-- Categories of component failures
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.FailureCategories') AND type = 'U')
BEGIN
    CREATE TABLE dbo.FailureCategories
    (
        CategoryId          INT IDENTITY(1,1) NOT NULL,
        CategoryCode        NVARCHAR(30) NOT NULL,          -- ENGINE, TRANS, BRAKES
        CategoryName        NVARCHAR(100) NOT NULL,
        [Description]       NVARCHAR(500) NULL,
        ParentCategoryId    INT NULL,                       -- For sub-categories
        DisplayOrder        INT NOT NULL DEFAULT (0),
        IconClass           NVARCHAR(50) NULL,              -- CSS icon class
        IsActive            BIT NOT NULL DEFAULT (1),
        
        CONSTRAINT PK_FailureCategories PRIMARY KEY CLUSTERED (CategoryId),
        CONSTRAINT UQ_FailureCategories_Code UNIQUE (CategoryCode),
        CONSTRAINT FK_FailureCategories_Parent FOREIGN KEY (ParentCategoryId) 
            REFERENCES dbo.FailureCategories(CategoryId)
    );
    
    CREATE NONCLUSTERED INDEX IX_FailureCategories_Parent 
    ON dbo.FailureCategories (ParentCategoryId);
END
GO

-- =============================================
-- TABLE: FailureRules
-- Rules for predicting failures based on vehicle attributes
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.FailureRules') AND type = 'U')
BEGIN
    CREATE TABLE dbo.FailureRules
    (
        RuleId              INT IDENTITY(1,1) NOT NULL,
        ModelYearId         INT NULL,                       -- NULL = applies to all years
        ModelId             INT NULL,                       -- NULL = applies to all models
        MakeId              INT NULL,                       -- NULL = applies to all makes
        CategoryId          INT NOT NULL,
        
        -- Rule Identification
        RuleName            NVARCHAR(200) NOT NULL,
        RuleCode            NVARCHAR(50) NOT NULL,
        [Description]       NVARCHAR(1000) NULL,
        
        -- Trigger Conditions
        MinMileage          INT NULL,                       -- Minimum mileage for rule
        MaxMileage          INT NULL,                       -- Maximum mileage for rule
        MinAge              INT NULL,                       -- Minimum vehicle age (years)
        MaxAge              INT NULL,                       -- Maximum vehicle age
        FuelTypeFilter      NVARCHAR(100) NULL,             -- Comma-separated: Diesel,Petrol
        TransmissionFilter  NVARCHAR(100) NULL,             -- Manual,Automatic
        
        -- Probability & Severity
        BaseProbability     DECIMAL(5,4) NOT NULL,          -- 0.0000 to 1.0000
        MileageMultiplier   DECIMAL(8,6) NULL,              -- Probability increase per 10k miles
        AgeMultiplier       DECIMAL(8,6) NULL,              -- Probability increase per year
        SeverityLevel       TINYINT NOT NULL,               -- 1=Low, 2=Medium, 3=High, 4=Critical
        
        -- Metadata
        DataSource          NVARCHAR(100) NULL,             -- MOT_DATA, MANUFACTURER, USER_REPORTS
        ConfidenceLevel     DECIMAL(3,2) NULL,              -- 0.00 to 1.00
        SampleSize          INT NULL,                       -- Number of data points
        IsRecall            BIT NOT NULL DEFAULT (0),       -- Is this a recall issue?
        RecallReference     NVARCHAR(100) NULL,
        IsActive            BIT NOT NULL DEFAULT (1),
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_FailureRules PRIMARY KEY CLUSTERED (RuleId),
        CONSTRAINT UQ_FailureRules_Code UNIQUE (RuleCode),
        CONSTRAINT FK_FailureRules_ModelYear FOREIGN KEY (ModelYearId) 
            REFERENCES dbo.ModelYears(ModelYearId),
        CONSTRAINT FK_FailureRules_Model FOREIGN KEY (ModelId) 
            REFERENCES dbo.CarModels(ModelId),
        CONSTRAINT FK_FailureRules_Make FOREIGN KEY (MakeId) 
            REFERENCES dbo.CarMakes(MakeId),
        CONSTRAINT FK_FailureRules_Category FOREIGN KEY (CategoryId) 
            REFERENCES dbo.FailureCategories(CategoryId),
        CONSTRAINT CK_FailureRules_Probability CHECK (BaseProbability >= 0 AND BaseProbability <= 1),
        CONSTRAINT CK_FailureRules_Severity CHECK (SeverityLevel BETWEEN 1 AND 4),
        CONSTRAINT CK_FailureRules_Mileage CHECK (MaxMileage IS NULL OR MinMileage IS NULL OR MaxMileage >= MinMileage),
        CONSTRAINT CK_FailureRules_Age CHECK (MaxAge IS NULL OR MinAge IS NULL OR MaxAge >= MinAge)
    );
    
    CREATE NONCLUSTERED INDEX IX_FailureRules_ModelYear 
    ON dbo.FailureRules (ModelYearId) INCLUDE (CategoryId, BaseProbability, SeverityLevel);
    
    CREATE NONCLUSTERED INDEX IX_FailureRules_Model 
    ON dbo.FailureRules (ModelId) INCLUDE (CategoryId, MinMileage, MaxMileage);
    
    CREATE NONCLUSTERED INDEX IX_FailureRules_Category 
    ON dbo.FailureRules (CategoryId, IsActive);
    
    CREATE NONCLUSTERED INDEX IX_FailureRules_Active 
    ON dbo.FailureRules (IsActive) WHERE IsActive = 1;
END
GO

-- =============================================
-- TABLE: RepairCostRanges
-- Cost estimates for repairs by country
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.RepairCostRanges') AND type = 'U')
BEGIN
    CREATE TABLE dbo.RepairCostRanges
    (
        CostRangeId         INT IDENTITY(1,1) NOT NULL,
        RuleId              INT NOT NULL,
        CountryId           INT NOT NULL,
        
        -- Cost Breakdown
        PartsMinCost        DECIMAL(10,2) NOT NULL,
        PartsMaxCost        DECIMAL(10,2) NOT NULL,
        PartsAvgCost        DECIMAL(10,2) NOT NULL,
        LabourMinHours      DECIMAL(5,2) NOT NULL,
        LabourMaxHours      DECIMAL(5,2) NOT NULL,
        LabourAvgHours      DECIMAL(5,2) NOT NULL,
        
        -- Total Costs (calculated with country labour rate)
        TotalMinCost        DECIMAL(10,2) NOT NULL,
        TotalMaxCost        DECIMAL(10,2) NOT NULL,
        TotalAvgCost        DECIMAL(10,2) NOT NULL,
        
        -- Dealer vs Independent
        DealerPremium       DECIMAL(5,2) NULL,              -- Percentage premium (0.30 = 30%)
        IndependentDiscount DECIMAL(5,2) NULL,              -- Percentage discount
        
        -- Validity
        EffectiveFrom       DATE NOT NULL,
        EffectiveTo         DATE NULL,
        LastPriceUpdate     DATETIME2 NULL,
        PriceSource         NVARCHAR(100) NULL,             -- DEALER, INDEPENDENT, SURVEY
        
        CONSTRAINT PK_RepairCostRanges PRIMARY KEY CLUSTERED (CostRangeId),
        CONSTRAINT FK_RepairCostRanges_Rule FOREIGN KEY (RuleId) 
            REFERENCES dbo.FailureRules(RuleId),
        CONSTRAINT FK_RepairCostRanges_Country FOREIGN KEY (CountryId) 
            REFERENCES dbo.Countries(CountryId),
        CONSTRAINT UQ_RepairCostRanges_RuleCountry UNIQUE (RuleId, CountryId, EffectiveFrom),
        CONSTRAINT CK_RepairCostRanges_Parts CHECK (PartsMinCost <= PartsAvgCost AND PartsAvgCost <= PartsMaxCost),
        CONSTRAINT CK_RepairCostRanges_Labour CHECK (LabourMinHours <= LabourAvgHours AND LabourAvgHours <= LabourMaxHours),
        CONSTRAINT CK_RepairCostRanges_Total CHECK (TotalMinCost <= TotalAvgCost AND TotalAvgCost <= TotalMaxCost)
    );
    
    CREATE NONCLUSTERED INDEX IX_RepairCostRanges_RuleCountry 
    ON dbo.RepairCostRanges (RuleId, CountryId) 
    INCLUDE (TotalMinCost, TotalMaxCost, TotalAvgCost);
    
    CREATE NONCLUSTERED INDEX IX_RepairCostRanges_Effective 
    ON dbo.RepairCostRanges (EffectiveFrom, EffectiveTo);
END
GO

-- =============================================
-- TABLE: ReliabilityScores
-- Pre-calculated reliability scores by model/year
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ReliabilityScores') AND type = 'U')
BEGIN
    CREATE TABLE dbo.ReliabilityScores
    (
        ScoreId             INT IDENTITY(1,1) NOT NULL,
        ModelYearId         INT NULL,                       -- Specific variant
        ModelId             INT NULL,                       -- Or general model
        MakeId              INT NULL,                       -- Or entire make
        
        -- Overall Score
        OverallScore        DECIMAL(5,2) NOT NULL,          -- 0-100 scale
        ScoreGrade          CHAR(1) NOT NULL,               -- A, B, C, D, F
        
        -- Category Scores
        EngineScore         DECIMAL(5,2) NULL,
        TransmissionScore   DECIMAL(5,2) NULL,
        ElectricalScore     DECIMAL(5,2) NULL,
        SuspensionScore     DECIMAL(5,2) NULL,
        BrakesScore         DECIMAL(5,2) NULL,
        BodyCorrosionScore  DECIMAL(5,2) NULL,
        
        -- Statistics
        TotalDataPoints     INT NOT NULL,
        MotFailureRate      DECIMAL(5,4) NULL,              -- MOT failure rate (UK)
        AvgAnnualRepairCost DECIMAL(10,2) NULL,
        
        -- Comparisons
        VsBrandAverage      DECIMAL(5,2) NULL,              -- Difference from brand avg
        VsClassAverage      DECIMAL(5,2) NULL,              -- Difference from class avg
        Ranking             INT NULL,                       -- Ranking in class
        TotalInClass        INT NULL,
        
        -- Metadata
        CalculatedAt        DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        ValidUntil          DATETIME2 NULL,
        DataSourcesJson     NVARCHAR(MAX) NULL,             -- JSON array of sources
        
        CONSTRAINT PK_ReliabilityScores PRIMARY KEY CLUSTERED (ScoreId),
        CONSTRAINT FK_ReliabilityScores_ModelYear FOREIGN KEY (ModelYearId) 
            REFERENCES dbo.ModelYears(ModelYearId),
        CONSTRAINT FK_ReliabilityScores_Model FOREIGN KEY (ModelId) 
            REFERENCES dbo.CarModels(ModelId),
        CONSTRAINT FK_ReliabilityScores_Make FOREIGN KEY (MakeId) 
            REFERENCES dbo.CarMakes(MakeId),
        CONSTRAINT CK_ReliabilityScores_Overall CHECK (OverallScore >= 0 AND OverallScore <= 100),
        CONSTRAINT CK_ReliabilityScores_Grade CHECK (ScoreGrade IN ('A', 'B', 'C', 'D', 'F'))
    );
    
    CREATE NONCLUSTERED INDEX IX_ReliabilityScores_ModelYear 
    ON dbo.ReliabilityScores (ModelYearId);
    
    CREATE NONCLUSTERED INDEX IX_ReliabilityScores_Model 
    ON dbo.ReliabilityScores (ModelId);
    
    CREATE NONCLUSTERED INDEX IX_ReliabilityScores_Score 
    ON dbo.ReliabilityScores (OverallScore DESC) INCLUDE (ModelYearId, ScoreGrade);
END
GO

-- =============================================
-- TABLE: Users
-- Application users for reports and subscriptions
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Users') AND type = 'U')
BEGIN
    CREATE TABLE dbo.Users
    (
        UserId              UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        Email               NVARCHAR(255) NOT NULL,
        PasswordHash        NVARCHAR(255) NULL,             -- NULL for OAuth users
        DisplayName         NVARCHAR(100) NULL,
        CountryId           INT NULL,
        
        -- OAuth
        AuthProvider        NVARCHAR(50) NULL,              -- Google, Microsoft, Apple
        AuthProviderId      NVARCHAR(255) NULL,
        
        -- Status
        IsEmailVerified     BIT NOT NULL DEFAULT (0),
        IsActive            BIT NOT NULL DEFAULT (1),
        IsBanned            BIT NOT NULL DEFAULT (0),
        
        -- Metadata
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        LastLoginAt         DATETIME2 NULL,
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId),
        CONSTRAINT UQ_Users_Email UNIQUE (Email),
        CONSTRAINT FK_Users_Country FOREIGN KEY (CountryId) 
            REFERENCES dbo.Countries(CountryId)
    );
    
    CREATE NONCLUSTERED INDEX IX_Users_Email 
    ON dbo.Users (Email);
    
    CREATE NONCLUSTERED INDEX IX_Users_AuthProvider 
    ON dbo.Users (AuthProvider, AuthProviderId) WHERE AuthProvider IS NOT NULL;
END
GO

-- =============================================
-- TABLE: SubscriptionPlans
-- Available subscription tiers
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.SubscriptionPlans') AND type = 'U')
BEGIN
    CREATE TABLE dbo.SubscriptionPlans
    (
        PlanId              INT IDENTITY(1,1) NOT NULL,
        PlanCode            NVARCHAR(30) NOT NULL,          -- FREE, BASIC, PRO, DEALER
        PlanName            NVARCHAR(100) NOT NULL,
        [Description]       NVARCHAR(500) NULL,
        
        -- Pricing
        MonthlyPrice        DECIMAL(10,2) NOT NULL,
        AnnualPrice         DECIMAL(10,2) NULL,             -- Annual discount price
        CurrencyCode        CHAR(3) NOT NULL DEFAULT 'GBP',
        
        -- Limits
        MonthlySearches     INT NULL,                       -- NULL = unlimited
        MonthlyReports      INT NULL,
        HistoryDays         INT NULL,                       -- How long to keep history
        
        -- Features (as flags)
        HasApiAccess        BIT NOT NULL DEFAULT (0),
        HasPdfExport        BIT NOT NULL DEFAULT (0),
        HasPrioritySupport  BIT NOT NULL DEFAULT (0),
        HasMotIntegration   BIT NOT NULL DEFAULT (0),
        HasBulkSearch       BIT NOT NULL DEFAULT (0),
        
        -- Status
        IsActive            BIT NOT NULL DEFAULT (1),
        DisplayOrder        INT NOT NULL DEFAULT (0),
        
        CONSTRAINT PK_SubscriptionPlans PRIMARY KEY CLUSTERED (PlanId),
        CONSTRAINT UQ_SubscriptionPlans_Code UNIQUE (PlanCode)
    );
END
GO

-- =============================================
-- TABLE: UserSubscriptions
-- User subscription records
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.UserSubscriptions') AND type = 'U')
BEGIN
    CREATE TABLE dbo.UserSubscriptions
    (
        SubscriptionId      UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        UserId              UNIQUEIDENTIFIER NOT NULL,
        PlanId              INT NOT NULL,
        
        -- Billing
        BillingCycle        NVARCHAR(20) NOT NULL,          -- MONTHLY, ANNUAL
        PriceAtPurchase     DECIMAL(10,2) NOT NULL,
        CurrencyCode        CHAR(3) NOT NULL,
        
        -- Dates
        StartDate           DATETIME2 NOT NULL,
        EndDate             DATETIME2 NULL,
        TrialEndDate        DATETIME2 NULL,
        CancelledAt         DATETIME2 NULL,
        
        -- Payment Provider
        PaymentProvider     NVARCHAR(50) NULL,              -- STRIPE, PAYPAL
        ExternalId          NVARCHAR(255) NULL,             -- Provider subscription ID
        
        -- Status
        [Status]            NVARCHAR(30) NOT NULL,          -- ACTIVE, CANCELLED, EXPIRED, PAST_DUE
        AutoRenew           BIT NOT NULL DEFAULT (1),
        
        -- Usage Tracking
        SearchesUsed        INT NOT NULL DEFAULT (0),
        ReportsGenerated    INT NOT NULL DEFAULT (0),
        LastResetDate       DATETIME2 NULL,
        
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_UserSubscriptions PRIMARY KEY CLUSTERED (SubscriptionId),
        CONSTRAINT FK_UserSubscriptions_User FOREIGN KEY (UserId) 
            REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_UserSubscriptions_Plan FOREIGN KEY (PlanId) 
            REFERENCES dbo.SubscriptionPlans(PlanId),
        CONSTRAINT CK_UserSubscriptions_Status CHECK ([Status] IN ('ACTIVE', 'CANCELLED', 'EXPIRED', 'PAST_DUE', 'TRIAL'))
    );
    
    CREATE NONCLUSTERED INDEX IX_UserSubscriptions_User 
    ON dbo.UserSubscriptions (UserId, [Status]);
    
    CREATE NONCLUSTERED INDEX IX_UserSubscriptions_Status 
    ON dbo.UserSubscriptions ([Status], EndDate);
END
GO

-- =============================================
-- TABLE: UserReports
-- User-submitted repair/issue reports
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.UserReports') AND type = 'U')
BEGIN
    CREATE TABLE dbo.UserReports
    (
        ReportId            UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        UserId              UNIQUEIDENTIFIER NULL,          -- NULL for anonymous
        ModelYearId         INT NOT NULL,
        CountryId           INT NOT NULL,
        CategoryId          INT NOT NULL,
        
        -- Vehicle Info
        VehicleMileage      INT NULL,
        VehicleAge          INT NULL,
        RegistrationYear    INT NULL,
        
        -- Issue Details
        IssueTitle          NVARCHAR(200) NOT NULL,
        IssueDescription    NVARCHAR(2000) NULL,
        RepairDescription   NVARCHAR(2000) NULL,
        
        -- Costs
        TotalCost           DECIMAL(10,2) NULL,
        PartsCost           DECIMAL(10,2) NULL,
        LabourCost          DECIMAL(10,2) NULL,
        WasWarrantyClaim    BIT NOT NULL DEFAULT (0),
        RepairLocation      NVARCHAR(50) NULL,              -- DEALER, INDEPENDENT, DIY
        
        -- Verification
        HasReceipt          BIT NOT NULL DEFAULT (0),
        ReceiptImageUrl     NVARCHAR(500) NULL,
        IsVerified          BIT NOT NULL DEFAULT (0),
        VerifiedAt          DATETIME2 NULL,
        VerifiedBy          UNIQUEIDENTIFIER NULL,
        
        -- Moderation
        [Status]            NVARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- PENDING, APPROVED, REJECTED
        ModerationNotes     NVARCHAR(500) NULL,
        
        -- Engagement
        UpvoteCount         INT NOT NULL DEFAULT (0),
        DownvoteCount       INT NOT NULL DEFAULT (0),
        ViewCount           INT NOT NULL DEFAULT (0),
        
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2 NULL,
        
        CONSTRAINT PK_UserReports PRIMARY KEY CLUSTERED (ReportId),
        CONSTRAINT FK_UserReports_User FOREIGN KEY (UserId) 
            REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_UserReports_ModelYear FOREIGN KEY (ModelYearId) 
            REFERENCES dbo.ModelYears(ModelYearId),
        CONSTRAINT FK_UserReports_Country FOREIGN KEY (CountryId) 
            REFERENCES dbo.Countries(CountryId),
        CONSTRAINT FK_UserReports_Category FOREIGN KEY (CategoryId) 
            REFERENCES dbo.FailureCategories(CategoryId),
        CONSTRAINT CK_UserReports_Status CHECK ([Status] IN ('PENDING', 'APPROVED', 'REJECTED', 'FLAGGED'))
    );
    
    CREATE NONCLUSTERED INDEX IX_UserReports_ModelYear 
    ON dbo.UserReports (ModelYearId, [Status]) INCLUDE (CategoryId, TotalCost);
    
    CREATE NONCLUSTERED INDEX IX_UserReports_User 
    ON dbo.UserReports (UserId) WHERE UserId IS NOT NULL;
    
    CREATE NONCLUSTERED INDEX IX_UserReports_Status 
    ON dbo.UserReports ([Status], CreatedAt DESC);
    
    CREATE NONCLUSTERED INDEX IX_UserReports_Category 
    ON dbo.UserReports (CategoryId, [Status]);
END
GO

-- =============================================
-- TABLE: UserReportVotes
-- Track user votes on reports
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.UserReportVotes') AND type = 'U')
BEGIN
    CREATE TABLE dbo.UserReportVotes
    (
        VoteId              INT IDENTITY(1,1) NOT NULL,
        ReportId            UNIQUEIDENTIFIER NOT NULL,
        UserId              UNIQUEIDENTIFIER NOT NULL,
        VoteType            TINYINT NOT NULL,               -- 1 = Upvote, -1 = Downvote
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        
        CONSTRAINT PK_UserReportVotes PRIMARY KEY CLUSTERED (VoteId),
        CONSTRAINT FK_UserReportVotes_Report FOREIGN KEY (ReportId) 
            REFERENCES dbo.UserReports(ReportId),
        CONSTRAINT FK_UserReportVotes_User FOREIGN KEY (UserId) 
            REFERENCES dbo.Users(UserId),
        CONSTRAINT UQ_UserReportVotes_UserReport UNIQUE (UserId, ReportId),
        CONSTRAINT CK_UserReportVotes_Type CHECK (VoteType IN (1, -1))
    );
    
    CREATE NONCLUSTERED INDEX IX_UserReportVotes_Report 
    ON dbo.UserReportVotes (ReportId);
END
GO

-- =============================================
-- TABLE: MotDefectMapping
-- Maps MOT defect codes to failure categories
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.MotDefectMapping') AND type = 'U')
BEGIN
    CREATE TABLE dbo.MotDefectMapping
    (
        MappingId           INT IDENTITY(1,1) NOT NULL,
        DefectCode          NVARCHAR(20) NOT NULL,          -- DVSA defect code
        DefectText          NVARCHAR(500) NOT NULL,
        CategoryId          INT NOT NULL,
        ProbabilityWeight   DECIMAL(5,4) NOT NULL,          -- Weight for probability calc
        SeverityIndicator   TINYINT NOT NULL,               -- 1-4
        IsActive            BIT NOT NULL DEFAULT (1),
        
        CONSTRAINT PK_MotDefectMapping PRIMARY KEY CLUSTERED (MappingId),
        CONSTRAINT FK_MotDefectMapping_Category FOREIGN KEY (CategoryId) 
            REFERENCES dbo.FailureCategories(CategoryId),
        CONSTRAINT UQ_MotDefectMapping_Code UNIQUE (DefectCode)
    );
    
    CREATE NONCLUSTERED INDEX IX_MotDefectMapping_Category 
    ON dbo.MotDefectMapping (CategoryId);
END
GO

-- =============================================
-- TABLE: PredictionHistory
-- Stores user prediction requests for analytics
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PredictionHistory') AND type = 'U')
BEGIN
    CREATE TABLE dbo.PredictionHistory
    (
        PredictionId        UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWSEQUENTIALID()),
        UserId              UNIQUEIDENTIFIER NULL,
        ModelYearId         INT NOT NULL,
        CountryId           INT NOT NULL,
        
        -- Input
        Mileage             INT NOT NULL,
        RegistrationNumber  NVARCHAR(20) NULL,              -- Optional UK reg
        
        -- Results
        ReliabilityScore    DECIMAL(5,2) NOT NULL,
        TwelveMonthCost     DECIMAL(10,2) NOT NULL,
        ThreeYearCost       DECIMAL(10,2) NOT NULL,
        TopIssuesJson       NVARCHAR(MAX) NOT NULL,         -- JSON array of top failures
        FullResultJson      NVARCHAR(MAX) NULL,             -- Complete result for caching
        
        -- Tracking
        SessionId           NVARCHAR(100) NULL,
        IpAddress           NVARCHAR(45) NULL,
        UserAgent           NVARCHAR(500) NULL,
        
        CreatedAt           DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        
        CONSTRAINT PK_PredictionHistory PRIMARY KEY CLUSTERED (PredictionId),
        CONSTRAINT FK_PredictionHistory_User FOREIGN KEY (UserId) 
            REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_PredictionHistory_ModelYear FOREIGN KEY (ModelYearId) 
            REFERENCES dbo.ModelYears(ModelYearId),
        CONSTRAINT FK_PredictionHistory_Country FOREIGN KEY (CountryId) 
            REFERENCES dbo.Countries(CountryId)
    );
    
    CREATE NONCLUSTERED INDEX IX_PredictionHistory_User 
    ON dbo.PredictionHistory (UserId, CreatedAt DESC) WHERE UserId IS NOT NULL;
    
    CREATE NONCLUSTERED INDEX IX_PredictionHistory_ModelYear 
    ON dbo.PredictionHistory (ModelYearId, CreatedAt DESC);
    
    CREATE NONCLUSTERED INDEX IX_PredictionHistory_Date 
    ON dbo.PredictionHistory (CreatedAt DESC);
END
GO

PRINT 'Schema creation completed successfully.';
GO
