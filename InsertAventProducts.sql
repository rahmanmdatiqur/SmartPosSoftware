-- ============================================================
-- Insert & Update Products for CategoryId = 8 (as requested)
-- ============================================================

USE PosInventoryDb;
GO

SET NOCOUNT ON;

DECLARE @CatId INT = 8;
DECLARE @UnitId INT = 1; -- Pieces (pcs)

-- 1. Update existing 4 Avent products to CategoryId = 8
UPDATE Products SET CategoryId = @CatId WHERE SKU = 'SCY903/01';
UPDATE Products SET CategoryId = @CatId WHERE SKU = 'SCY903/11';
UPDATE Products SET CategoryId = @CatId WHERE SKU = 'SCY903/21';
UPDATE Products SET CategoryId = @CatId WHERE SKU = 'SCY906/01';

-- 2. Temporary table for new entries
IF OBJECT_ID('tempdb..#NewProducts') IS NOT NULL DROP TABLE #NewProducts;

CREATE TABLE #NewProducts (
    SKU          NVARCHAR(50),
    Barcode      NVARCHAR(50),
    Name         NVARCHAR(150),
    GenericName  NVARCHAR(150) NULL,
    Description  NVARCHAR(500) NULL,
    CategoryId   INT,
    UnitId       INT,
    CostPrice    DECIMAL(18,2),
    SellingPrice DECIMAL(18,2),
    CurrentStock INT,
    MinAlertStock INT,
    ImageUrl     NVARCHAR(255),
    IsActive     BIT
);

INSERT INTO #NewProducts (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive)
VALUES
-- Top items
('AV-05',     'AV-05',     'Feeder 260ml',                      NULL,        'Feeder 260ml Code: AV-05',                      @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('AV-06',     'AV-06',     'Feeder 330ml',                      NULL,        'Feeder 330ml Code: AV-06',                      @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 1. Avent 125ml
('SCY900/01', 'SCY900/01', 'Avent 125ml',                       NULL,        'Avent 125ml Code: SCY900/01',                   @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 8. Avent 125ml 2x
('SCY900/02', 'SCY900/02', 'Avent 125ml 2x',                    NULL,        'Avent 125ml 2x Code: SCY900/02',                @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 9. Avent 260ml 2x
('SCY903/02', 'SCY903/02', 'Avent 260ml 2x',                    NULL,        'Avent 260ml 2x Code: SCY903/02',                @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 10. Avent 330ml 2x (Avent 3300ml 2x)
('SCY906/02', 'SCY906/02', 'Avent 330ml 2x',                    'Avent 3300ml 2x', 'Avent 330ml 2x Code: SCY906/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 12-16. Avent Nipple Natural (Sizes 1 to 5)
('SCY961/02', 'SCY961/02', 'Avent Nipple Natural (Size 1)',     'SCY961/02', 'Avent Nipple Natural Code: SCY961/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY962/02', 'SCY962/02', 'Avent Nipple Natural (Size 2)',     'SCY962/02', 'Avent Nipple Natural Code: SCY962/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY963/02', 'SCY963/02', 'Avent Nipple Natural (Size 3)',     'SCY963/02', 'Avent Nipple Natural Code: SCY963/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY964/02', 'SCY964/02', 'Avent Nipple Natural (Size 4)',     'SCY964/02', 'Avent Nipple Natural Code: SCY964/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY965/02', 'SCY965/02', 'Avent Nipple Natural (Size 5)',     'SCY965/02', 'Avent Nipple Natural Code: SCY965/02',          @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 19-23. Avent Nipple Anti-colic (Sizes 1 to 5: SCY761 to SCY765)
('SCY762/02', 'SCY762/02', 'Avent Nipple Anti-colic (Size 2)',  'SCY762/02', 'Avent Nipple Anti-colic Code: SCY762/02',       @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY761/02', 'SCY761/02', 'Avent Nipple Anti-colic (Size 1)',  'SCY961/02', 'Avent Nipple Anti-colic Code: SCY761/02 (SCY961/02)', @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY763/02', 'SCY763/02', 'Avent Nipple Anti-colic (Size 3)',  'SCY961/02', 'Avent Nipple Anti-colic Code: SCY763/02 (SCY961/02)', @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY764/02', 'SCY764/02', 'Avent Nipple Anti-colic (Size 4)',  'SCY961/02', 'Avent Nipple Anti-colic Code: SCY764/02 (SCY961/02)', @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCY765/02', 'SCY765/02', 'Avent Nipple Anti-colic (Size 5)',  'SCY961/02', 'Avent Nipple Anti-colic Code: SCY765/02 (SCY961/02)', @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 25-26. Avent Soothers
('SCF085/59', 'SCF085/59', 'Avent Soother 0-6',                 NULL,        'Avent Soother 0-6 Code: SCF085/59',              @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCF085/61', 'SCF085/61', 'Avent Soother 6-18',                NULL,        'Avent Soother 6-18 Code: SCF085/61',             @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 28-29. Avent Breast Pumps
('SCD417/20', 'SCD417/20', 'Avent Manual Breast Pump',          NULL,        'Avent Manual Breast Pump Code: SCD417/20',       @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCF395/11', 'SCF395/11', 'Avent Electric Breast Pump',        'AV-EBP',    'Avent Electric Breast Pump',                     @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 30-31. Avent Glass Bottles
('SCF051/17', 'SCF051/17', 'Avent Glass Bottle 120ml',          NULL,        'Avent Glass Bottle 120ml Code: SCF051/17',       @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),
('SCF053/17', 'SCF053/17', 'Avent Glass Bottle 240ml',          NULL,        'Avent Glass Bottle 240ml Code: SCF053/17',       @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1),

-- 31b. Duck beak 280ml
('DB-280',    'DB-280',    'Duck beak 280ml',                   NULL,        'Duck beak 280ml',                                @CatId, @UnitId, 0, 0, 0, 5, '/uploads/products/pharma-item.svg', 1);

-- 3. Insert items that don't already exist in Products
INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, CreatedAt)
SELECT
    n.SKU,
    n.Barcode,
    n.Name,
    n.GenericName,
    n.Description,
    n.CategoryId,
    n.UnitId,
    n.CostPrice,
    n.SellingPrice,
    n.CurrentStock,
    n.MinAlertStock,
    n.ImageUrl,
    n.IsActive,
    GETUTCDATE()
FROM #NewProducts n
WHERE NOT EXISTS (
    SELECT 1 FROM Products p WHERE p.SKU = n.SKU OR p.Barcode = n.Barcode
);

DROP TABLE #NewProducts;
GO

-- Verification query
SELECT Id, SKU, Barcode, Name, CategoryId, SellingPrice, CurrentStock, IsActive
FROM Products
WHERE CategoryId = 8
ORDER BY Id DESC;
GO
