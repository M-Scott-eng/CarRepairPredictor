# CarCheck Platform - Architecture Refactor

Transform from "Car Repair Cost Predictor" to comprehensive **CarCheck** platform with Parts Finder, Common Faults Database, and Buyer's Guide.

---

## 1. Updated Architecture

### Current Structure
```
CarPredictor.Api/          → HTTP endpoints
CarPredictor.Core/         → Domain models, interfaces
CarPredictor.Data/         → Database repositories
CarPredictor.External/     → External service integrations
CarPredictor.Rules/        → Prediction rule engine
CarPredictor.Services/     → Business logic
```

### New Structure
```
CarCheck.Api/                    → HTTP endpoints (renamed)
CarCheck.Core/                   → Domain models, interfaces, enums
├── Domain/
│   ├── Vehicles/                → Vehicle, Manufacturer, Engine
│   ├── Parts/                   → Part, PartListing, Supplier
│   ├── Faults/                  → Fault, Symptom, FaultReport
│   ├── Guides/                  → BuyersGuide, ChecklistItem, MotPattern
│   └── Common/                  → Region, User, Subscription
├── Interfaces/
│   ├── Repositories/            → Data access contracts
│   └── Services/                → Service contracts
└── Enums/

CarCheck.Data/                   → Database layer
├── Repositories/
├── Migrations/
└── Scripts/

CarCheck.External/               → External API integrations
├── Parts/
│   ├── EbayApi/
│   ├── AmazonApi/
│   ├── EuroCarPartsApi/
│   ├── AutodocApi/
│   └── RockAutoApi/
├── Vehicle/
│   ├── DvlaApi/                 → UK vehicle lookup
│   └── MotApi/                  → MOT history
└── Common/
    └── HttpClientFactory

CarCheck.Rules/                  → Business rules engine
├── Faults/                      → Fault probability rules
├── Reliability/                 → Reliability scoring
└── Pricing/                     → Price estimation rules

CarCheck.Services/               → Business logic
├── Parts/
│   ├── IPartsSearchService
│   ├── IPriceComparisonService
│   └── IPartMatchingService
├── Faults/
│   ├── IFaultDatabaseService
│   └── IFaultReportService
├── Guides/
│   ├── IBuyersGuideService
│   └── IMotAnalysisService
└── Vehicles/
    ├── IVehicleLookupService
    └── IVehicleSpecService

CarCheck.Workers/                → NEW: Background jobs
├── PriceRefreshWorker           → Refresh part prices
├── MotDataSyncWorker            → Sync MOT failure data
└── FaultReportAggregator        → Aggregate user fault reports
```

### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (React)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │Parts     │ │Faults    │ │Buyer's   │ │Vehicle           │   │
│  │Finder    │ │Database  │ │Guide     │ │Lookup            │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (CarCheck.Api)                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │/parts    │ │/faults   │ │/guides   │ │/vehicles         │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SERVICES (CarCheck.Services)                │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐    │
│  │PartsSearch   │ │FaultDatabase │ │BuyersGuide           │    │
│  │PriceCompare  │ │FaultReport   │ │MotAnalysis           │    │
│  │PartMatching  │ │              │ │ReliabilityScore      │    │
│  └──────────────┘ └──────────────┘ └──────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  CarCheck.Data  │ │CarCheck.External│ │ CarCheck.Rules  │
│  (SQL Server)   │ │  (APIs)         │ │ (JSON Rules)    │
│  ─────────────  │ │  ─────────────  │ │ ─────────────   │
│  • Vehicles     │ │  • eBay         │ │ • FaultRules    │
│  • Parts        │ │  • Amazon       │ │ • Reliability   │
│  • Faults       │ │  • EuroCarParts │ │ • Pricing       │
│  • Guides       │ │  • Autodoc      │ │                 │
│  • Users        │ │  • RockAuto     │ │                 │
│                 │ │  • DVLA         │ │                 │
│                 │ │  • MOT API      │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## 2. Database Schema

### New Tables

```sql
-- =====================================================
-- VEHICLE DOMAIN (extends existing)
-- =====================================================

-- Add engine specification table
CREATE TABLE EngineSpec (
    EngineSpecId INT IDENTITY(1,1) PRIMARY KEY,
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    EngineCode NVARCHAR(20) NOT NULL,
    EngineName NVARCHAR(100),
    Displacement DECIMAL(4,2),          -- e.g., 2.0
    FuelType NVARCHAR(20),              -- Petrol, Diesel, Hybrid, Electric
    Power INT,                          -- HP
    Torque INT,                         -- Nm
    YearStart INT,
    YearEnd INT,
    IsCommon BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- =====================================================
-- PARTS DOMAIN (NEW)
-- =====================================================

-- Part categories
CREATE TABLE PartCategory (
    PartCategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    ParentCategoryId INT FOREIGN KEY REFERENCES PartCategory(PartCategoryId),
    IconName NVARCHAR(50),
    DisplayOrder INT DEFAULT 0
);

-- Master parts catalog
CREATE TABLE Part (
    PartId INT IDENTITY(1,1) PRIMARY KEY,
    PartCategoryId INT NOT NULL FOREIGN KEY REFERENCES PartCategory(PartCategoryId),
    PartName NVARCHAR(200) NOT NULL,
    PartDescription NVARCHAR(MAX),
    OemPartNumber NVARCHAR(50),
    IsUniversal BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Vehicle-part compatibility
CREATE TABLE VehiclePartCompatibility (
    VehiclePartCompatibilityId INT IDENTITY(1,1) PRIMARY KEY,
    PartId INT NOT NULL FOREIGN KEY REFERENCES Part(PartId),
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    EngineSpecId INT FOREIGN KEY REFERENCES EngineSpec(EngineSpecId),
    YearStart INT,
    YearEnd INT,
    Notes NVARCHAR(500),
    UNIQUE(PartId, VehicleModelId, EngineSpecId)
);

-- External suppliers
CREATE TABLE Supplier (
    SupplierId INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    SupplierCode NVARCHAR(20) NOT NULL UNIQUE,  -- EBAY, AMAZON, EUROCAR, AUTODOC, ROCKAUTO
    WebsiteUrl NVARCHAR(500),
    ApiEndpoint NVARCHAR(500),
    LogoUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    RatingWeight DECIMAL(3,2) DEFAULT 1.0,      -- For weighted scoring
    ShippingToUk BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Cached part listings from suppliers
CREATE TABLE PartListing (
    PartListingId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PartId INT NOT NULL FOREIGN KEY REFERENCES Part(PartId),
    SupplierId INT NOT NULL FOREIGN KEY REFERENCES Supplier(SupplierId),
    ExternalId NVARCHAR(100),                   -- Supplier's listing ID
    SupplierPartNumber NVARCHAR(100),
    Title NVARCHAR(500),
    Price DECIMAL(10,2) NOT NULL,
    Currency NVARCHAR(3) DEFAULT 'GBP',
    ShippingCost DECIMAL(10,2),
    Availability NVARCHAR(50),                  -- InStock, LimitedStock, OutOfStock, PreOrder
    SellerName NVARCHAR(200),
    SellerRating DECIMAL(3,2),                  -- 0.00 - 5.00
    SellerReviewCount INT,
    Condition NVARCHAR(20),                     -- New, Refurbished, Used
    ListingUrl NVARCHAR(1000),
    ImageUrl NVARCHAR(1000),
    LastUpdated DATETIME2 DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2,
    INDEX IX_PartListing_Part (PartId),
    INDEX IX_PartListing_Supplier (SupplierId),
    INDEX IX_PartListing_Price (Price)
);

-- User part searches (for analytics)
CREATE TABLE PartSearchHistory (
    PartSearchHistoryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    VehicleModelId INT,
    EngineSpecId INT,
    SearchQuery NVARCHAR(200),
    PartCategoryId INT,
    ResultCount INT,
    SearchedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- =====================================================
-- FAULTS DOMAIN (extends existing)
-- =====================================================

-- Symptoms linked to faults
CREATE TABLE Symptom (
    SymptomId INT IDENTITY(1,1) PRIMARY KEY,
    SymptomName NVARCHAR(100) NOT NULL,
    SymptomDescription NVARCHAR(500),
    CategoryId INT FOREIGN KEY REFERENCES FailureCategory(FailureCategoryId)
);

-- Fault-symptom mapping
CREATE TABLE FaultSymptom (
    FaultSymptomId INT IDENTITY(1,1) PRIMARY KEY,
    FailurePatternId INT NOT NULL FOREIGN KEY REFERENCES FailurePattern(FailurePatternId),
    SymptomId INT NOT NULL FOREIGN KEY REFERENCES Symptom(SymptomId),
    IsCommon BIT DEFAULT 1,
    UNIQUE(FailurePatternId, SymptomId)
);

-- Community fault reports
CREATE TABLE FaultReport (
    FaultReportId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    EngineSpecId INT FOREIGN KEY REFERENCES EngineSpec(EngineSpecId),
    FailurePatternId INT FOREIGN KEY REFERENCES FailurePattern(FailurePatternId),
    VehicleYear INT,
    MileageAtFailure INT,
    Description NVARCHAR(MAX),
    RepairCost DECIMAL(10,2),
    RepairDifficulty TINYINT,                   -- 1-5 scale
    WasWarranty BIT DEFAULT 0,
    ReportedAt DATETIME2 DEFAULT GETUTCDATE(),
    IsVerified BIT DEFAULT 0,
    UpvoteCount INT DEFAULT 0,
    INDEX IX_FaultReport_Vehicle (VehicleModelId),
    INDEX IX_FaultReport_Fault (FailurePatternId)
);

-- Fault fix information
CREATE TABLE FaultFix (
    FaultFixId INT IDENTITY(1,1) PRIMARY KEY,
    FailurePatternId INT NOT NULL FOREIGN KEY REFERENCES FailurePattern(FailurePatternId),
    FixTitle NVARCHAR(200) NOT NULL,
    FixDescription NVARCHAR(MAX),
    EstimatedLabourHours DECIMAL(4,2),
    DifficultyLevel TINYINT,                    -- 1-5 (DIY to Specialist)
    RequiresSpecialistTools BIT DEFAULT 0,
    VideoUrl NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Parts needed for fixes
CREATE TABLE FaultFixPart (
    FaultFixPartId INT IDENTITY(1,1) PRIMARY KEY,
    FaultFixId INT NOT NULL FOREIGN KEY REFERENCES FaultFix(FaultFixId),
    PartId INT NOT NULL FOREIGN KEY REFERENCES Part(PartId),
    Quantity INT DEFAULT 1,
    IsOptional BIT DEFAULT 0
);

-- =====================================================
-- BUYER'S GUIDE DOMAIN (NEW)
-- =====================================================

-- Pre-purchase checklist items
CREATE TABLE ChecklistCategory (
    ChecklistCategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    DisplayOrder INT DEFAULT 0
);

CREATE TABLE ChecklistItem (
    ChecklistItemId INT IDENTITY(1,1) PRIMARY KEY,
    ChecklistCategoryId INT NOT NULL FOREIGN KEY REFERENCES ChecklistCategory(ChecklistCategoryId),
    VehicleModelId INT FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),  -- NULL = universal
    ItemTitle NVARCHAR(200) NOT NULL,
    ItemDescription NVARCHAR(MAX),
    WhyImportant NVARCHAR(500),
    HowToCheck NVARCHAR(MAX),
    RedFlags NVARCHAR(500),
    EstimatedRepairCost NVARCHAR(100),
    Severity TINYINT,                           -- 1=Minor, 2=Moderate, 3=Major, 4=Critical
    DisplayOrder INT DEFAULT 0
);

-- MOT failure patterns (UK specific)
CREATE TABLE MotDefectCategory (
    MotDefectCategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(10) NOT NULL,         -- e.g., "5.3" for suspension
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryId INT FOREIGN KEY REFERENCES MotDefectCategory(MotDefectCategoryId)
);

CREATE TABLE MotFailurePattern (
    MotFailurePatternId INT IDENTITY(1,1) PRIMARY KEY,
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    MotDefectCategoryId INT NOT NULL FOREIGN KEY REFERENCES MotDefectCategory(MotDefectCategoryId),
    DefectDescription NVARCHAR(500),
    FailureRate DECIMAL(5,2),                   -- Percentage
    AvgMileageAtFailure INT,
    SampleSize INT,
    DataYear INT,
    INDEX IX_MotPattern_Vehicle (VehicleModelId)
);

-- Reliability scores (aggregated)
CREATE TABLE ReliabilityScore (
    ReliabilityScoreId INT IDENTITY(1,1) PRIMARY KEY,
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    EngineSpecId INT FOREIGN KEY REFERENCES EngineSpec(EngineSpecId),
    OverallScore DECIMAL(4,2),                  -- 0-100
    EngineScore DECIMAL(4,2),
    TransmissionScore DECIMAL(4,2),
    ElectricalScore DECIMAL(4,2),
    SuspensionScore DECIMAL(4,2),
    BodyCorrosionScore DECIMAL(4,2),
    RunningCostScore DECIMAL(4,2),
    MotPassRate DECIMAL(5,2),                   -- Percentage
    AverageRepairCost DECIMAL(10,2),
    SampleSize INT,
    CalculatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UNIQUE(VehicleModelId, EngineSpecId)
);

-- Buyer's guide content
CREATE TABLE BuyersGuide (
    BuyersGuideId INT IDENTITY(1,1) PRIMARY KEY,
    VehicleModelId INT NOT NULL FOREIGN KEY REFERENCES VehicleModel(VehicleModelId),
    Introduction NVARCHAR(MAX),
    ProsAndCons NVARCHAR(MAX),                  -- JSON: {pros: [], cons: []}
    BestEngineChoice NVARCHAR(500),
    AvoidEngines NVARCHAR(500),
    IdealMileage NVARCHAR(100),
    PriceExpectation NVARCHAR(200),
    InsuranceGroup NVARCHAR(50),
    FuelEconomy NVARCHAR(100),
    LastUpdated DATETIME2 DEFAULT GETUTCDATE(),
    UNIQUE(VehicleModelId)
);
```

---

## 3. API Endpoints

### Parts Finder API

```
POST   /api/v1/parts/search
       Body: { vehicleId, engineSpecId, partCategoryId?, query? }
       → Returns aggregated listings from all suppliers

GET    /api/v1/parts/compare/{partId}
       → Price comparison across suppliers

GET    /api/v1/parts/categories
       → Part category tree

GET    /api/v1/parts/vehicle/{vehicleId}/compatible
       → All compatible parts for a vehicle

GET    /api/v1/parts/popular
       → Most searched parts

POST   /api/v1/parts/alert
       Body: { partId, targetPrice, email }
       → Price drop notification signup
```

### Common Faults API

```
GET    /api/v1/faults/vehicle/{vehicleId}
       Query: ?engineSpecId=&minMileage=&category=
       → Known faults for vehicle

GET    /api/v1/faults/{faultId}
       → Fault detail with symptoms, fixes, parts

GET    /api/v1/faults/{faultId}/reports
       → Community reports for this fault

POST   /api/v1/faults/report
       Body: { vehicleId, faultId?, description, mileage, cost }
       → Submit fault report

GET    /api/v1/faults/search
       Query: ?symptoms=&category=&vehicleId=
       → Search by symptoms

GET    /api/v1/faults/trending
       → Recently reported faults (community)
```

### Buyer's Guide API

```
GET    /api/v1/guides/vehicle/{vehicleId}
       → Full buyer's guide

GET    /api/v1/guides/vehicle/{vehicleId}/checklist
       → Pre-purchase checklist

GET    /api/v1/guides/vehicle/{vehicleId}/mot-patterns
       → MOT failure analysis

GET    /api/v1/guides/vehicle/{vehicleId}/reliability
       → Reliability scores breakdown

GET    /api/v1/guides/compare
       Query: ?vehicleIds=1,2,3
       → Compare reliability of multiple vehicles

GET    /api/v1/guides/best-in-class
       Query: ?category=suv&budget=15000&year=2015
       → Recommendations
```

### Vehicle API (enhanced)

```
GET    /api/v1/vehicles/lookup/{registration}
       → DVLA lookup (UK reg)

GET    /api/v1/vehicles/{vehicleId}/specs
       → Full specifications

GET    /api/v1/vehicles/{vehicleId}/engines
       → Available engine options

GET    /api/v1/vehicles/{vehicleId}/mot-history/{registration}
       → MOT test history
```

---

## 4. New Services & Data Models

### Domain Models

```csharp
// Parts Domain
public record Part(
    int PartId,
    string PartName,
    string? OemPartNumber,
    int PartCategoryId,
    string CategoryName,
    bool IsUniversal);

public record PartListing(
    long PartListingId,
    int PartId,
    int SupplierId,
    string SupplierName,
    string? SupplierPartNumber,
    string Title,
    decimal Price,
    decimal? ShippingCost,
    decimal TotalPrice,
    string Availability,
    string? SellerName,
    decimal? SellerRating,
    int? SellerReviewCount,
    string? Condition,
    string ListingUrl,
    string? ImageUrl,
    DateTime LastUpdated);

public record PartSearchResult(
    Part Part,
    IReadOnlyList<PartListing> Listings,
    decimal LowestPrice,
    decimal AveragePrice,
    int SupplierCount);

// Faults Domain
public record Fault(
    int FaultId,
    string FaultName,
    string Description,
    string Category,
    int? MinMileage,
    int? MaxMileage,
    int PeakMileage,
    decimal Probability,
    int Severity,
    IReadOnlyList<string> Symptoms,
    IReadOnlyList<FaultFix> Fixes);

public record FaultFix(
    int FaultFixId,
    string Title,
    string Description,
    decimal? LabourHours,
    int DifficultyLevel,
    string? VideoUrl,
    IReadOnlyList<PartRequirement> RequiredParts);

public record FaultReport(
    long ReportId,
    int VehicleModelId,
    int? FaultId,
    int VehicleYear,
    int MileageAtFailure,
    string Description,
    decimal? RepairCost,
    int RepairDifficulty,
    DateTime ReportedAt,
    int UpvoteCount);

// Buyer's Guide Domain
public record BuyersGuide(
    int VehicleModelId,
    string ModelName,
    ReliabilityScore Reliability,
    IReadOnlyList<ChecklistItem> Checklist,
    IReadOnlyList<MotFailurePattern> MotPatterns,
    IReadOnlyList<string> Pros,
    IReadOnlyList<string> Cons,
    string? BestEngineChoice,
    string? EngineToAvoid,
    string? IdealMileageRange,
    string? PriceExpectation);

public record ReliabilityScore(
    decimal OverallScore,
    decimal EngineScore,
    decimal TransmissionScore,
    decimal ElectricalScore,
    decimal SuspensionScore,
    decimal BodyScore,
    decimal RunningCostScore,
    decimal MotPassRate,
    string Grade);  // A, B, C, D, F

public record MotFailurePattern(
    string CategoryCode,
    string CategoryName,
    string Description,
    decimal FailureRate,
    int? AvgMileageAtFailure);
```

### Service Interfaces

```csharp
// Parts Services
public interface IPartsSearchService
{
    Task<PartSearchResult> SearchPartsAsync(PartsSearchRequest request);
    Task<IReadOnlyList<PartListing>> GetPriceComparisonAsync(int partId);
    Task<IReadOnlyList<Part>> GetCompatiblePartsAsync(int vehicleId, int? engineSpecId);
}

public interface IPartSupplierAdapter
{
    string SupplierCode { get; }
    Task<IReadOnlyList<PartListing>> SearchAsync(PartSearchQuery query);
    Task<PartListing?> GetListingAsync(string externalId);
}

// Fault Services
public interface IFaultDatabaseService
{
    Task<IReadOnlyList<Fault>> GetFaultsForVehicleAsync(int vehicleId, FaultFilter? filter);
    Task<Fault?> GetFaultDetailAsync(int faultId);
    Task<IReadOnlyList<Fault>> SearchBySymptoms(IEnumerable<int> symptomIds);
}

public interface IFaultReportService
{
    Task<long> SubmitReportAsync(FaultReportSubmission report);
    Task<IReadOnlyList<FaultReport>> GetReportsAsync(int faultId, int page, int pageSize);
    Task UpvoteReportAsync(long reportId);
}

// Buyer's Guide Services
public interface IBuyersGuideService
{
    Task<BuyersGuide> GetGuideAsync(int vehicleId);
    Task<IReadOnlyList<ChecklistItem>> GetChecklistAsync(int vehicleId);
    Task<VehicleComparison> CompareVehiclesAsync(IEnumerable<int> vehicleIds);
}

public interface IMotAnalysisService
{
    Task<IReadOnlyList<MotFailurePattern>> GetFailurePatternsAsync(int vehicleId);
    Task<MotHistory> GetVehicleMotHistoryAsync(string registration);
    Task RefreshMotDataAsync(int vehicleId);
}

public interface IReliabilityScoreService
{
    Task<ReliabilityScore> CalculateScoreAsync(int vehicleId, int? engineSpecId);
    Task RefreshScoresAsync(int vehicleId);
}
```

---

## 5. External API Integrations

### Supplier Adapters

```csharp
// Base adapter interface
public interface IPartSupplierAdapter
{
    string SupplierCode { get; }
    int Priority { get; }
    Task<IReadOnlyList<PartListing>> SearchAsync(PartSearchQuery query, CancellationToken ct);
}

// Implementations needed:
// - EbayPartAdapter        → eBay Finding/Browse API
// - AmazonPartAdapter      → Amazon Product Advertising API
// - EuroCarPartsAdapter    → Web scraping or partner API
// - AutodocAdapter         → Autodoc affiliate API
// - RockAutoAdapter        → Web scraping or data feed
```

### UK Government APIs

```csharp
// DVLA Vehicle Enquiry Service
public interface IDvlaService
{
    Task<VehicleDetails?> LookupAsync(string registration);
}

// MOT History API
public interface IMotHistoryService
{
    Task<MotHistory> GetHistoryAsync(string registration);
    Task<IReadOnlyList<MotTestResult>> GetTestsAsync(string registration);
}
```

---

## 6. Migration Plan

### Phase 1: Database Migration (Week 1-2)

1. **Create new tables** alongside existing ones
2. **Add foreign keys** carefully to not break existing data
3. **Migrate existing data**:
   - Map `FailurePattern` → new fault tables
   - Generate initial `ReliabilityScore` from rule engine data
   - Create default `ChecklistItem` entries

```sql
-- Example: Migrate failure patterns to include symptoms
INSERT INTO Symptom (SymptomName, CategoryId)
SELECT DISTINCT 'Generic symptom', FailureCategoryId
FROM FailurePattern;

-- Populate reliability scores from existing rule data
INSERT INTO ReliabilityScore (VehicleModelId, OverallScore, EngineScore, ...)
SELECT 
    vm.VehicleModelId,
    100 - (AVG(fp.BaseProbability) * 100),
    ...
FROM VehicleModel vm
LEFT JOIN FailurePattern fp ON vm.VehicleModelId = fp.VehicleModelId
GROUP BY vm.VehicleModelId;
```

### Phase 2: Core Refactor (Week 2-3)

1. **Rename projects** (optional) or create parallel structure
2. **Move interfaces** to new locations
3. **Create new domain models**
4. **Update existing services** to use new models

### Phase 3: Parts Feature (Week 3-4)

1. **Implement supplier adapters** (start with 2-3)
2. **Build parts search service**
3. **Create caching layer** for listings
4. **Add parts API endpoints**
5. **Build frontend components**

### Phase 4: Faults Enhancement (Week 4-5)

1. **Enhance fault models** with symptoms, fixes
2. **Implement community reporting**
3. **Add symptom search**
4. **Update frontend fault display**

### Phase 5: Buyer's Guide (Week 5-6)

1. **Implement MOT analysis service**
2. **Build reliability scoring**
3. **Create checklist system**
4. **Integrate with frontend**

### Phase 6: Polish & Launch (Week 6-7)

1. **Performance optimization**
2. **Add more suppliers**
3. **Seed more vehicle data**
4. **User testing**
5. **Documentation**

---

## 7. Configuration Changes

### appsettings.json additions

```json
{
  "ExternalApis": {
    "Ebay": {
      "AppId": "",
      "CertId": "",
      "DevId": "",
      "Sandbox": false,
      "MarketplaceId": "EBAY_GB"
    },
    "Amazon": {
      "AccessKey": "",
      "SecretKey": "",
      "PartnerTag": "",
      "Region": "eu-west-1"
    },
    "Dvla": {
      "ApiKey": "",
      "BaseUrl": "https://driver-vehicle-licensing.api.gov.uk"
    },
    "MotHistory": {
      "ApiKey": "",
      "BaseUrl": "https://beta.check-mot.service.gov.uk"
    }
  },
  "Caching": {
    "PartListingTtlMinutes": 60,
    "SupplierSearchTtlMinutes": 15,
    "ReliabilityScoreTtlHours": 24
  },
  "Features": {
    "PartsFinderEnabled": true,
    "CommunityReportsEnabled": true,
    "MotLookupEnabled": true
  }
}
```

---

## 8. Folder Structure After Refactor

```
CarCheck/
├── src/
│   ├── CarCheck.Api/
│   │   ├── Controllers/
│   │   │   ├── PartsController.cs
│   │   │   ├── FaultsController.cs
│   │   │   ├── GuidesController.cs
│   │   │   ├── VehiclesController.cs
│   │   │   └── ...
│   │   ├── DTOs/
│   │   │   ├── Parts/
│   │   │   ├── Faults/
│   │   │   └── Guides/
│   │   └── ...
│   │
│   ├── CarCheck.Core/
│   │   ├── Domain/
│   │   │   ├── Parts/
│   │   │   ├── Faults/
│   │   │   ├── Guides/
│   │   │   └── Vehicles/
│   │   ├── Interfaces/
│   │   │   ├── Repositories/
│   │   │   └── Services/
│   │   └── Enums/
│   │
│   ├── CarCheck.Services/
│   │   ├── Parts/
│   │   │   ├── PartsSearchService.cs
│   │   │   ├── PriceComparisonService.cs
│   │   │   └── PartMatchingService.cs
│   │   ├── Faults/
│   │   │   ├── FaultDatabaseService.cs
│   │   │   └── FaultReportService.cs
│   │   └── Guides/
│   │       ├── BuyersGuideService.cs
│   │       ├── MotAnalysisService.cs
│   │       └── ReliabilityScoreService.cs
│   │
│   ├── CarCheck.External/
│   │   ├── Parts/
│   │   │   ├── Adapters/
│   │   │   │   ├── EbayAdapter.cs
│   │   │   │   ├── AmazonAdapter.cs
│   │   │   │   └── ...
│   │   │   └── IPartSupplierAdapter.cs
│   │   └── Uk/
│   │       ├── DvlaService.cs
│   │       └── MotHistoryService.cs
│   │
│   ├── CarCheck.Data/
│   │   ├── Repositories/
│   │   ├── Migrations/
│   │   └── Scripts/
│   │
│   └── CarCheck.Rules/
│       ├── Faults/
│       ├── Reliability/
│       └── RuleData/
│
├── frontend/
│   └── src/
│       ├── pages/
│       │   ├── PartsFinderPage.tsx
│       │   ├── FaultDatabasePage.tsx
│       │   ├── BuyersGuidePage.tsx
│       │   └── ...
│       └── components/
│           ├── parts/
│           ├── faults/
│           └── guides/
│
├── tests/
└── docs/
```

---

## Summary

| Feature | Status | New Tables | New Endpoints | Priority |
|---------|--------|------------|---------------|----------|
| Parts Finder | New | 6 | 6 | High |
| Common Faults | Enhanced | 4 | 6 | High |
| Buyer's Guide | New | 5 | 6 | Medium |
| MOT Analysis | New | 2 | 2 | Medium |
| Community Reports | New | 1 | 3 | Low |

**Total new tables**: 18  
**Total new endpoints**: 23  
**Estimated effort**: 6-7 weeks
