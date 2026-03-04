# E-Commerce Order and Inventory Management System

## Project Overview
This repository contains a highly normalized, robust SQL Server database architecture designed to manage e-commerce operations, dynamic inventory tracking, and order processing. The primary focus of this project is to demonstrate advanced database concepts, including strict concurrency control, ACID-compliant transaction management, data integrity enforcement, and query performance tuning.

## Database Architecture
The schema is designed in Third Normal Form (3NF) to separate logical business domains: Users, Products, Categories, Warehouses, and Order Lifecycles. An independent Audit Log table is implemented to track historical data mutations without interfering with core referential integrity constraints.

![ER Diagram](screenshots/Diagram.jpeg)

## Core Technical Implementations

### Concurrency Control and Lock Management
In high-traffic e-commerce environments, race conditions can lead to overselling stock. This project mitigates these risks using explicit locking hints and transactional scopes:
* **UPDLOCK & ROWLOCK:** Used during order placement to serialize access to inventory records. This ensures that simultaneous read-and-update operations do not result in lost updates. The deduction logic is executed atomically within the UPDATE statement's WHERE clause.
* **XLOCK:** Applied during order cancellations to gain an exclusive lock on the order row, completely preventing simultaneous overlapping status modifications (e.g., attempting to cancel and ship an order concurrently).
* **SERIALIZABLE & HOLDLOCK:** Implemented for generating consistent, point-in-time inventory reports, guaranteeing protection against phantom reads while the report aggregates data across multiple tables.

### Business Logic and Data Integrity
* **Strict State-Machine:** Order status transitions (Pending -> Confirmed -> Shipped / Canceled) are strictly governed by procedural logic. Invalid state transitions trigger a transaction rollback.
* **Cascading Inventory Restoration:** Canceled orders automatically restore the reserved stock to the exact warehouse origin, mapped historically in the order details.
* **Resilient Replenishment (UPSERT):** Warehouse restocking utilizes conditional logic alongside SAVE TRANSACTION points. If a delivery update fails for one specific warehouse, the database performs a partial rollback, allowing the rest of the batch to commit successfully.
* **Trigger-Based Auditing:** AFTER INSERT/UPDATE triggers automatically maintain an immutable audit trail for price changes, stock movements, and order status updates. INSTEAD OF DELETE triggers protect relational integrity by preventing the removal of products tied to active orders.

## Performance Tuning
To optimize reporting queries (such as filtering orders by specific operational statuses), execution plans were analyzed to eliminate expensive table scans. 

By implementing a Nonclustered Covering Index that includes frequently accessed columns (Client ID, Date, Total Value), the SQL Server Query Optimizer transitioned from a resource-intensive Clustered Index Scan to a highly efficient Index Seek, bypassing Key Lookups.

**Execution Plan Before Indexing (Clustered Index Scan - High Cost)**
![Execution Plan Before](screenshots/index_scan_before.jpeg)

**Execution Plan After Indexing (Index Seek - Optimized)**
![Execution Plan After](screenshots/index_seek_after.jpeg)

## Repository Structure
The project is modularized for clarity and maintainability:
* `Proiect_ECommerce.sql` - The unified, single-file script for quick deployment and execution.
* `01_creare_tabele.sql` - Data Definition Language (DDL) for the core schema.
* `02_foreign_keys.sql` - Constraints and Foreign Keys.
* `03_populate_tables.sql` - Initial data population.
* `04_index.sql` - Performance optimization indexes.
* `05_views.sql` - Reporting views utilizing Window Functions.
* `06_triggers.sql` - Data validation and auditing triggers.
* `07_procedures.sql` - Stored procedures handling transactions and locks.
* `08_demo.sql` - Execution script demonstrating the business workflows.

## Execution Guide
1. Open SQL Server Management Studio (SSMS).
2. Open the `Proiect_ECommerce.sql` script or execute the individual scripts in the `sql` directory in numerical order.
3. Run the commands in `08_demo.sql` to observe the transactions, lock management, and audit logging in real-time.
