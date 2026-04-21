-- =============================================
-- Script: 002_CreateStoredProcedures.sql
-- Description: Creates all stored procedures for the Car Repair Predictor database
-- =============================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Manufacturer Stored Procedures
-- =============================================

IF OBJECT_ID('dbo.sp_GetAllManufacturers', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAllManufacturers;
GO

CREATE PROCEDURE dbo.sp_GetAllManufacturers
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        ManufacturerId,
        ManufacturerName,
        CountryOfOrigin
    FROM dbo.Manufacturer
    ORDER BY ManufacturerName;
END
GO

IF OBJECT_ID('dbo.sp_GetManufacturerById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetManufacturerById;
GO

CREATE PROCEDURE dbo.sp_GetManufacturerById
    @ManufacturerId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        ManufacturerId,
        ManufacturerName,
        CountryOfOrigin
    FROM dbo.Manufacturer
    WHERE ManufacturerId = @ManufacturerId;
END
GO

-- =============================================
-- VehicleModel Stored Procedures
-- =============================================

IF OBJECT_ID('dbo.sp_GetVehicleModelsByManufacturer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetVehicleModelsByManufacturer;
GO

CREATE PROCEDURE dbo.sp_GetVehicleModelsByManufacturer
    @ManufacturerId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        vm.VehicleModelId,
        vm.ManufacturerId,
        vm.ModelName,
        vm.YearStart,
        vm.YearEnd,
        vm.EngineTypes,
        m.ManufacturerName
    FROM dbo.VehicleModel vm
    INNER JOIN dbo.Manufacturer m ON vm.ManufacturerId = m.ManufacturerId
    WHERE vm.ManufacturerId = @ManufacturerId
    ORDER BY vm.ModelName;
END
GO

IF OBJECT_ID('dbo.sp_GetVehicleModelById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetVehicleModelById;
GO

CREATE PROCEDURE dbo.sp_GetVehicleModelById
    @VehicleModelId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        vm.VehicleModelId,
        vm.ManufacturerId,
        vm.ModelName,
        vm.YearStart,
        vm.YearEnd,
        vm.EngineTypes,
        m.ManufacturerName
    FROM dbo.VehicleModel vm
    INNER JOIN dbo.Manufacturer m ON vm.ManufacturerId = m.ManufacturerId
    WHERE vm.VehicleModelId = @VehicleModelId;
END
GO

IF OBJECT_ID('dbo.sp_GetAvailableYearsForModel', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAvailableYearsForModel;
GO

CREATE PROCEDURE dbo.sp_GetAvailableYearsForModel
    @VehicleModelId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @YearStart INT, @YearEnd INT;

    SELECT 
        @YearStart = YearStart,
        @YearEnd = ISNULL(YearEnd, YEAR(GETDATE()))
    FROM dbo.VehicleModel
    WHERE VehicleModelId = @VehicleModelId;

    -- Generate list of years between YearStart and YearEnd
    ;WITH YearsCTE AS (
        SELECT @YearStart AS [Year]
        UNION ALL
        SELECT [Year] + 1
        FROM YearsCTE
        WHERE [Year] < @YearEnd
    )
    SELECT [Year]
    FROM YearsCTE
    ORDER BY [Year] DESC
    OPTION (MAXRECURSION 100);
END
GO

-- =============================================
-- FailurePattern Stored Procedures
-- =============================================

IF OBJECT_ID('dbo.sp_GetFailurePatternsByVehicleModel', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFailurePatternsByVehicleModel;
GO

CREATE PROCEDURE dbo.sp_GetFailurePatternsByVehicleModel
    @VehicleModelId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        fp.FailurePatternId,
        fp.VehicleModelId,
        fp.FailureCategoryId,
        fp.FailureName,
        fp.[Description],
        fp.MinMileage,
        fp.MaxMileage,
        fp.MinAge,
        fp.MaxAge,
        fp.BaseProbability,
        fp.SeverityLevel,
        fp.IsCommon,
        fp.DataSource,
        fc.CategoryName
    FROM dbo.FailurePattern fp
    INNER JOIN dbo.FailureCategory fc ON fp.FailureCategoryId = fc.FailureCategoryId
    WHERE fp.VehicleModelId = @VehicleModelId
    ORDER BY fp.BaseProbability DESC, fp.SeverityLevel DESC;
END
GO

IF OBJECT_ID('dbo.sp_GetApplicableFailurePatterns', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetApplicableFailurePatterns;
GO

CREATE PROCEDURE dbo.sp_GetApplicableFailurePatterns
    @VehicleModelId INT,
    @Mileage INT,
    @VehicleAge INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        fp.FailurePatternId,
        fp.VehicleModelId,
        fp.FailureCategoryId,
        fp.FailureName,
        fp.[Description],
        fp.MinMileage,
        fp.MaxMileage,
        fp.MinAge,
        fp.MaxAge,
        fp.BaseProbability,
        fp.SeverityLevel,
        fp.IsCommon,
        fp.DataSource,
        fc.CategoryName
    FROM dbo.FailurePattern fp
    INNER JOIN dbo.FailureCategory fc ON fp.FailureCategoryId = fc.FailureCategoryId
    WHERE fp.VehicleModelId = @VehicleModelId
      AND (fp.MinMileage IS NULL OR @Mileage >= fp.MinMileage)
      AND (fp.MaxMileage IS NULL OR @Mileage <= fp.MaxMileage)
      AND (fp.MinAge IS NULL OR @VehicleAge >= fp.MinAge)
      AND (fp.MaxAge IS NULL OR @VehicleAge <= fp.MaxAge)
    ORDER BY fp.BaseProbability DESC, fp.SeverityLevel DESC;
END
GO

-- =============================================
-- RepairCost Stored Procedures
-- =============================================

IF OBJECT_ID('dbo.sp_GetRepairCostsByFailurePatterns', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetRepairCostsByFailurePatterns;
GO

CREATE PROCEDURE dbo.sp_GetRepairCostsByFailurePatterns
    @FailurePatternIds dbo.IntIdList READONLY,
    @RegionId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        rc.RepairCostId,
        rc.FailurePatternId,
        rc.RegionId,
        rc.MinCost,
        rc.MaxCost,
        rc.AverageCost,
        rc.LabourHours,
        rc.PartsOnlyCost,
        rc.EffectiveFrom,
        rc.EffectiveTo
    FROM dbo.RepairCost rc
    INNER JOIN @FailurePatternIds fp ON rc.FailurePatternId = fp.Id
    WHERE rc.RegionId = @RegionId
      AND rc.EffectiveFrom <= CAST(GETDATE() AS DATE)
      AND (rc.EffectiveTo IS NULL OR rc.EffectiveTo >= CAST(GETDATE() AS DATE));
END
GO

-- =============================================
-- Region Stored Procedures
-- =============================================

IF OBJECT_ID('dbo.sp_GetActiveRegions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetActiveRegions;
GO

CREATE PROCEDURE dbo.sp_GetActiveRegions
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        RegionId,
        RegionCode,
        RegionName,
        CurrencyCode,
        IsActive
    FROM dbo.Region
    WHERE IsActive = 1
    ORDER BY RegionName;
END
GO

IF OBJECT_ID('dbo.sp_GetRegionByCode', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetRegionByCode;
GO

CREATE PROCEDURE dbo.sp_GetRegionByCode
    @RegionCode NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        RegionId,
        RegionCode,
        RegionName,
        CurrencyCode,
        IsActive
    FROM dbo.Region
    WHERE RegionCode = @RegionCode;
END
GO

PRINT 'Stored procedures created successfully.';
GO
