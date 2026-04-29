-- =====================================================
-- CarCheck Platform - Seed Data Script
-- Run after 002_CarCheck_Schema.sql
-- =====================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

PRINT 'Starting CarCheck seed data insertion...';
GO

-- =====================================================
-- 1. SUPPLIER SEED DATA
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Supplier] WHERE [SupplierCode] = 'EBAY')
BEGIN
    INSERT INTO [dbo].[Supplier] 
        ([SupplierName], [SupplierCode], [WebsiteUrl], [LogoUrl], [IsActive], [RatingWeight], [ShippingToUk])
    VALUES
        ('eBay UK', 'EBAY', 'https://www.ebay.co.uk', '/logos/ebay.svg', 1, 1.0, 1),
        ('Amazon UK', 'AMAZON', 'https://www.amazon.co.uk', '/logos/amazon.svg', 1, 1.0, 1),
        ('Euro Car Parts', 'EUROCAR', 'https://www.eurocarparts.com', '/logos/eurocarparts.svg', 1, 1.2, 1),
        ('Autodoc', 'AUTODOC', 'https://www.autodoc.co.uk', '/logos/autodoc.svg', 1, 1.1, 1),
        ('RockAuto', 'ROCKAUTO', 'https://www.rockauto.com', '/logos/rockauto.svg', 1, 0.9, 1),
        ('GSF Car Parts', 'GSF', 'https://www.gsfcarparts.com', '/logos/gsf.svg', 1, 1.1, 1),
        ('Halfords', 'HALFORDS', 'https://www.halfords.com', '/logos/halfords.svg', 1, 1.0, 1);
    
    PRINT 'Inserted Supplier seed data';
END
GO

-- =====================================================
-- 2. PART CATEGORIES SEED DATA
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[PartCategory] WHERE [CategoryName] = 'Engine')
BEGIN
    -- Root categories
    INSERT INTO [dbo].[PartCategory] ([CategoryName], [ParentCategoryId], [IconName], [DisplayOrder])
    VALUES
        ('Engine', NULL, 'engine', 1),
        ('Transmission', NULL, 'transmission', 2),
        ('Brakes', NULL, 'brake', 3),
        ('Suspension', NULL, 'suspension', 4),
        ('Steering', NULL, 'steering', 5),
        ('Electrical', NULL, 'electrical', 6),
        ('Cooling', NULL, 'cooling', 7),
        ('Exhaust', NULL, 'exhaust', 8),
        ('Body', NULL, 'body', 9),
        ('Interior', NULL, 'interior', 10),
        ('Filters', NULL, 'filter', 11),
        ('Consumables', NULL, 'oil', 12);

    -- Engine subcategories
    DECLARE @EngineId INT = (SELECT [PartCategoryId] FROM [dbo].[PartCategory] WHERE [CategoryName] = 'Engine');
    INSERT INTO [dbo].[PartCategory] ([CategoryName], [ParentCategoryId], [IconName], [DisplayOrder])
    VALUES
        ('Timing Chain / Belt', @EngineId, NULL, 1),
        ('Turbo', @EngineId, NULL, 2),
        ('Injectors', @EngineId, NULL, 3),
        ('Spark Plugs', @EngineId, NULL, 4),
        ('Coil Packs', @EngineId, NULL, 5),
        ('Water Pump', @EngineId, NULL, 6),
        ('Thermostat', @EngineId, NULL, 7),
        ('Gaskets', @EngineId, NULL, 8),
        ('Sensors', @EngineId, NULL, 9);

    -- Brakes subcategories
    DECLARE @BrakesId INT = (SELECT [PartCategoryId] FROM [dbo].[PartCategory] WHERE [CategoryName] = 'Brakes');
    INSERT INTO [dbo].[PartCategory] ([CategoryName], [ParentCategoryId], [IconName], [DisplayOrder])
    VALUES
        ('Brake Pads', @BrakesId, NULL, 1),
        ('Brake Discs', @BrakesId, NULL, 2),
        ('Brake Calipers', @BrakesId, NULL, 3),
        ('Brake Lines', @BrakesId, NULL, 4),
        ('Handbrake', @BrakesId, NULL, 5);

    -- Suspension subcategories
    DECLARE @SuspId INT = (SELECT [PartCategoryId] FROM [dbo].[PartCategory] WHERE [CategoryName] = 'Suspension');
    INSERT INTO [dbo].[PartCategory] ([CategoryName], [ParentCategoryId], [IconName], [DisplayOrder])
    VALUES
        ('Shock Absorbers', @SuspId, NULL, 1),
        ('Springs', @SuspId, NULL, 2),
        ('Control Arms', @SuspId, NULL, 3),
        ('Ball Joints', @SuspId, NULL, 4),
        ('Bushes', @SuspId, NULL, 5),
        ('Anti-Roll Bar', @SuspId, NULL, 6),
        ('Wheel Bearings', @SuspId, NULL, 7);

    PRINT 'Inserted PartCategory seed data';
END
GO

-- =====================================================
-- 3. SYMPTOM SEED DATA
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Symptom] WHERE [SymptomName] = 'Engine warning light')
BEGIN
    INSERT INTO [dbo].[Symptom] ([SymptomName], [SymptomDescription], [CategoryId])
    VALUES
        -- Engine symptoms
        ('Engine warning light', 'Check engine or MIL light illuminated on dashboard', 1),
        ('Rough idle', 'Engine runs unevenly when stationary', 1),
        ('Engine misfires', 'One or more cylinders not firing correctly', 1),
        ('Loss of power', 'Reduced acceleration or top speed', 1),
        ('Excessive oil consumption', 'Using more than 1L oil per 1000 miles', 1),
        ('Blue smoke from exhaust', 'Indicates oil burning', 1),
        ('Black smoke from exhaust', 'Indicates rich fuel mixture', 1),
        ('White smoke from exhaust', 'May indicate coolant leak into combustion', 1),
        ('Engine knocking', 'Metallic knocking sound from engine', 1),
        ('Timing chain rattle', 'Rattling noise on cold start or at idle', 1),
        
        -- Transmission symptoms
        ('Gearbox slipping', 'Transmission slips out of gear or delays engagement', 2),
        ('Jerky gear changes', 'Harsh or delayed automatic shifts', 2),
        ('Clutch judder', 'Vibration when releasing clutch', 2),
        ('Grinding gears', 'Metallic grinding when changing gear', 2),
        ('Transmission warning light', 'Gearbox warning indicator illuminated', 2),
        
        -- Brake symptoms
        ('Brake squeal', 'High-pitched noise when braking', 3),
        ('Brake judder', 'Vibration through pedal or steering when braking', 3),
        ('Soft brake pedal', 'Pedal travels too far before braking', 3),
        ('ABS warning light', 'ABS warning indicator illuminated', 3),
        ('Pulling under braking', 'Vehicle pulls to one side when braking', 3),
        
        -- Suspension symptoms
        ('Clunking over bumps', 'Knocking sound from suspension', 4),
        ('Uneven tyre wear', 'Tyres wearing unevenly', 4),
        ('Vehicle pulling', 'Vehicle drifts to one side', 4),
        ('Bouncy ride', 'Excessive body movement over bumps', 4),
        ('Creaking noise', 'Creaking from suspension', 4),
        
        -- Electrical symptoms
        ('Battery not charging', 'Battery warning light or flat battery', 5),
        ('Electrical gremlins', 'Intermittent electrical faults', 5),
        ('Lights flickering', 'Dashboard or headlights flickering', 5),
        ('Central locking issues', 'Door locks not working correctly', 5),
        ('Window not working', 'Electric window failure', 5),
        
        -- Cooling symptoms
        ('Overheating', 'Temperature gauge in red or coolant warning', 6),
        ('Coolant loss', 'Coolant level dropping without visible leak', 6),
        ('Heater not working', 'No hot air from cabin heater', 6),
        ('Sweet smell', 'Sweet coolant smell in cabin', 6);
    
    PRINT 'Inserted Symptom seed data';
END
GO

-- =====================================================
-- 4. MOT DEFECT CATEGORIES SEED DATA
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[MotDefectCategory] WHERE [CategoryCode] = '1')
BEGIN
    -- Top-level MOT categories
    INSERT INTO [dbo].[MotDefectCategory] ([CategoryCode], [CategoryName], [ParentCategoryId])
    VALUES
        ('1', 'Identification', NULL),
        ('2', 'Steering', NULL),
        ('3', 'Visibility', NULL),
        ('4', 'Lamps and Reflectors', NULL),
        ('5', 'Axles, Wheels, Tyres, Suspension', NULL),
        ('6', 'Body and Structure', NULL),
        ('7', 'Other Equipment', NULL),
        ('8', 'Nuisance', NULL),
        ('9', 'Driver''s View', NULL);

    -- Suspension subcategories (most common failures)
    DECLARE @Cat5Id INT = (SELECT [MotDefectCategoryId] FROM [dbo].[MotDefectCategory] WHERE [CategoryCode] = '5');
    INSERT INTO [dbo].[MotDefectCategory] ([CategoryCode], [CategoryName], [ParentCategoryId])
    VALUES
        ('5.1', 'Wheel Bearings', @Cat5Id),
        ('5.2', 'Wheels and Tyres', @Cat5Id),
        ('5.3', 'Suspension', @Cat5Id);

    -- Brakes subcategories
    DECLARE @Cat1Id INT = (SELECT [MotDefectCategoryId] FROM [dbo].[MotDefectCategory] WHERE [CategoryCode] = '1');
    INSERT INTO [dbo].[MotDefectCategory] ([CategoryCode], [CategoryName], [ParentCategoryId])
    VALUES
        ('1.1', 'Brake Systems', @Cat1Id),
        ('1.2', 'Mechanical and Electronic Brake Components', @Cat1Id),
        ('1.3', 'Braking Performance', @Cat1Id);

    -- Body subcategories
    DECLARE @Cat6Id INT = (SELECT [MotDefectCategoryId] FROM [dbo].[MotDefectCategory] WHERE [CategoryCode] = '6');
    INSERT INTO [dbo].[MotDefectCategory] ([CategoryCode], [CategoryName], [ParentCategoryId])
    VALUES
        ('6.1', 'Body and Chassis', @Cat6Id),
        ('6.2', 'Corrosion', @Cat6Id);

    -- Emissions subcategories
    DECLARE @Cat8Id INT = (SELECT [MotDefectCategoryId] FROM [dbo].[MotDefectCategory] WHERE [CategoryCode] = '8');
    INSERT INTO [dbo].[MotDefectCategory] ([CategoryCode], [CategoryName], [ParentCategoryId])
    VALUES
        ('8.1', 'Noise', @Cat8Id),
        ('8.2', 'Exhaust Emissions', @Cat8Id),
        ('8.4', 'Fluid Leaks', @Cat8Id);

    PRINT 'Inserted MotDefectCategory seed data';
END
GO

-- =====================================================
-- 5. CHECKLIST CATEGORIES SEED DATA
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Exterior Check')
BEGIN
    INSERT INTO [dbo].[ChecklistCategory] ([CategoryName], [Description], [DisplayOrder])
    VALUES
        ('Exterior Check', 'Visual inspection of body, paint and panels', 1),
        ('Interior Check', 'Cabin, seats, controls and electronics', 2),
        ('Engine Bay', 'Under-bonnet inspection', 3),
        ('Underside', 'Underneath the vehicle', 4),
        ('Road Test', 'Driving evaluation', 5),
        ('Documentation', 'Service history and paperwork', 6);
    
    PRINT 'Inserted ChecklistCategory seed data';
END
GO

-- =====================================================
-- 6. UNIVERSAL CHECKLIST ITEMS
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[ChecklistItem] WHERE [ItemTitle] = 'Check for rust')
BEGIN
    DECLARE @ExtCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Exterior Check');
    DECLARE @IntCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Interior Check');
    DECLARE @EngCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Engine Bay');
    DECLARE @UndCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Underside');
    DECLARE @RoadCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Road Test');
    DECLARE @DocCatId INT = (SELECT [ChecklistCategoryId] FROM [dbo].[ChecklistCategory] WHERE [CategoryName] = 'Documentation');

    -- Exterior checks
    INSERT INTO [dbo].[ChecklistItem] 
        ([ChecklistCategoryId], [VehicleModelId], [ItemTitle], [ItemDescription], [WhyImportant], [HowToCheck], [RedFlags], [EstimatedRepairCost], [Severity], [DisplayOrder])
    VALUES
        (@ExtCatId, NULL, 'Check for rust', 'Inspect wheel arches, sills, door bottoms and around windows', 
         'Rust can spread quickly and compromise structural integrity', 
         'Look for bubbling paint, orange discoloration, or flaky areas. Use a magnet to detect filler.',
         'Rust bubbles, thick filler, mismatched paint', '£500-£2000+', 3, 1),
        
        (@ExtCatId, NULL, 'Panel gaps and alignment', 'Check all panel gaps are even and consistent', 
         'Uneven gaps can indicate previous accident damage', 
         'Compare gaps on both sides of the car. Check bonnet, doors and boot alignment.',
         'Uneven gaps, doors that don''t close properly', '£300-£1500', 2, 2),
        
        (@ExtCatId, NULL, 'Glass and windscreen', 'Check all glass for chips, cracks and scratches', 
         'Windscreen damage can fail MOT and impair visibility', 
         'Look across windscreen at an angle. Check all windows operate correctly.',
         'Cracks in driver''s view, chips near edges', '£100-£400', 2, 3),
        
        (@ExtCatId, NULL, 'Tyre condition', 'Check all tyres including spare for wear and damage', 
         'Worn tyres affect safety and can indicate alignment issues', 
         'Check tread depth (min 1.6mm UK legal), look for uneven wear patterns.',
         'Below 3mm tread, uneven wear, bulges or cracks', '£200-£800', 3, 4);

    -- Engine bay checks
    INSERT INTO [dbo].[ChecklistItem] 
        ([ChecklistCategoryId], [VehicleModelId], [ItemTitle], [ItemDescription], [WhyImportant], [HowToCheck], [RedFlags], [EstimatedRepairCost], [Severity], [DisplayOrder])
    VALUES
        (@EngCatId, NULL, 'Oil condition and level', 'Check oil level, colour and consistency', 
         'Oil condition indicates engine health and maintenance', 
         'Pull dipstick when cold. Oil should be amber/brown, not black or milky.',
         'Milky oil (head gasket), very black oil, metal particles', '£50-£3000+', 4, 1),
        
        (@EngCatId, NULL, 'Coolant level and condition', 'Check coolant level and colour', 
         'Overheating can cause catastrophic engine damage', 
         'Check expansion tank level (engine cold). Coolant should be pink/blue/green, not brown.',
         'Brown coolant, oil in coolant, low level', '£100-£2000+', 4, 2),
        
        (@EngCatId, NULL, 'Belts and hoses', 'Inspect drive belts and coolant hoses', 
         'Belt or hose failure can strand you or cause engine damage', 
         'Look for cracks, fraying or swelling. Press hoses - should be firm not soft.',
         'Cracked belts, bulging hoses, wet spots', '£100-£500', 3, 3),
        
        (@EngCatId, NULL, 'Listen to engine', 'Start and listen for unusual noises', 
         'Engine noises can indicate serious problems', 
         'Cold start reveals timing chain rattle. Listen for knocking, ticking or whining.',
         'Timing chain rattle, bottom end knock, turbo whine', '£500-£5000+', 4, 4);

    -- Road test checks
    INSERT INTO [dbo].[ChecklistItem] 
        ([ChecklistCategoryId], [VehicleModelId], [ItemTitle], [ItemDescription], [WhyImportant], [HowToCheck], [RedFlags], [EstimatedRepairCost], [Severity], [DisplayOrder])
    VALUES
        (@RoadCatId, NULL, 'Gearbox operation', 'Test all gears engage smoothly', 
         'Gearbox repairs are expensive', 
         'Manual: check clutch bite point, all gears. Auto: check smooth changes, no jerks.',
         'Clutch slip, grinding, delayed engagement, jerky changes', '£500-£3000+', 4, 1),
        
        (@RoadCatId, NULL, 'Brakes', 'Test brakes at various speeds', 
         'Brakes are critical for safety', 
         'Brake firmly from 30mph - car should stop straight. Check for judder or pulling.',
         'Judder, pulling to one side, grinding, soft pedal', '£200-£800', 4, 2),
        
        (@RoadCatId, NULL, 'Steering and handling', 'Check steering feel and response', 
         'Poor steering indicates worn components', 
         'Check for play in steering wheel. Car should track straight on flat road.',
         'Excessive play, pulling, knocking on full lock', '£200-£1000', 3, 3),
        
        (@RoadCatId, NULL, 'Suspension', 'Feel for bumps and listen for noises', 
         'Worn suspension affects handling and tyre wear', 
         'Drive over speed bumps. Listen for clunks. Check car doesn''t bounce excessively.',
         'Clunking, bouncing, uneven ride', '£200-£1500', 2, 4);

    -- Documentation checks
    INSERT INTO [dbo].[ChecklistItem] 
        ([ChecklistCategoryId], [VehicleModelId], [ItemTitle], [ItemDescription], [WhyImportant], [HowToCheck], [RedFlags], [EstimatedRepairCost], [Severity], [DisplayOrder])
    VALUES
        (@DocCatId, NULL, 'Service history', 'Review all service records', 
         'Proves maintenance and shows what work has been done', 
         'Check stamps match garages. Verify timing belt/chain service if applicable.',
         'Missing records, gaps in history, no cambelt stamp', 'N/A', 3, 1),
        
        (@DocCatId, NULL, 'MOT history', 'Check online MOT history', 
         'Reveals recurring problems and mileage consistency', 
         'Check gov.uk MOT history. Look for advisories and mileage drops.',
         'Repeated failures, mileage discrepancies', 'N/A', 4, 2),
        
        (@DocCatId, NULL, 'V5C logbook', 'Verify V5C details match the car', 
         'Confirms ownership and vehicle identity', 
         'Check VIN matches car. Verify seller details. Check for previous keepers.',
         'VIN mismatch, mismatched details, many owners', 'N/A', 4, 3);

    PRINT 'Inserted ChecklistItem seed data';
END
GO

PRINT 'Seed data insertion completed successfully.';
GO
