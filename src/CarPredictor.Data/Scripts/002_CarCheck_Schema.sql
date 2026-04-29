-- =====================================================
-- CarCheck Platform - Database Migration Script
-- Phase 1: Core Schema Extensions
-- Run after existing CarRepairPredictor schema
-- =====================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Starting CarCheck Platform schema migration...';
GO

-- =====================================================
-- 1. ENGINE SPECIFICATIONS TABLE
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EngineSpec]'))
BEGIN
    CREATE TABLE [dbo].[EngineSpec] (
        [EngineSpecId] INT IDENTITY(1,1) NOT NULL,
        [VehicleModelId] INT NOT NULL,
        [EngineCode] NVARCHAR(20) NOT NULL,
        [EngineName] NVARCHAR(100) NULL,
        [Displacement] DECIMAL(4,2) NULL,
        [FuelType] NVARCHAR(20) NULL,
        [Power] INT NULL,
        [Torque] INT NULL,
        [YearStart] INT NULL,
        [YearEnd] INT NULL,
        [IsCommon] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_EngineSpec] PRIMARY KEY CLUSTERED ([EngineSpecId]),
        CONSTRAINT [FK_EngineSpec_VehicleModel] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_EngineSpec_VehicleModel] 
        ON [dbo].[EngineSpec]([VehicleModelId]);
    
    PRINT 'Created table: EngineSpec';
END
GO

-- =====================================================
-- 2. PARTS DOMAIN TABLES
-- =====================================================

-- Part Categories
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PartCategory]'))
BEGIN
    CREATE TABLE [dbo].[PartCategory] (
        [PartCategoryId] INT IDENTITY(1,1) NOT NULL,
        [CategoryName] NVARCHAR(50) NOT NULL,
        [ParentCategoryId] INT NULL,
        [IconName] NVARCHAR(50) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [PK_PartCategory] PRIMARY KEY CLUSTERED ([PartCategoryId]),
        CONSTRAINT [FK_PartCategory_Parent] FOREIGN KEY ([ParentCategoryId]) 
            REFERENCES [dbo].[PartCategory]([PartCategoryId])
    );
    
    PRINT 'Created table: PartCategory';
END
GO

-- Parts Master
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Part]'))
BEGIN
    CREATE TABLE [dbo].[Part] (
        [PartId] INT IDENTITY(1,1) NOT NULL,
        [PartCategoryId] INT NOT NULL,
        [PartName] NVARCHAR(200) NOT NULL,
        [PartDescription] NVARCHAR(MAX) NULL,
        [OemPartNumber] NVARCHAR(50) NULL,
        [IsUniversal] BIT NOT NULL DEFAULT 0,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_Part] PRIMARY KEY CLUSTERED ([PartId]),
        CONSTRAINT [FK_Part_Category] FOREIGN KEY ([PartCategoryId]) 
            REFERENCES [dbo].[PartCategory]([PartCategoryId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_Part_Category] 
        ON [dbo].[Part]([PartCategoryId]);
    CREATE NONCLUSTERED INDEX [IX_Part_OemNumber] 
        ON [dbo].[Part]([OemPartNumber]) WHERE [OemPartNumber] IS NOT NULL;
    
    PRINT 'Created table: Part';
END
GO

-- Vehicle-Part Compatibility
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehiclePartCompatibility]'))
BEGIN
    CREATE TABLE [dbo].[VehiclePartCompatibility] (
        [VehiclePartCompatibilityId] INT IDENTITY(1,1) NOT NULL,
        [PartId] INT NOT NULL,
        [VehicleModelId] INT NOT NULL,
        [EngineSpecId] INT NULL,
        [YearStart] INT NULL,
        [YearEnd] INT NULL,
        [Notes] NVARCHAR(500) NULL,
        CONSTRAINT [PK_VehiclePartCompatibility] PRIMARY KEY CLUSTERED ([VehiclePartCompatibilityId]),
        CONSTRAINT [FK_VehiclePartCompat_Part] FOREIGN KEY ([PartId]) 
            REFERENCES [dbo].[Part]([PartId]),
        CONSTRAINT [FK_VehiclePartCompat_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId]),
        CONSTRAINT [FK_VehiclePartCompat_Engine] FOREIGN KEY ([EngineSpecId]) 
            REFERENCES [dbo].[EngineSpec]([EngineSpecId]),
        CONSTRAINT [UQ_VehiclePartCompat] UNIQUE ([PartId], [VehicleModelId], [EngineSpecId])
    );
    
    PRINT 'Created table: VehiclePartCompatibility';
END
GO

-- Suppliers
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Supplier]'))
BEGIN
    CREATE TABLE [dbo].[Supplier] (
        [SupplierId] INT IDENTITY(1,1) NOT NULL,
        [SupplierName] NVARCHAR(100) NOT NULL,
        [SupplierCode] NVARCHAR(20) NOT NULL,
        [WebsiteUrl] NVARCHAR(500) NULL,
        [ApiEndpoint] NVARCHAR(500) NULL,
        [LogoUrl] NVARCHAR(500) NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [RatingWeight] DECIMAL(3,2) NOT NULL DEFAULT 1.0,
        [ShippingToUk] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_Supplier] PRIMARY KEY CLUSTERED ([SupplierId]),
        CONSTRAINT [UQ_Supplier_Code] UNIQUE ([SupplierCode])
    );
    
    PRINT 'Created table: Supplier';
END
GO

-- Part Listings (cached from suppliers)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PartListing]'))
BEGIN
    CREATE TABLE [dbo].[PartListing] (
        [PartListingId] BIGINT IDENTITY(1,1) NOT NULL,
        [PartId] INT NOT NULL,
        [SupplierId] INT NOT NULL,
        [ExternalId] NVARCHAR(100) NULL,
        [SupplierPartNumber] NVARCHAR(100) NULL,
        [Title] NVARCHAR(500) NULL,
        [Price] DECIMAL(10,2) NOT NULL,
        [Currency] NVARCHAR(3) NOT NULL DEFAULT 'GBP',
        [ShippingCost] DECIMAL(10,2) NULL,
        [Availability] NVARCHAR(50) NULL,
        [SellerName] NVARCHAR(200) NULL,
        [SellerRating] DECIMAL(3,2) NULL,
        [SellerReviewCount] INT NULL,
        [Condition] NVARCHAR(20) NULL,
        [ListingUrl] NVARCHAR(1000) NULL,
        [ImageUrl] NVARCHAR(1000) NULL,
        [LastUpdated] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [ExpiresAt] DATETIME2 NULL,
        CONSTRAINT [PK_PartListing] PRIMARY KEY CLUSTERED ([PartListingId]),
        CONSTRAINT [FK_PartListing_Part] FOREIGN KEY ([PartId]) 
            REFERENCES [dbo].[Part]([PartId]),
        CONSTRAINT [FK_PartListing_Supplier] FOREIGN KEY ([SupplierId]) 
            REFERENCES [dbo].[Supplier]([SupplierId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_PartListing_Part] 
        ON [dbo].[PartListing]([PartId]);
    CREATE NONCLUSTERED INDEX [IX_PartListing_Supplier] 
        ON [dbo].[PartListing]([SupplierId]);
    CREATE NONCLUSTERED INDEX [IX_PartListing_Price] 
        ON [dbo].[PartListing]([Price]);
    CREATE NONCLUSTERED INDEX [IX_PartListing_Expires] 
        ON [dbo].[PartListing]([ExpiresAt]) WHERE [ExpiresAt] IS NOT NULL;
    
    PRINT 'Created table: PartListing';
END
GO

-- Part Search History
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PartSearchHistory]'))
BEGIN
    CREATE TABLE [dbo].[PartSearchHistory] (
        [PartSearchHistoryId] BIGINT IDENTITY(1,1) NOT NULL,
        [UserId] INT NULL,
        [VehicleModelId] INT NULL,
        [EngineSpecId] INT NULL,
        [SearchQuery] NVARCHAR(200) NULL,
        [PartCategoryId] INT NULL,
        [ResultCount] INT NULL,
        [SearchedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_PartSearchHistory] PRIMARY KEY CLUSTERED ([PartSearchHistoryId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_PartSearchHistory_Date] 
        ON [dbo].[PartSearchHistory]([SearchedAt]);
    
    PRINT 'Created table: PartSearchHistory';
END
GO

-- =====================================================
-- 3. FAULTS DOMAIN EXTENSIONS
-- =====================================================

-- Symptoms
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Symptom]'))
BEGIN
    CREATE TABLE [dbo].[Symptom] (
        [SymptomId] INT IDENTITY(1,1) NOT NULL,
        [SymptomName] NVARCHAR(100) NOT NULL,
        [SymptomDescription] NVARCHAR(500) NULL,
        [CategoryId] INT NULL,
        CONSTRAINT [PK_Symptom] PRIMARY KEY CLUSTERED ([SymptomId]),
        CONSTRAINT [FK_Symptom_Category] FOREIGN KEY ([CategoryId]) 
            REFERENCES [dbo].[FailureCategory]([FailureCategoryId])
    );
    
    PRINT 'Created table: Symptom';
END
GO

-- Fault-Symptom Mapping
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FaultSymptom]'))
BEGIN
    CREATE TABLE [dbo].[FaultSymptom] (
        [FaultSymptomId] INT IDENTITY(1,1) NOT NULL,
        [FailurePatternId] INT NOT NULL,
        [SymptomId] INT NOT NULL,
        [IsCommon] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [PK_FaultSymptom] PRIMARY KEY CLUSTERED ([FaultSymptomId]),
        CONSTRAINT [FK_FaultSymptom_Fault] FOREIGN KEY ([FailurePatternId]) 
            REFERENCES [dbo].[FailurePattern]([FailurePatternId]),
        CONSTRAINT [FK_FaultSymptom_Symptom] FOREIGN KEY ([SymptomId]) 
            REFERENCES [dbo].[Symptom]([SymptomId]),
        CONSTRAINT [UQ_FaultSymptom] UNIQUE ([FailurePatternId], [SymptomId])
    );
    
    PRINT 'Created table: FaultSymptom';
END
GO

-- Community Fault Reports
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FaultReport]'))
BEGIN
    CREATE TABLE [dbo].[FaultReport] (
        [FaultReportId] BIGINT IDENTITY(1,1) NOT NULL,
        [UserId] INT NULL,
        [VehicleModelId] INT NOT NULL,
        [EngineSpecId] INT NULL,
        [FailurePatternId] INT NULL,
        [VehicleYear] INT NULL,
        [MileageAtFailure] INT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [RepairCost] DECIMAL(10,2) NULL,
        [RepairDifficulty] TINYINT NULL,
        [WasWarranty] BIT NOT NULL DEFAULT 0,
        [ReportedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        [IsVerified] BIT NOT NULL DEFAULT 0,
        [UpvoteCount] INT NOT NULL DEFAULT 0,
        CONSTRAINT [PK_FaultReport] PRIMARY KEY CLUSTERED ([FaultReportId]),
        CONSTRAINT [FK_FaultReport_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId]),
        CONSTRAINT [FK_FaultReport_Engine] FOREIGN KEY ([EngineSpecId]) 
            REFERENCES [dbo].[EngineSpec]([EngineSpecId]),
        CONSTRAINT [FK_FaultReport_Fault] FOREIGN KEY ([FailurePatternId]) 
            REFERENCES [dbo].[FailurePattern]([FailurePatternId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_FaultReport_Vehicle] 
        ON [dbo].[FaultReport]([VehicleModelId]);
    CREATE NONCLUSTERED INDEX [IX_FaultReport_Fault] 
        ON [dbo].[FaultReport]([FailurePatternId]) WHERE [FailurePatternId] IS NOT NULL;
    
    PRINT 'Created table: FaultReport';
END
GO

-- Fault Fixes
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FaultFix]'))
BEGIN
    CREATE TABLE [dbo].[FaultFix] (
        [FaultFixId] INT IDENTITY(1,1) NOT NULL,
        [FailurePatternId] INT NOT NULL,
        [FixTitle] NVARCHAR(200) NOT NULL,
        [FixDescription] NVARCHAR(MAX) NULL,
        [EstimatedLabourHours] DECIMAL(4,2) NULL,
        [DifficultyLevel] TINYINT NULL,
        [RequiresSpecialistTools] BIT NOT NULL DEFAULT 0,
        [VideoUrl] NVARCHAR(500) NULL,
        [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_FaultFix] PRIMARY KEY CLUSTERED ([FaultFixId]),
        CONSTRAINT [FK_FaultFix_Fault] FOREIGN KEY ([FailurePatternId]) 
            REFERENCES [dbo].[FailurePattern]([FailurePatternId])
    );
    
    PRINT 'Created table: FaultFix';
END
GO

-- Fault Fix Parts
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FaultFixPart]'))
BEGIN
    CREATE TABLE [dbo].[FaultFixPart] (
        [FaultFixPartId] INT IDENTITY(1,1) NOT NULL,
        [FaultFixId] INT NOT NULL,
        [PartId] INT NOT NULL,
        [Quantity] INT NOT NULL DEFAULT 1,
        [IsOptional] BIT NOT NULL DEFAULT 0,
        CONSTRAINT [PK_FaultFixPart] PRIMARY KEY CLUSTERED ([FaultFixPartId]),
        CONSTRAINT [FK_FaultFixPart_Fix] FOREIGN KEY ([FaultFixId]) 
            REFERENCES [dbo].[FaultFix]([FaultFixId]),
        CONSTRAINT [FK_FaultFixPart_Part] FOREIGN KEY ([PartId]) 
            REFERENCES [dbo].[Part]([PartId])
    );
    
    PRINT 'Created table: FaultFixPart';
END
GO

-- =====================================================
-- 4. BUYER'S GUIDE DOMAIN
-- =====================================================

-- Checklist Categories
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChecklistCategory]'))
BEGIN
    CREATE TABLE [dbo].[ChecklistCategory] (
        [ChecklistCategoryId] INT IDENTITY(1,1) NOT NULL,
        [CategoryName] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(200) NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        CONSTRAINT [PK_ChecklistCategory] PRIMARY KEY CLUSTERED ([ChecklistCategoryId])
    );
    
    PRINT 'Created table: ChecklistCategory';
END
GO

-- Checklist Items
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChecklistItem]'))
BEGIN
    CREATE TABLE [dbo].[ChecklistItem] (
        [ChecklistItemId] INT IDENTITY(1,1) NOT NULL,
        [ChecklistCategoryId] INT NOT NULL,
        [VehicleModelId] INT NULL,
        [ItemTitle] NVARCHAR(200) NOT NULL,
        [ItemDescription] NVARCHAR(MAX) NULL,
        [WhyImportant] NVARCHAR(500) NULL,
        [HowToCheck] NVARCHAR(MAX) NULL,
        [RedFlags] NVARCHAR(500) NULL,
        [EstimatedRepairCost] NVARCHAR(100) NULL,
        [Severity] TINYINT NULL,
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        CONSTRAINT [PK_ChecklistItem] PRIMARY KEY CLUSTERED ([ChecklistItemId]),
        CONSTRAINT [FK_ChecklistItem_Category] FOREIGN KEY ([ChecklistCategoryId]) 
            REFERENCES [dbo].[ChecklistCategory]([ChecklistCategoryId]),
        CONSTRAINT [FK_ChecklistItem_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId])
    );
    
    PRINT 'Created table: ChecklistItem';
END
GO

-- MOT Defect Categories
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MotDefectCategory]'))
BEGIN
    CREATE TABLE [dbo].[MotDefectCategory] (
        [MotDefectCategoryId] INT IDENTITY(1,1) NOT NULL,
        [CategoryCode] NVARCHAR(10) NOT NULL,
        [CategoryName] NVARCHAR(100) NOT NULL,
        [ParentCategoryId] INT NULL,
        CONSTRAINT [PK_MotDefectCategory] PRIMARY KEY CLUSTERED ([MotDefectCategoryId]),
        CONSTRAINT [FK_MotDefectCategory_Parent] FOREIGN KEY ([ParentCategoryId]) 
            REFERENCES [dbo].[MotDefectCategory]([MotDefectCategoryId])
    );
    
    PRINT 'Created table: MotDefectCategory';
END
GO

-- MOT Failure Patterns
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MotFailurePattern]'))
BEGIN
    CREATE TABLE [dbo].[MotFailurePattern] (
        [MotFailurePatternId] INT IDENTITY(1,1) NOT NULL,
        [VehicleModelId] INT NOT NULL,
        [MotDefectCategoryId] INT NOT NULL,
        [DefectDescription] NVARCHAR(500) NULL,
        [FailureRate] DECIMAL(5,2) NULL,
        [AvgMileageAtFailure] INT NULL,
        [SampleSize] INT NULL,
        [DataYear] INT NULL,
        CONSTRAINT [PK_MotFailurePattern] PRIMARY KEY CLUSTERED ([MotFailurePatternId]),
        CONSTRAINT [FK_MotFailurePattern_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId]),
        CONSTRAINT [FK_MotFailurePattern_Category] FOREIGN KEY ([MotDefectCategoryId]) 
            REFERENCES [dbo].[MotDefectCategory]([MotDefectCategoryId])
    );
    
    CREATE NONCLUSTERED INDEX [IX_MotFailurePattern_Vehicle] 
        ON [dbo].[MotFailurePattern]([VehicleModelId]);
    
    PRINT 'Created table: MotFailurePattern';
END
GO

-- Reliability Scores
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReliabilityScore]'))
BEGIN
    CREATE TABLE [dbo].[ReliabilityScore] (
        [ReliabilityScoreId] INT IDENTITY(1,1) NOT NULL,
        [VehicleModelId] INT NOT NULL,
        [EngineSpecId] INT NULL,
        [OverallScore] DECIMAL(4,2) NULL,
        [EngineScore] DECIMAL(4,2) NULL,
        [TransmissionScore] DECIMAL(4,2) NULL,
        [ElectricalScore] DECIMAL(4,2) NULL,
        [SuspensionScore] DECIMAL(4,2) NULL,
        [BodyCorrosionScore] DECIMAL(4,2) NULL,
        [RunningCostScore] DECIMAL(4,2) NULL,
        [MotPassRate] DECIMAL(5,2) NULL,
        [AverageRepairCost] DECIMAL(10,2) NULL,
        [SampleSize] INT NULL,
        [CalculatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_ReliabilityScore] PRIMARY KEY CLUSTERED ([ReliabilityScoreId]),
        CONSTRAINT [FK_ReliabilityScore_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId]),
        CONSTRAINT [FK_ReliabilityScore_Engine] FOREIGN KEY ([EngineSpecId]) 
            REFERENCES [dbo].[EngineSpec]([EngineSpecId]),
        CONSTRAINT [UQ_ReliabilityScore] UNIQUE ([VehicleModelId], [EngineSpecId])
    );
    
    PRINT 'Created table: ReliabilityScore';
END
GO

-- Buyer's Guide Content
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BuyersGuide]'))
BEGIN
    CREATE TABLE [dbo].[BuyersGuide] (
        [BuyersGuideId] INT IDENTITY(1,1) NOT NULL,
        [VehicleModelId] INT NOT NULL,
        [Introduction] NVARCHAR(MAX) NULL,
        [ProsAndCons] NVARCHAR(MAX) NULL,
        [BestEngineChoice] NVARCHAR(500) NULL,
        [AvoidEngines] NVARCHAR(500) NULL,
        [IdealMileage] NVARCHAR(100) NULL,
        [PriceExpectation] NVARCHAR(200) NULL,
        [InsuranceGroup] NVARCHAR(50) NULL,
        [FuelEconomy] NVARCHAR(100) NULL,
        [LastUpdated] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_BuyersGuide] PRIMARY KEY CLUSTERED ([BuyersGuideId]),
        CONSTRAINT [FK_BuyersGuide_Vehicle] FOREIGN KEY ([VehicleModelId]) 
            REFERENCES [dbo].[VehicleModel]([VehicleModelId]),
        CONSTRAINT [UQ_BuyersGuide_Vehicle] UNIQUE ([VehicleModelId])
    );
    
    PRINT 'Created table: BuyersGuide';
END
GO

PRINT 'Schema migration completed successfully.';
GO
