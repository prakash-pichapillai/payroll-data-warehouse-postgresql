# Payroll Data Warehouse & Analytics System (PostgreSQL)

## Overview
This project implements an **enterprise-style payroll data warehouse** using PostgreSQL, designed to support **gross-to-net payroll reconciliation, audit validation, and workforce cost analytics**.

The system models real-world payroll components including **earnings, deductions, taxes, time entries, employees, departments, locations, and pay periods**, enabling analytics commonly required by **HR, Finance, and Audit teams**.

This repository is intentionally built to demonstrate **job-ready SQL skills** using realistic payroll business logic rather than toy datasets.

---

## Business Problem
Payroll data is **high-risk and business-critical**. Errors in payroll processing can result in:
- Compliance violations and audit findings  
- Financial misstatements  
- Employee dissatisfaction and rework  

Organizations require a structured data model and analytical layer to:
- Reconcile **gross pay to net pay**
- Detect **missing or incorrect deductions and taxes**
- Analyze **overtime usage and payroll costs**
- Support **historical, audit-safe reporting**

This project addresses these requirements through a PostgreSQL-based data warehouse and analytics layer.

---

## Payroll Rules & Assumptions
- Payroll is processed by defined pay periods  
- Gross pay is derived from earnings and time entries  
- Net pay = Gross Pay − Deductions − Taxes  
- Payroll data is immutable once a pay period is closed  
- Employees belong to departments, entities, and locations  
- Historical payroll records must remain auditable  

---

## Architecture Overview
**High-level flow:**

Source Systems (HRIS, Payroll, Timekeeping)  
→ Staging / Load Scripts  
→ Payroll Data Warehouse (PostgreSQL)  
→ Analytics & Reporting (SQL Views / BI Tools)

The warehouse is designed for **analytics-first workloads**, not transactional processing.

---

## Data Model Design
The database follows a **fact and dimension (star-schema-inspired) design** to support historical analysis and auditability.

### Fact Tables
- `fact_payroll` – final payroll results per employee and pay period  
- `fact_earnings` – regular and overtime earnings  
- `fact_deductions` – employee deductions by category  
- `fact_taxes` – tax calculations by jurisdiction  
- `fact_time_entry` – regular and overtime hours worked  

### Dimension Tables
- `dim_employee`
- `dim_department`
- `dim_location`
- `dim_entity`
- `dim_company`
- `dim_pay_period`
- `dim_date`

This design:
- Preserves payroll history
- Supports period-over-period analysis
- Enables audit-safe reporting without modifying historical data

An ERD diagram is available in the `/schema` directory.

---

## Key Analytics & Use Cases

### Payroll Reconciliation (Audit Use Case)
Validates payroll accuracy by reconciling gross pay against deductions, taxes, and net pay.

```sql
WITH reconciliation AS (
    SELECT
        employee_id,
        pay_period_id,
        gross_pay,
        total_deductions,
        total_taxes,
        net_pay,
        gross_pay - total_deductions - total_taxes AS calculated_net_pay
    FROM fact_payroll
)
SELECT *
FROM reconciliation
WHERE net_pay <> calculated_net_pay;
```

### Compliance Checks
- Employees paid without mandatory deductions
- Missing tax records by pay period

### Workforce Analytics
- Overtime utilization by department
- Headcount and cost distribution trends

### Payroll Cost Trends
- Payroll spend by location and pay period
- Period-over-period payroll growth

