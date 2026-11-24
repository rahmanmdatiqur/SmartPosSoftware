# SmartPOS & Inventory Management System (.NET MVC)
## Architecture, Database Schema, RBAC & Deployment Documentation

---

## 1. Executive System Overview

The **SmartPOS & Inventory Management System** is an enterprise-grade retail and inventory management application engineered with **C# ASP.NET Core (MVC)**, **Entity Framework Core**, **SQL Server**, and **Razor Views**.

The system addresses the end-to-end retail lifecycle:
- **POS Checkout Terminal**: High-speed counter interface supporting barcode scanning, live search, automatic cart calculations (VAT/Tax, Discounts), multi-tender payments (Cash, Card, Mobile Banking), and 80mm thermal receipt printing.
- **Inventory & Warehouse Management**: Multi-category product catalog with barcode assignment, stock reorder thresholds, quick stock replenishment (Stock In), physical audit stock adjustments, and a complete audit ledger.
- **Dynamic RBAC (Role-Based Access Control)**: Granular **User × Role × Page Permission** matrix enabling administrators to toggle View, Create, Edit, and Delete privileges per module/screen dynamically from the UI.
- **Business Intelligence & Reporting**: Real-time sales metrics, top-selling items, cash/card payment distributions, and low-stock alerts.

```
┌─────────────────────────────────────────────────────────────┐
│                    ASP.NET Core MVC                         │
│     (Controllers, Razor Views, Cookie Auth, Session)        │
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
┌──────────────▼──────────────┐ ┌──────────────▼──────────────┐
│       POS & Inventory       │ │      Dynamic RBAC Core      │
│  - Barcode Scanning         │ │  - AppUser & AppRole        │
│  - Real-time Calculations   │ │  - AppModulePage Catalog    │
│  - Thermal 80mm Receipt     │ │  - RolePermission Matrix    │
│  - Stock Audit Ledger       │ │  - AuthorizePermissionFilter│
└──────────────┬──────────────┘ └──────────────┬──────────────┘
               │                               │
               └───────────────┬───────────────┘
                               │
               ┌───────────────▼───────────────┐
               │    ApplicationDbContext       │
               │   (EF Core + SQL Server)      │
               └───────────────┬───────────────┘
                               │
               ┌───────────────▼───────────────┐
               │       PosInventoryDb          │
               │  (14 Normalized SQL Tables)   │
               └───────────────────────────────┘
```

---

## 2. Pre-Configured Master Data & Demo Credentials

| Username | Password | Role | Access Scope |
|---|---|---|---|
| `admin` | `Admin@123` | **SuperAdmin** | Full unrestricted root access across all modules, users, and permission matrix |
| `cashier` | `Cashier@123` | **Cashier** | POS Terminal checkout, Sales Invoices, Customer registration, Dashboard |
| `manager` | `Manager@123` | **InventoryManager** | Stock Overview, Physical Adjustments, Audit Log, Product Catalog, Reports |
