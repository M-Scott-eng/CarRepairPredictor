-- =====================================================
-- CarCheck Platform - Monetisation Schema
-- Subscriptions, Purchases, Usage Tracking
-- =====================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =====================================================
-- 1. USERS - Core user accounts
-- =====================================================
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        Email NVARCHAR(255) NOT NULL,
        PasswordHash NVARCHAR(255),           -- NULL for OAuth-only users
        DisplayName NVARCHAR(100),
        StripeCustomerId NVARCHAR(100),       -- Stripe customer ID
        EmailVerified BIT NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        LastLoginAt DATETIME2,
        
        CONSTRAINT UQ_Users_Email UNIQUE (Email)
    );

    CREATE NONCLUSTERED INDEX IX_Users_StripeCustomer ON dbo.Users(StripeCustomerId) WHERE StripeCustomerId IS NOT NULL;
    CREATE NONCLUSTERED INDEX IX_Users_Email ON dbo.Users(Email);
END
GO

-- =====================================================
-- 2. SUBSCRIPTION_PLANS - Available plans
-- =====================================================
IF OBJECT_ID('dbo.SubscriptionPlans', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SubscriptionPlans (
        PlanId INT IDENTITY(1,1) PRIMARY KEY,
        PlanCode NVARCHAR(50) NOT NULL,       -- 'free', 'premium_monthly', 'premium_annual'
        PlanName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        PriceGbp DECIMAL(10,2) NOT NULL,      -- Monthly price
        BillingPeriod NVARCHAR(20) NOT NULL,  -- 'month', 'year', 'one_time'
        StripePriceId NVARCHAR(100),          -- Stripe price ID
        SearchesPerMonth INT,                  -- NULL = unlimited
        ReportsIncluded INT NOT NULL DEFAULT 0,
        ShowAds BIT NOT NULL DEFAULT 1,
        Features NVARCHAR(MAX),               -- JSON array of feature strings
        IsActive BIT NOT NULL DEFAULT 1,
        DisplayOrder INT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT UQ_SubscriptionPlans_Code UNIQUE (PlanCode)
    );
END
GO

-- Seed subscription plans
IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionPlans WHERE PlanCode = 'free')
BEGIN
    INSERT INTO dbo.SubscriptionPlans (PlanCode, PlanName, Description, PriceGbp, BillingPeriod, SearchesPerMonth, ReportsIncluded, ShowAds, Features, DisplayOrder)
    VALUES 
    ('free', 'Free', 'Basic access with ads', 0.00, 'month', 5, 0, 1, 
     '["5 parts searches per month","Price comparison across 4 suppliers","Common faults database","Basic buyer''s guide","Ads shown"]', 1),
    
    ('premium_monthly', 'Premium Monthly', 'Full access, billed monthly', 4.99, 'month', NULL, 3, 0,
     '["Unlimited parts searches","Price comparison across 4 suppliers","Full common faults database","Detailed buyer''s guides","3 premium reports/month","No ads","Price alerts","Save searches"]', 2),
    
    ('premium_annual', 'Premium Annual', 'Full access, billed yearly (save 33%)', 39.99, 'year', NULL, 36, 0,
     '["Unlimited parts searches","Price comparison across 4 suppliers","Full common faults database","Detailed buyer''s guides","36 premium reports/year","No ads","Price alerts","Save searches","Priority support"]', 3);
END
GO

-- =====================================================
-- 3. USER_SUBSCRIPTIONS - Active subscriptions
-- =====================================================
IF OBJECT_ID('dbo.UserSubscriptions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserSubscriptions (
        SubscriptionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        UserId UNIQUEIDENTIFIER NOT NULL,
        PlanId INT NOT NULL,
        StripeSubscriptionId NVARCHAR(100),
        Status NVARCHAR(20) NOT NULL,         -- 'active', 'cancelled', 'past_due', 'trialing'
        CurrentPeriodStart DATETIME2 NOT NULL,
        CurrentPeriodEnd DATETIME2 NOT NULL,
        CancelAtPeriodEnd BIT NOT NULL DEFAULT 0,
        CancelledAt DATETIME2,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_UserSubscriptions_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_UserSubscriptions_Plan FOREIGN KEY (PlanId) REFERENCES dbo.SubscriptionPlans(PlanId)
    );

    CREATE NONCLUSTERED INDEX IX_UserSubscriptions_User ON dbo.UserSubscriptions(UserId, Status);
    CREATE NONCLUSTERED INDEX IX_UserSubscriptions_Stripe ON dbo.UserSubscriptions(StripeSubscriptionId) WHERE StripeSubscriptionId IS NOT NULL;
END
GO

-- =====================================================
-- 4. PURCHASES - One-time purchases (reports)
-- =====================================================
IF OBJECT_ID('dbo.Purchases', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Purchases (
        PurchaseId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        UserId UNIQUEIDENTIFIER NOT NULL,
        ProductType NVARCHAR(50) NOT NULL,    -- 'buyers_report', 'fault_report', 'price_alert'
        ProductId NVARCHAR(100),              -- Reference to the specific product
        PriceGbp DECIMAL(10,2) NOT NULL,
        StripePaymentIntentId NVARCHAR(100),
        StripeSessionId NVARCHAR(100),
        Status NVARCHAR(20) NOT NULL,         -- 'pending', 'completed', 'refunded', 'failed'
        Metadata NVARCHAR(MAX),               -- JSON with make/model/year etc
        CompletedAt DATETIME2,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_Purchases_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );

    CREATE NONCLUSTERED INDEX IX_Purchases_User ON dbo.Purchases(UserId, CreatedAt DESC);
    CREATE NONCLUSTERED INDEX IX_Purchases_Stripe ON dbo.Purchases(StripePaymentIntentId) WHERE StripePaymentIntentId IS NOT NULL;
END
GO

-- =====================================================
-- 5. USAGE_TRACKING - Track searches and actions
-- =====================================================
IF OBJECT_ID('dbo.UsageTracking', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsageTracking (
        TrackingId BIGINT IDENTITY(1,1) PRIMARY KEY,
        UserId UNIQUEIDENTIFIER,              -- NULL for anonymous users
        SessionId NVARCHAR(100),              -- Anonymous session tracking
        ActionType NVARCHAR(50) NOT NULL,     -- 'parts_search', 'fault_view', 'guide_view', 'report_download'
        ActionData NVARCHAR(MAX),             -- JSON with search params etc
        IpAddress NVARCHAR(50),
        UserAgent NVARCHAR(500),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_UsageTracking_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );

    CREATE NONCLUSTERED INDEX IX_UsageTracking_User ON dbo.UsageTracking(UserId, ActionType, CreatedAt DESC) WHERE UserId IS NOT NULL;
    CREATE NONCLUSTERED INDEX IX_UsageTracking_Session ON dbo.UsageTracking(SessionId, CreatedAt DESC) WHERE SessionId IS NOT NULL;
    CREATE NONCLUSTERED INDEX IX_UsageTracking_Date ON dbo.UsageTracking(CreatedAt) INCLUDE (ActionType);
END
GO

-- =====================================================
-- 6. AFFILIATE_CLICKS - Track affiliate link clicks
-- =====================================================
IF OBJECT_ID('dbo.AffiliateClicks', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AffiliateClicks (
        ClickId BIGINT IDENTITY(1,1) PRIMARY KEY,
        UserId UNIQUEIDENTIFIER,
        SessionId NVARCHAR(100),
        SupplierId NVARCHAR(50) NOT NULL,     -- 'ebay', 'amazon', 'autodoc', 'rockauto'
        ProductUrl NVARCHAR(2000) NOT NULL,
        AffiliateUrl NVARCHAR(2000) NOT NULL,
        PartTitle NVARCHAR(500),
        PartPrice DECIMAL(10,2),
        SearchQuery NVARCHAR(200),
        Make NVARCHAR(50),
        Model NVARCHAR(100),
        Year INT,
        IpAddress NVARCHAR(50),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_AffiliateClicks_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );

    CREATE NONCLUSTERED INDEX IX_AffiliateClicks_Supplier ON dbo.AffiliateClicks(SupplierId, CreatedAt DESC);
    CREATE NONCLUSTERED INDEX IX_AffiliateClicks_Date ON dbo.AffiliateClicks(CreatedAt) INCLUDE (SupplierId);
END
GO

-- =====================================================
-- 7. PREMIUM_REPORTS - Generated buyer's reports
-- =====================================================
IF OBJECT_ID('dbo.PremiumReports', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PremiumReports (
        ReportId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        UserId UNIQUEIDENTIFIER NOT NULL,
        PurchaseId UNIQUEIDENTIFIER,          -- NULL if from subscription allowance
        Make NVARCHAR(50) NOT NULL,
        Model NVARCHAR(100) NOT NULL,
        Year INT,
        EngineCode NVARCHAR(20),
        ReportType NVARCHAR(50) NOT NULL,     -- 'full_buyers_guide', 'fault_analysis', 'price_comparison'
        ReportData NVARCHAR(MAX) NOT NULL,    -- JSON report content
        PdfUrl NVARCHAR(500),                 -- Generated PDF storage URL
        ExpiresAt DATETIME2,                  -- Report might expire after X days
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_PremiumReports_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_PremiumReports_Purchase FOREIGN KEY (PurchaseId) REFERENCES dbo.Purchases(PurchaseId)
    );

    CREATE NONCLUSTERED INDEX IX_PremiumReports_User ON dbo.PremiumReports(UserId, CreatedAt DESC);
END
GO

-- =====================================================
-- 8. SAVED_SEARCHES - User saved searches
-- =====================================================
IF OBJECT_ID('dbo.SavedSearches', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SavedSearches (
        SavedSearchId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        UserId UNIQUEIDENTIFIER NOT NULL,
        SearchName NVARCHAR(100),
        Make NVARCHAR(50) NOT NULL,
        Model NVARCHAR(100) NOT NULL,
        Year INT,
        EngineCode NVARCHAR(20),
        PartCategory NVARCHAR(100),
        SearchQuery NVARCHAR(200),
        EnablePriceAlerts BIT NOT NULL DEFAULT 0,
        TargetPrice DECIMAL(10,2),
        LastAlertSentAt DATETIME2,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_SavedSearches_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );

    CREATE NONCLUSTERED INDEX IX_SavedSearches_User ON dbo.SavedSearches(UserId);
    CREATE NONCLUSTERED INDEX IX_SavedSearches_Alerts ON dbo.SavedSearches(EnablePriceAlerts) WHERE EnablePriceAlerts = 1;
END
GO

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Get user's current subscription status
IF OBJECT_ID('dbo.sp_GetUserSubscription', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserSubscription;
GO
CREATE PROCEDURE dbo.sp_GetUserSubscription
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        u.UserId,
        u.Email,
        u.StripeCustomerId,
        COALESCE(us.Status, 'none') AS SubscriptionStatus,
        COALESCE(sp.PlanCode, 'free') AS PlanCode,
        sp.PlanName,
        sp.SearchesPerMonth,
        sp.ReportsIncluded,
        sp.ShowAds,
        us.CurrentPeriodEnd,
        us.CancelAtPeriodEnd
    FROM dbo.Users u
    LEFT JOIN dbo.UserSubscriptions us ON u.UserId = us.UserId AND us.Status IN ('active', 'trialing')
    LEFT JOIN dbo.SubscriptionPlans sp ON us.PlanId = sp.PlanId
    WHERE u.UserId = @UserId;
END
GO

-- Get user's usage for current period
IF OBJECT_ID('dbo.sp_GetUserUsage', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserUsage;
GO
CREATE PROCEDURE dbo.sp_GetUserUsage
    @UserId UNIQUEIDENTIFIER,
    @SessionId NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PeriodStart DATETIME2 = DATEADD(DAY, 1-DAY(GETUTCDATE()), CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME2));

    SELECT 
        COUNT(CASE WHEN ActionType = 'parts_search' THEN 1 END) AS PartsSearches,
        COUNT(CASE WHEN ActionType = 'fault_view' THEN 1 END) AS FaultViews,
        COUNT(CASE WHEN ActionType = 'guide_view' THEN 1 END) AS GuideViews,
        COUNT(CASE WHEN ActionType = 'report_download' THEN 1 END) AS ReportsDownloaded
    FROM dbo.UsageTracking
    WHERE (UserId = @UserId OR (@UserId IS NULL AND SessionId = @SessionId))
      AND CreatedAt >= @PeriodStart;
END
GO

-- Track usage
IF OBJECT_ID('dbo.sp_TrackUsage', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_TrackUsage;
GO
CREATE PROCEDURE dbo.sp_TrackUsage
    @UserId UNIQUEIDENTIFIER = NULL,
    @SessionId NVARCHAR(100) = NULL,
    @ActionType NVARCHAR(50),
    @ActionData NVARCHAR(MAX) = NULL,
    @IpAddress NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    INSERT INTO dbo.UsageTracking (UserId, SessionId, ActionType, ActionData, IpAddress, UserAgent)
    VALUES (@UserId, @SessionId, @ActionType, @ActionData, @IpAddress, @UserAgent);
END
GO

-- Check if user can perform action (usage limits)
IF OBJECT_ID('dbo.sp_CanUserPerformAction', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CanUserPerformAction;
GO
CREATE PROCEDURE dbo.sp_CanUserPerformAction
    @UserId UNIQUEIDENTIFIER = NULL,
    @SessionId NVARCHAR(100) = NULL,
    @ActionType NVARCHAR(50),
    @CanPerform BIT OUTPUT,
    @Message NVARCHAR(200) OUTPUT,
    @RemainingCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PeriodStart DATETIME2 = DATEADD(DAY, 1-DAY(GETUTCDATE()), CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME2));
    DECLARE @Limit INT;
    DECLARE @CurrentCount INT;

    -- Get user's plan limits
    SELECT @Limit = COALESCE(sp.SearchesPerMonth, 999999)
    FROM dbo.Users u
    LEFT JOIN dbo.UserSubscriptions us ON u.UserId = us.UserId AND us.Status IN ('active', 'trialing')
    LEFT JOIN dbo.SubscriptionPlans sp ON us.PlanId = sp.PlanId
    WHERE u.UserId = @UserId;

    -- Default to free tier limits for anonymous/non-subscribed users
    IF @Limit IS NULL
        SET @Limit = 5;

    -- Get current usage
    SELECT @CurrentCount = COUNT(*)
    FROM dbo.UsageTracking
    WHERE (UserId = @UserId OR (@UserId IS NULL AND SessionId = @SessionId))
      AND ActionType = @ActionType
      AND CreatedAt >= @PeriodStart;

    SET @RemainingCount = @Limit - @CurrentCount;

    IF @CurrentCount >= @Limit
    BEGIN
        SET @CanPerform = 0;
        SET @Message = 'Monthly limit reached. Upgrade to Premium for unlimited searches.';
    END
    ELSE
    BEGIN
        SET @CanPerform = 1;
        SET @Message = NULL;
    END
END
GO

PRINT 'Monetisation schema created successfully.';
GO
