-- ============================================================
-- Insert & Clean Avent Products
-- Category: Avent
-- ============================================================

USE PosInventoryDb;
GO

SET NOCOUNT ON;

-- 1. Identify Avent Category Id
DECLARE @AventCatId INT = (SELECT TOP 1 Id FROM Categories WHERE Name = 'Avent');
IF @AventCatId IS NULL
BEGIN
    INSERT INTO Categories (Name, Description, IsActive) VALUES ('Avent', 'Philips Avent brand baby products', 1);
    SET @AventCatId = SCOPE_IDENTITY();
END

DECLARE @UnitId INT = (SELECT TOP 1 Id FROM Units WHERE ShortCode = 'pcs');
IF @UnitId IS NULL SET @UnitId = 1;

-- 2. Delete existing products inserted previously (Id >= 197) that have no sales/purchases
DELETE FROM Products WHERE Id >= 197;

-- 3. Update existing Avent products (193-196) to Category = Avent
UPDATE Products
SET CategoryId = @AventCatId
WHERE SKU IN ('SCY903/01', 'SCY903/11', 'SCY903/21', 'SCY906/01');

-- 4. Insert table with all requested items
CREATE TABLE #TempAvent (
    SKU          NVARCHAR(50),
    Barcode      NVARCHAR(50),
    Name         NVARCHAR(150),
    GenericName  NVARCHAR(150) NULL,
    Description  NVARCHAR(500) NULL,
    CostPrice    DECIMAL(18,2),
    SellingPrice DECIMAL(18,2),
    CurrentStock INT,
    MinAlertStock INT
);

INSERT INTO #TempAvent (SKU, Barcode, Name, GenericName, Description, CostPrice, SellingPrice, CurrentStock, MinAlertStock)
VALUES
-- Top 2 items
('AV-05',         'AV-05',         'Feeder 260ml',                      'AV-05',         'Feeder 260ml Code: AV-05',                     0, 0, 0, 5),
('AV-06',         'AV-06',         'Feeder 330ml',                      'AV-06',         'Feeder 330ml Code: AV-06',                     0, 0, 0, 5),

-- 1. Avent 125ml
('SCY900/01',     'SCY900/01',     'Avent 125ml',                       'SCY900/01',     'Avent 125ml Code: SCY900/01',                  0, 0, 0, 5),

-- 8. Avent 125ml 2x
('SCY900/02',     'SCY900/02',     'Avent 125ml 2x',                    'SCY900/02',     'Avent 125ml 2x Code: SCY900/02',               0, 0, 0, 5),

-- 9. Avent 260ml 2x
('SCY903/02',     'SCY903/02',     'Avent 260ml 2x',                    'SCY903/02',     'Avent 260ml 2x Code: SCY903/02',               0, 0, 0, 5),

-- 10. Avent 3300ml 2x (330ml 2x)
('SCY906/02',     'SCY906/02',     'Avent 330ml 2x',                    'Avent 3300ml 2x','Avent 3300ml 2x Code: SCY906/02',             0, 0, 0, 5),

-- 12-16. Avent Nipple Natural (Codes: SCY961/02 to SCY965/02)
('SCY961/02',     'SCY961/02',     'Avent Nipple Natural (Size 1)',     'SCY961/02',     'Avent Nipple Natural Code: SCY961/02',         0, 0, 0, 5),
('SCY962/02',     'SCY962/02',     'Avent Nipple Natural (Size 2)',     'SCY962/02',     'Avent Nipple Natural Code: SCY962/02',         0, 0, 0, 5),
('SCY963/02',     'SCY963/02',     'Avent Nipple Natural (Size 3)',     'SCY963/02',     'Avent Nipple Natural Code: SCY963/02',         0, 0, 0, 5),
('SCY964/02',     'SCY964/02',     'Avent Nipple Natural (Size 4)',     'SCY964/02',     'Avent Nipple Natural Code: SCY964/02',         0, 0, 0, 5),
('SCY965/02',     'SCY965/02',     'Avent Nipple Natural (Size 5)',     'SCY965/02',     'Avent Nipple Natural Code: SCY965/02',         0, 0, 0, 5),

-- 19-23. Avent Nipple Anti-colic
-- (Note: -AC suffix applied to avoid duplicate key conflict with Natural SCY961-964 while preserving searchability)
('SCY762/02',     'SCY762/02',     'Avent Nipple Anti-colic (Size 2)',  'SCY762/02',     'Avent Nipple Anti-colic Code: SCY762/02',      0, 0, 0, 5),
('SCY961/02-AC',  'SCY961/02-AC',  'Avent Nipple Anti-colic (Size 1)',  'SCY961/02',     'Avent Nipple Anti-colic Code: SCY961/02',      0, 0, 0, 5),
('SCY962/02-AC',  'SCY962/02-AC',  'Avent Nipple Anti-colic (Size 3)',  'SCY962/02',     'Avent Nipple Anti-colic Code: SCY962/02',      0, 0, 0, 5),
('SCY963/02-AC',  'SCY963/02-AC',  'Avent Nipple Anti-colic (Size 4)',  'SCY963/02',     'Avent Nipple Anti-colic Code: SCY963/02',      0, 0, 0, 5),
('SCY964/02-AC',  'SCY964/02-AC',  'Avent Nipple Anti-colic (Size 5)',  'SCY964/02',     'Avent Nipple Anti-colic Code: SCY964/02',      0, 0, 0, 5),

-- 25-26. Avent Soothers
('SCF085/59',     'SCF085/59',     'Avent Soother 0-6',                 'SCF085/59',     'Avent Soother 0-6 Code: SCF085/59',             0, 0, 0, 5),
('SCF085/61',     'SCF085/61',     'Avent Soother 6-18',                'SCF085/61',     'Avent Soother 6-18 Code: SCF085/61',            0, 0, 0, 5),

-- 28-29. Avent Breast Pumps
('SCD417/20',     'SCD417/20',     'Avent Manual Breast Pump',          'SCD417/20',     'Avent Manual Breast Pump Code: SCD417/20',      0, 0, 0, 5),
('SCF395/11',     'SCF395/11',     'Avent Electric Breast Pump',        'AV-EBP',        'Avent Electric Breast Pump',                    0, 0, 0, 5),

-- 30-31. Avent Glass Bottles
('SCF051/17',     'SCF051/17',     'Avent Glass Bottle 120ml',          'SCF051/17',     'Avent Glass Bottle 120ml Code: SCF051/17',      0, 0, 0, 5),
('SCF053/17',     'SCF053/17',     'Avent Glass Bottle 240ml',          'SCF053/17',     'Avent Glass Bottle 240ml Code: SCF053/17',      0, 0, 0, 5),

-- 31b. Duck beak 280ml
('DB-280',        'DB-280',        'Duck beak 280ml',                   'DB-280',        'Duck beak 280ml',                               0, 0, 0, 5);

-- 5. Insert new products
INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive, CreatedAt)
SELECT
    t.SKU,
    t.Barcode,
    t.Name,
    t.GenericName,
    t.Description,
    @AventCatId,
    @UnitId,
    t.CostPrice,
    t.SellingPrice,
    t.CurrentStock,
    t.MinAlertStock,
    '/uploads/products/pharma-item.svg',
    1,
    GETUTCDATE()
FROM #TempAvent t
WHERE NOT EXISTS (
    SELECT 1 FROM Products p WHERE p.SKU = t.SKU OR p.Barcode = t.Barcode
);

DROP TABLE #TempAvent;
GO

-- 6. Verification Output
SELECT
    p.Id,
    p.SKU,
    p.Barcode,
    p.Name,
    c.Name AS CategoryName,
    p.CategoryId,
    p.SellingPrice,
    p.CurrentStock
FROM Products p
JOIN Categories c ON p.CategoryId = c.Id
WHERE c.Name = 'Avent'
ORDER BY p.Id ASC;
GO
