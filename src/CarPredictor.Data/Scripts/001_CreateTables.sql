-- =============================================
-- Script: 001_CreateTables.sql
-- Description: Creates all tables for the Car Repair Predictor database
-- =============================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- User-Defined Table Types
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'IntIdList' AND is_table_type = 1)
BEGIN
    CREATE TYPE dbo.IntIdList AS TABLE
    (
        Id INT NOT NULL
    );
END
GO

-- =============================================
-- Reference Tables
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Region') AND type = 'U')
BEGIN
    CREATE TABLE dbo.Region
    (
        RegionId        INT IDENTITY(1,1) NOT NULL,
        RegionCode      NVARCHAR(10) NOT NULL,
        RegionName      NVARCHAR(100) NOT NULL,
        CurrencyCode    NVARCHAR(3) NOT NULL,
        IsActive        BIT NOT NULL CONSTRAINT DF_Region_IsActive DEFAULT (1),
        CONSTRAINT PK_Region PRIMARY KEY CLUSTERED (RegionId),
        CONSTRAINT UQ_Region_Code UNIQUE (RegionCode)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Manufacturer') AND type = 'U')
BEGIN
    CREATE TABLE dbo.Manufacturer
    (
        ManufacturerId      INT IDENTITY(1,1) NOT NULL,
        ManufacturerName    NVARCHAR(100) NOT NULL,
        CountryOfOrigin     NVARCHAR(100) NULL,
        CONSTRAINT PK_Manufacturer PRIMARY KEY CLUSTERED (ManufacturerId)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VehicleModel') AND type = 'U')
BEGIN
    CREATE TABLE dbo.VehicleModel
    (
        VehicleModelId  INT IDENTITY(1,1) NOT NULL,
        ManufacturerId  INT NOT NULL,
        ModelName       NVARCHAR(100) NOT NULL,
        YearStart       INT NOT NULL,
        YearEnd         INT NULL,
        EngineTypes     NVARCHAR(500) NULL,
        CONSTRAINT PK_VehicleModel PRIMARY KEY CLUSTERED (VehicleModelId),
        CONSTRAINT FK_VehicleModel_Manufacturer FOREIGN KEY (ManufacturerId) 
            REFERENCES dbo.Manufacturer(ManufacturerId)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.FailureCategory') AND type = 'U')
BEGIN
    CREATE TABLE dbo.FailureCategory
    (
        FailureCategoryId   INT IDENTITY(1,1) NOT NULL,
        CategoryCode        NVARCHAR(50) NOT NULL,
        CategoryName        NVARCHAR(100) NOT NULL,
        [Description]       NVARCHAR(500) NULL,
        CONSTRAINT PK_FailureCategory PRIMARY KEY CLUSTERED (FailureCategoryId),
        CONSTRAINT UQ_FailureCategory_Code UNIQUE (CategoryCode)
    );
END
GO

-- =============================================
-- Core Data Tables
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.FailurePattern') AND type = 'U')
BEGIN
    CREATE TABLE dbo.FailurePattern
    (
        FailurePatternId    INT IDENTITY(1,1) NOT NULL,
        VehicleModelId      INT NOT NULL,
        FailureCategoryId   INT NOT NULL,
        FailureName         NVARCHAR(200) NOT NULL,
        [Description]       NVARCHAR(1000) NULL,
        MinMileage          INT NULL,
        MaxMileage          INT NULL,
        MinAge              INT NULL,
        MaxAge              INT NULL,
        BaseProbability     DECIMAL(5,4) NOT NULL,
        SeverityLevel       TINYINT NOT NULL,
        IsCommon            BIT NOT NULL CONSTRAINT DF_FailurePattern_IsCommon DEFAULT (0),
        DataSource          NVARCHAR(100) NULL,
        CONSTRAINT PK_FailurePattern PRIMARY KEY CLUSTERED (FailurePatternId),
        CONSTRAINT FK_FailurePattern_VehicleModel FOREIGN KEY (VehicleModelId)
            REFERENCES dbo.VehicleModel(VehicleModelId),
        CONSTRAINT FK_FailurePattern_Category FOREIGN KEY (FailureCategoryId)
            REFERENCES dbo.FailureCategory(FailureCategoryId),
        CONSTRAINT CK_FailurePattern_Severity CHECK (SeverityLevel BETWEEN 1 AND 4),
        CONSTRAINT CK_FailurePattern_Probability CHECK (BaseProbability BETWEEN 0.0000 AND 1.0000)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.RepairCost') AND type = 'U')
BEGIN
    CREATE TABLE dbo.RepairCost
    (
        RepairCostId        INT IDENTITY(1,1) NOT NULL,
        FailurePatternId    INT NOT NULL,
        RegionId            INT NOT NULL,
        MinCost             DECIMAL(10,2) NOT NULL,
        MaxCost             DECIMAL(10,2) NOT NULL,
        AverageCost         DECIMAL(10,2) NOT NULL,
        LabourHours         DECIMAL(5,2) NULL,
        PartsOnlyCost       DECIMAL(10,2) NULL,
        EffectiveFrom       DATE NOT NULL,
        EffectiveTo         DATE NULL,
        CONSTRAINT PK_RepairCost PRIMARY KEY CLUSTERED (RepairCostId),
        CONSTRAINT FK_RepairCost_FailurePattern FOREIGN KEY (FailurePatternId)
            REFERENCES dbo.FailurePattern(FailurePatternId),
        CONSTRAINT FK_RepairCost_Region FOREIGN KEY (RegionId)
            REFERENCES dbo.Region(RegionId),
        CONSTRAINT CK_RepairCost_MinMax CHECK (MinCost <= MaxCost)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.MotDefectMapping') AND type = 'U')
BEGIN
    CREATE TABLE dbo.MotDefectMapping
    (
        MotDefectMappingId  INT IDENTITY(1,1) NOT NULL,
        MotDefectCode       NVARCHAR(20) NOT NULL,
        MotDefectText       NVARCHAR(500) NOT NULL,
        FailureCategoryId   INT NOT NULL,
        ProbabilityWeight   DECIMAL(5,4) NOT NULL,
        CONSTRAINT PK_MotDefectMapping PRIMARY KEY CLUSTERED (MotDefectMappingId),
        CONSTRAINT FK_MotDefectMapping_Category FOREIGN KEY (FailureCategoryId)
            REFERENCES dbo.FailureCategory(FailureCategoryId)
    );
END
GO

-- =============================================
-- Prediction History Table
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PredictionHistory') AND type = 'U')
BEGIN
    CREATE TABLE dbo.PredictionHistory
    (
        PredictionHistoryId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PredictionHistory_Id DEFAULT (NEWSEQUENTIALID()),
        VehicleModelId      INT NOT NULL,
        [Year]              INT NOT NULL,
        Mileage             INT NOT NULL,
        RegionId            INT NOT NULL,
        RegistrationNumber  NVARCHAR(20) NULL,
        ReliabilityScore    DECIMAL(5,2) NOT NULL,
        TwelveMonthCost     DECIMAL(10,2) NOT NULL,
        ThreeYearCost       DECIMAL(10,2) NOT NULL,
        PredictionJson      NVARCHAR(MAX) NOT NULL,
        CreatedAt           DATETIME2 NOT NULL CONSTRAINT DF_PredictionHistory_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_PredictionHistory PRIMARY KEY CLUSTERED (PredictionHistoryId),
        CONSTRAINT FK_PredictionHistory_VehicleModel FOREIGN KEY (VehicleModelId)
            REFERENCES dbo.VehicleModel(VehicleModelId),
        CONSTRAINT FK_PredictionHistory_Region FOREIGN KEY (RegionId)
            REFERENCES dbo.Region(RegionId)
    );
END
GO

-- =============================================
-- Indexes
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleModel_ManufacturerId')
BEGIN
    CREATE NONCLUSTERED INDEX IX_VehicleModel_ManufacturerId
    ON dbo.VehicleModel (ManufacturerId);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FailurePattern_VehicleModelId')
BEGIN
    CREATE NONCLUSTERED INDEX IX_FailurePattern_VehicleModelId
    ON dbo.FailurePattern (VehicleModelId)
    INCLUDE (FailureCategoryId, FailureName, BaseProbability, SeverityLevel);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RepairCost_FailurePatternId_RegionId')
BEGIN
    CREATE NONCLUSTERED INDEX IX_RepairCost_FailurePatternId_RegionId
    ON dbo.RepairCost (FailurePatternId, RegionId)
    INCLUDE (MinCost, MaxCost, AverageCost);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PredictionHistory_VehicleModelId')
BEGIN
    CREATE NONCLUSTERED INDEX IX_PredictionHistory_VehicleModelId
    ON dbo.PredictionHistory (VehicleModelId, CreatedAt DESC);
END
GO

PRINT 'Tables created successfully.';
GO
