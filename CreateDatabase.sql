-- ============================================================
--  POS SOFTWARE — Full Database Creation Script
--  Target Server : DEV-1017
--  Database Name : PosInventoryDb
--  Generated     : 2026-11-23
-- ============================================================

USE master;
GO

-- Drop & recreate the database
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'PosInventoryDb')
BEGIN
    ALTER DATABASE PosInventoryDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PosInventoryDb;
END
GO

CREATE DATABASE PosInventoryDb
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE PosInventoryDb;
GO

-- ============================================================
-- 1. SECURITY — Roles, Users, Module Pages, Permissions
-- ============================================================

CREATE TABLE AppRoles (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(50)  NOT NULL,
    Description NVARCHAR(200) NULL,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE TABLE AppUsers (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(50)  NOT NULL,
    FullName     NVARCHAR(100) NOT NULL,
    Email        NVARCHAR(100) NULL,
    Phone        NVARCHAR(20)  NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Salt         NVARCHAR(MAX) NOT NULL,
    RoleId       INT           NOT NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    LastLoginAt  DATETIME2     NULL,
    CONSTRAINT FK_AppUsers_AppRoles FOREIGN KEY (RoleId)
        REFERENCES AppRoles(Id) ON DELETE CASCADE
);
GO

CREATE UNIQUE INDEX UX_AppUsers_Username ON AppUsers(Username);
GO

CREATE TABLE AppModulePages (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName     NVARCHAR(50)  NOT NULL,
    PageName       NVARCHAR(100) NOT NULL,
    DisplayName    NVARCHAR(100) NOT NULL,
    ControllerName NVARCHAR(100) NOT NULL DEFAULT '',
    ActionName     NVARCHAR(100) NOT NULL DEFAULT '',
    IconClass      NVARCHAR(50)  NOT NULL DEFAULT 'bi bi-circle',
    SortOrder      INT           NOT NULL DEFAULT 0,
    ShowInMenu     BIT           NOT NULL DEFAULT 1,
    IsActive       BIT           NOT NULL DEFAULT 1
);
GO

CREATE TABLE RolePermissions (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    RoleId          INT NOT NULL,
    AppModulePageId INT NOT NULL,
    CanView         BIT NOT NULL DEFAULT 0,
    CanCreate       BIT NOT NULL DEFAULT 0,
    CanEdit         BIT NOT NULL DEFAULT 0,
    CanDelete       BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleId)
        REFERENCES AppRoles(Id) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermissions_Pages FOREIGN KEY (AppModulePageId)
        REFERENCES AppModulePages(Id) ON DELETE CASCADE
);
GO

-- ============================================================
-- 2. CATALOG & INVENTORY
-- ============================================================

CREATE TABLE Categories (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(250) NULL,
    IsActive    BIT           NOT NULL DEFAULT 1
);
GO

CREATE TABLE Units (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(50) NOT NULL,
    ShortCode NVARCHAR(10) NOT NULL,
    IsActive  BIT          NOT NULL DEFAULT 1
);
GO

CREATE TABLE Suppliers (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(150) NOT NULL,
    ContactPerson NVARCHAR(100) NULL,
    Phone         NVARCHAR(20)  NULL,
    Email         NVARCHAR(100) NULL,
    Address       NVARCHAR(300) NULL,
    IsActive      BIT           NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE TABLE Products (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    SKU           NVARCHAR(50)  NOT NULL,
    Barcode       NVARCHAR(50)  NOT NULL,
    Name          NVARCHAR(150) NOT NULL,
    GenericName   NVARCHAR(150) NULL,
    Description   NVARCHAR(500) NULL,
    CategoryId    INT           NOT NULL,
    UnitId        INT           NOT NULL,
    SupplierId    INT           NULL,
    CostPrice     DECIMAL(18,2) NOT NULL DEFAULT 0,
    SellingPrice  DECIMAL(18,2) NOT NULL DEFAULT 0,
    CurrentStock  INT           NOT NULL DEFAULT 0,
    MinAlertStock INT           NOT NULL DEFAULT 5,
    ImageUrl      NVARCHAR(255) NULL,
    IsActive      BIT           NOT NULL DEFAULT 1,
    SortOrder     INT           NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId)
        REFERENCES Categories(Id),
    CONSTRAINT FK_Products_Units FOREIGN KEY (UnitId)
        REFERENCES Units(Id),
    CONSTRAINT FK_Products_Suppliers FOREIGN KEY (SupplierId)
        REFERENCES Suppliers(Id)
);
GO

CREATE UNIQUE INDEX UX_Products_Barcode ON Products(Barcode);
CREATE UNIQUE INDEX UX_Products_SKU     ON Products(SKU);
GO

CREATE TABLE StockTransactions (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    ProductId       INT           NOT NULL,
    TransactionType NVARCHAR(30)  NOT NULL,
    Quantity        INT           NOT NULL,
    PreviousStock   INT           NOT NULL,
    NewStock        INT           NOT NULL,
    ReferenceNo     NVARCHAR(50)  NULL,
    Notes           NVARCHAR(255) NULL,
    CreatedByUserId INT           NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_StockTx_Products FOREIGN KEY (ProductId)
        REFERENCES Products(Id),
    CONSTRAINT FK_StockTx_Users FOREIGN KEY (CreatedByUserId)
        REFERENCES AppUsers(Id) ON DELETE SET NULL
);
GO

CREATE TABLE StockAdjustments (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    AdjustmentNo    NVARCHAR(50)  NOT NULL,
    AdjustmentDate  DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    Notes           NVARCHAR(255) NULL,
    CreatedByUserId INT           NULL,
    CONSTRAINT FK_StockAdj_Users FOREIGN KEY (CreatedByUserId)
        REFERENCES AppUsers(Id) ON DELETE SET NULL
);
GO

CREATE TABLE StockAdjustmentItems (
    Id                INT IDENTITY(1,1) PRIMARY KEY,
    StockAdjustmentId INT           NOT NULL,
    ProductId         INT           NOT NULL,
    OldStock          INT           NOT NULL,
    AdjustedStock     INT           NOT NULL,
    DifferenceQty     INT           NOT NULL,
    Reason            NVARCHAR(100) NULL,
    CONSTRAINT FK_SAItems_Adj FOREIGN KEY (StockAdjustmentId)
        REFERENCES StockAdjustments(Id) ON DELETE CASCADE,
    CONSTRAINT FK_SAItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products(Id)
);
GO

-- ============================================================
-- 3. POS & SALES
-- ============================================================

CREATE TABLE Customers (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(100) NOT NULL,
    Phone         NVARCHAR(20)  NULL,
    Email         NVARCHAR(100) NULL,
    Address       NVARCHAR(255) NULL,
    LoyaltyPoints INT           NOT NULL DEFAULT 0,
    IsActive      BIT           NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE TABLE Sales (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNumber   NVARCHAR(50)  NOT NULL,
    SaleDate        DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CustomerId      INT           NOT NULL,
    SubTotal        DECIMAL(18,2) NOT NULL DEFAULT 0,
    TaxRate         DECIMAL(18,2) NOT NULL DEFAULT 0,
    TaxAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountPercent DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    RoundUp         DECIMAL(18,2) NOT NULL DEFAULT 0,
    FinalPayable    DECIMAL(18,2) NOT NULL DEFAULT 0,
    GrandTotal      DECIMAL(18,2) NOT NULL DEFAULT 0,
    PaidAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    ChangeAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
    DuesAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    AdmissionNo     NVARCHAR(50)  NULL,
    SaleOrderNo     NVARCHAR(50)  NULL,
    CustomerType    NVARCHAR(50)  NOT NULL DEFAULT 'Walk-in',
    FundType        NVARCHAR(50)  NOT NULL DEFAULT 'Cash',
    MobileNumber    NVARCHAR(30)  NULL,
    IsPosted        BIT           NOT NULL DEFAULT 1,
    PaymentMethod   NVARCHAR(30)  NOT NULL DEFAULT 'Cash',
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Completed',
    Notes           NVARCHAR(255) NULL,
    CashierId       INT           NULL,
    CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerId)
        REFERENCES Customers(Id),
    CONSTRAINT FK_Sales_Cashier FOREIGN KEY (CashierId)
        REFERENCES AppUsers(Id) ON DELETE SET NULL
);
GO

CREATE UNIQUE INDEX UX_Sales_InvoiceNumber ON Sales(InvoiceNumber);
GO

CREATE TABLE SaleItems (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    SaleId         INT           NOT NULL,
    ProductId      INT           NOT NULL,
    ProductName    NVARCHAR(150) NOT NULL,
    BatchNo        NVARCHAR(50)  NULL,
    CostPrice      DECIMAL(18,2) NOT NULL DEFAULT 0,
    UnitPrice      DECIMAL(18,2) NOT NULL DEFAULT 0,
    Quantity       INT           NOT NULL DEFAULT 1,
    SubTotal       DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_SaleItems_Sales FOREIGN KEY (SaleId)
        REFERENCES Sales(Id) ON DELETE CASCADE,
    CONSTRAINT FK_SaleItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products(Id)
);
GO

-- ============================================================
-- 4. PURCHASE
-- ============================================================

CREATE TABLE Purchases (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseNo      NVARCHAR(50)  NOT NULL,
    PurchaseDate    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    ReceiveDate     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    SupplierId      INT           NOT NULL,
    PurchaseOrderNo NVARCHAR(50)  NULL,
    TotalQty        INT           NOT NULL DEFAULT 0,
    SubTotal        DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    PaidAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    DueAmount       DECIMAL(18,2) NOT NULL DEFAULT 0,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Posted',
    IsPosted        BIT           NOT NULL DEFAULT 1,
    Notes           NVARCHAR(255) NULL,
    CreatedByUserId INT           NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Purchases_Suppliers FOREIGN KEY (SupplierId)
        REFERENCES Suppliers(Id) ON DELETE NO ACTION,
    CONSTRAINT FK_Purchases_Users FOREIGN KEY (CreatedByUserId)
        REFERENCES AppUsers(Id) ON DELETE SET NULL
);
GO

CREATE UNIQUE INDEX UX_Purchases_PurchaseNo ON Purchases(PurchaseNo);
GO

CREATE TABLE PurchaseItems (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseId  INT           NOT NULL,
    ProductId   INT           NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    ProductCode NVARCHAR(50)  NULL,
    Quantity    INT           NOT NULL DEFAULT 1,
    UnitPrice   DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_PurchaseItems_Purchases FOREIGN KEY (PurchaseId)
        REFERENCES Purchases(Id) ON DELETE CASCADE,
    CONSTRAINT FK_PurchaseItems_Products FOREIGN KEY (ProductId)
        REFERENCES Products(Id)
);
GO

-- ============================================================
-- 5. SEED DATA
-- ============================================================

-- Roles
INSERT INTO AppRoles (RoleName, Description, IsActive)
VALUES
    ('SuperAdmin',       'Full system administrative rights',                        1),
    ('Admin',            'Store Administrator with full operational rights',         1),
    ('Cashier',          'Front desk cashier with POS access',                       1),
    ('InventoryManager', 'Manages stocks, adjustments, and products',               1);
GO

-- Users  (passwords: Admin@123 / Cashier@123 / Manager@123)
INSERT INTO AppUsers (Username, FullName, Email, Phone, PasswordHash, Salt, RoleId, IsActive)
VALUES
    ('admin',   'System Administrator', 'admin@smartpos.com',   '+1 555-0101', 'Jzm4iop46jau0m2Pocjfur/Vb9wfW/rY1KncMAaYSX4=', 'C9t4sXZWALx4EJVtMySY7w==', 1, 1),
    ('cashier', 'John Cashier',         'cashier@smartpos.com', '+1 555-0102', '7VZGTIwI6vgUXCb/22q13WtrlKTrjOFrWTlpgp4C2Y4=', 'OZjMwzmun5TAfDBFAv6arQ==', 3, 1),
    ('manager', 'Robert Stock Manager', 'manager@smartpos.com', '+1 555-0103', 'KxPP0w/la6kxJBzmTUdEtWWqH3gRwE6XdW1M/+oA0lE=', '05atjwtlYF3I5GUDh3rMNA==', 4, 1);
GO

-- Module Pages
INSERT INTO AppModulePages (ModuleName, PageName, DisplayName, ControllerName, ActionName, IconClass, SortOrder, ShowInMenu)
VALUES
    ('Main',      'Dashboard',       'Dashboard',            'Dashboard',      'Index',   'bi bi-speedometer2', 1,  1),
    ('POS',       'PosTerminal',     'POS Terminal',         'Pos',            'Index',   'bi bi-cart4',        2,  1),
    ('POS',       'SalesOrders',     'Sales Invoices',       'Sales',          'Index',   'bi bi-receipt',      3,  1),
    ('Purchase',  'Purchase',        'Purchase List',        'Purchase',       'Index',   'bi bi-bag-check',    4,  1),
    ('Inventory', 'InventoryList',   'Stock Overview',       'Inventory',      'Index',   'bi bi-boxes',        5,  1),
    ('Inventory', 'StockAdjustment', 'Stock Adjustment',     'Inventory',      'Adjust',  'bi bi-sliders',      6,  1),
    ('Catalog',   'Products',        'Products',             'Product',        'Index',   'bi bi-box-seam',     7,  1),
    ('Catalog',   'Categories',      'Categories',           'Category',       'Index',   'bi bi-tags',         8,  1),
    ('Catalog',   'Suppliers',       'Suppliers',            'Supplier',       'Index',   'bi bi-truck',        9,  1),
    ('Catalog',   'Customers',       'Customers',            'Customer',       'Index',   'bi bi-people',       10, 1),
    ('Security',  'Users',           'User Management',      'User',           'Index',   'bi bi-person-gear',  11, 1),
    ('Security',  'RolePermissions', 'Role & Permissions',   'RolePermission', 'Index',   'bi bi-shield-lock',  12, 1),
    ('Reports',   'Reports',         'Sales & Stock Reports','Sales',          'Reports', 'bi bi-graph-up',     13, 1);
GO

-- Role Permissions: SuperAdmin → full access to all pages
INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
SELECT 1, Id, 1, 1, 1, 1 FROM AppModulePages;
GO

-- Role Permissions: Admin → full access except Delete on Users/RolePermissions
INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
SELECT 2, Id, 1, 1, 1,
    CASE WHEN PageName IN ('Users','RolePermissions') THEN 0 ELSE 1 END
FROM AppModulePages;
GO

-- Role Permissions: Cashier
INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
SELECT 3, Id,
    CASE WHEN PageName IN ('Dashboard','PosTerminal','SalesOrders','Customers') THEN 1 ELSE 0 END,
    CASE WHEN PageName IN ('PosTerminal','Customers')                           THEN 1 ELSE 0 END,
    0, 0
FROM AppModulePages;
GO

-- Role Permissions: InventoryManager
INSERT INTO RolePermissions (RoleId, AppModulePageId, CanView, CanCreate, CanEdit, CanDelete)
SELECT 4, Id,
    CASE WHEN PageName IN ('Dashboard','InventoryList','StockAdjustment','Products','Categories','Suppliers','Reports') THEN 1 ELSE 0 END,
    CASE WHEN PageName IN ('StockAdjustment','Products','Categories','Suppliers')                                       THEN 1 ELSE 0 END,
    CASE WHEN PageName IN ('StockAdjustment','Products','Categories','Suppliers','InventoryList')                       THEN 1 ELSE 0 END,
    0
FROM AppModulePages;
GO

-- Categories
INSERT INTO Categories (Name, Description, IsActive)
VALUES
    ('Beverages',        'Soft drinks, juices, bottled water, tea & coffee',         1),
    ('Bakery & Snacks',  'Bread, cookies, chips, biscuits and snacks',               1),
    ('Grocery & Staples','Rice, flour, cooking oil, spices, pulses',                 1),
    ('Dairy & Eggs',     'Milk, cheese, butter, yogurt, fresh eggs',                 1),
    ('Personal Care',    'Soap, shampoo, toothpaste, cosmetics',                     1),
    ('Pharmacy',         'Prescription and OTC medicines, healthcare products',      1);
GO

-- Units
INSERT INTO Units (Name, ShortCode, IsActive)
VALUES
    ('Pieces', 'PCS',  1),
    ('Kilogram','kg',  1),
    ('Box',    'box',  1),
    ('Packet', 'pkt',  1),
    ('Litre',  'ltr',  1);
GO

-- Suppliers
INSERT INTO Suppliers (Name, ContactPerson, Phone, Email, Address, IsActive)
VALUES
    ('Jawdan Pharmacy',           'Dave Miller',   '+1 555-0211', 'orders@jawdanpharma.com',  'Sylhet',                  1),
    ('Incepta Pharmaceuticals Ltd.','Sarah Jenkins','+1 555-0212', 'contact@inceptapharma.com','Dhaka',                   1),
    ('Nipro JMI Pharma Ltd.',     'Ali Rahman',    '+1 555-0213', 'sales@niprojmi.com',       'Dhaka',                   1),
    ('SK+F (Transcom)',            'Kamal Hossain', '+1 555-0214', 'orders@skfbd.com',         'Transcom Industrial Park', 1);
GO

-- Customers
INSERT INTO Customers (Name, Phone, Email, Address, LoyaltyPoints, IsActive)
VALUES
    ('Walk-in',        '01XXXXXXXXX',  'walkin@willows.org',          'Counter Front',         0,   1),
    ('Michael Anderson','+1 555-0301', 'm.anderson@example.com',      '742 Evergreen Terrace', 120, 1),
    ('Emma Watson',     '+1 555-0302', 'e.watson@example.com',        '221B Baker Street',     85,  1);
GO

-- Products  (CategoryId: Pharmacy=6, Beverages=1 | UnitId: PCS=1, ltr=5 | SupplierIds: 1-4)
INSERT INTO Products (SKU, Barcode, Name, GenericName, Description, CategoryId, UnitId, SupplierId, CostPrice, SellingPrice, CurrentStock, MinAlertStock, ImageUrl, IsActive)
VALUES
    ('PH-00001','PH-00001','Montiva 10 Tablet',   'Montelukast',       '10mg chewable / film-coated tablet',         6, 1, 1,   9.17, 16.00,  50, 10, '/uploads/products/pharma-item.svg', 1),
    ('PH-00002','PH-00002','Starcal D Tablet',    'Calcium + Vit D3',  'Calcium 500mg + Vitamin D3 200IU',           6, 1, 1,   5.00,  8.00,   3,  5, '/uploads/products/pharma-item.svg', 1),
    ('PH-00003','PH-00003','Avamist Nasal Spray', 'Fluticasone',       'Metered dose nasal suspension spray',        6, 1, 2, 350.00,450.00,  10,  5, '/uploads/products/pharma-item.svg', 1),
    ('PH-00004','PH-00004','Bilfast Kids Tablet', 'Bilastine',         '10mg orodispersible allergy tablets',        6, 1, 2,  12.00, 18.00,  30, 10, '/uploads/products/pharma-item.svg', 1),
    ('PH-00005','PH-00005','Bilfast Oral Solution','Bilastine 120ml',  '2.5mg/ml antihistamine syrup',               6, 5, 2,  85.00,110.00,   2,  5, '/uploads/products/pharma-item.svg', 1),
    ('PH-00006','PH-00006','Bilfast Tablet',      'Bilastine 20mg',    '20mg non-sedating antihistamine',            6, 1, 2,  14.00, 20.00,  30, 10, '/uploads/products/pharma-item.svg', 1),
    ('PH-00007','PH-00007','Doxiva Syrup',        'Doxofylline',       '100mg/5ml bronchodilator syrup',             6, 5, 3,  65.00, 85.00,   2,  5, '/uploads/products/pharma-item.svg', 1),
    ('PH-00008','PH-00008','Dermasol Oint 20g T', 'Clobetasol',        '0.05% topical corticosteroid ointment',      6, 1, 1,  55.00, 75.50,  25,  5, '/uploads/products/pharma-item.svg', 1),
    ('PH-00009','PH-00009','LOSECTIL 20MG CAP',   'Omeprazole',        '20mg gastro-resistant capsule',              6, 1, 4,   3.50,  5.00, 100, 20, '/uploads/products/pharma-item.svg', 1),
    ('BEV-001', '8901001', 'Coca Cola Can 330ml', 'Carbonated Soft Drink','Classic sparkling soft drink',            1, 1, 1,   0.85,  1.50, 120, 20, '/uploads/products/pharma-item.svg', 1);
GO

-- Purchases
INSERT INTO Purchases (PurchaseNo, SupplierId, PurchaseDate, ReceiveDate, PurchaseOrderNo, TotalQty, SubTotal, DiscountAmount, TotalAmount, PaidAmount, DueAmount, Status, IsPosted)
VALUES
    ('PUR-00037', 1, DATEADD(DAY,-4,GETUTCDATE()), DATEADD(DAY,-4,GETUTCDATE()), 'PO-2026-0037',    4,  2300.00, 0.00,  2300.00,  2300.00, 0.00, 'Posted', 1),
    ('PUR-00036', 2, DATEADD(DAY,-4,GETUTCDATE()), DATEADD(DAY,-4,GETUTCDATE()), 'PO-2026-0036',  710,  7260.10, 0.00,  7260.10,  7260.10, 0.00, 'Posted', 1),
    ('PUR-00035', 3, DATEADD(DAY,-4,GETUTCDATE()), DATEADD(DAY,-4,GETUTCDATE()), 'PO-2026-0035',   10,  2420.20, 0.00,  2420.20,  2420.20, 0.00, 'Posted', 1),
    ('PUR-00034', 4, DATEADD(DAY,-4,GETUTCDATE()), DATEADD(DAY,-4,GETUTCDATE()), 'PO-2026-0034', 1208, 20985.44, 0.00, 20985.44, 20985.44, 0.00, 'Posted', 1);
GO

-- Purchase Items (PH-00008 Id=8, PH-00001 Id=1)
INSERT INTO PurchaseItems (PurchaseId, ProductId, ProductName, ProductCode, Quantity, UnitPrice, TotalAmount)
VALUES
    (1, 8, 'Dermasol Oint 20g T', 'PH-00008',   4, 575.00, 2300.00),
    (2, 1, 'Montiva 10 Tablet',   'PH-00001', 710,  10.22, 7260.10);
GO

-- Sales
INSERT INTO Sales (InvoiceNumber, SaleDate, CustomerId, CustomerType, FundType, SubTotal, TaxRate, TaxAmount, DiscountPercent, DiscountAmount, RoundUp, FinalPayable, GrandTotal, PaidAmount, ChangeAmount, DuesAmount, PaymentMethod, Status, IsPosted)
VALUES
    ('INV-00224', DATEADD(DAY,-1,GETUTCDATE()), 1, 'Walk-in','Cash',  85.50, 0,0, 0,0, 0.50, 85.00,  85.00, 85.00, 0, 0, 'Cash','Completed',1),
    ('INV-00223', DATEADD(DAY,-1,GETUTCDATE()), 1, 'Walk-in','Cash', 288.50, 0,0, 0,0, 0.50,288.00, 288.00,288.00, 0, 0, 'Cash','Completed',1),
    ('INV-00222', DATEADD(DAY,-2,GETUTCDATE()), 1, 'Walk-in','Cash',  24.00, 0,0, 0,0, 0.00, 24.00,  24.00, 24.00, 0, 0, 'Cash','Completed',1),
    ('INV-00221', DATEADD(DAY,-2,GETUTCDATE()), 1, 'Walk-in','Cash', 174.00, 0,0, 0,0, 0.00,174.00, 174.00,174.00, 0, 0, 'Cash','Completed',1);
GO

-- Sale Items (SaleId=1: Dermasol + LOSECTIL)
INSERT INTO SaleItems (SaleId, ProductId, ProductName, CostPrice, UnitPrice, Quantity, SubTotal, DiscountAmount, TotalAmount)
VALUES
    (1, 8, 'Dermasol Oint 20g T', 55.00, 75.50, 1, 75.50, 0, 75.50),
    (1, 9, 'LOSECTIL 20MG CAP',   3.50,   5.00, 2, 10.00, 0, 10.00);
GO

PRINT 'PosInventoryDb created and seeded successfully on DEV-1017.';
GO
