/* ============================================================
   File: ddl_constraints_indexes.sql
   Purpose: Enforce data integrity and improve query performance
   Database: PostgreSQL
   ============================================================ */

---------------------------------------------------------------
-- PRIMARY KEYS
---------------------------------------------------------------

ALTER TABLE dim_employee
    ADD CONSTRAINT pk_dim_employee PRIMARY KEY (employee_id);

ALTER TABLE dim_department
    ADD CONSTRAINT pk_dim_department PRIMARY KEY (department_id);

ALTER TABLE dim_location
    ADD CONSTRAINT pk_dim_location PRIMARY KEY (location_id);

ALTER TABLE dim_entity
    ADD CONSTRAINT pk_dim_entity PRIMARY KEY (entity_id);

ALTER TABLE dim_company
    ADD CONSTRAINT pk_dim_company PRIMARY KEY (company_id);

ALTER TABLE dim_pay_period
    ADD CONSTRAINT pk_dim_pay_period PRIMARY KEY (pay_period_id);

ALTER TABLE dim_date
    ADD CONSTRAINT pk_dim_date PRIMARY KEY (full_date);

ALTER TABLE fact_payroll
    ADD CONSTRAINT pk_fact_payroll PRIMARY KEY (payroll_id);

---------------------------------------------------------------
-- FOREIGN KEYS (REFERENTIAL INTEGRITY)
---------------------------------------------------------------

ALTER TABLE fact_payroll
    ADD CONSTRAINT fk_payroll_employee
    FOREIGN KEY (employee_id)
    REFERENCES dim_employee (employee_id);

ALTER TABLE fact_payroll
    ADD CONSTRAINT fk_payroll_pay_period
    FOREIGN KEY (pay_period_id)
    REFERENCES dim_pay_period (pay_period_id);

ALTER TABLE fact_earnings
    ADD CONSTRAINT fk_earnings_employee
    FOREIGN KEY (employee_id)
    REFERENCES dim_employee (employee_id);

ALTER TABLE fact_earnings
    ADD CONSTRAINT fk_earnings_pay_period
    FOREIGN KEY (pay_period_id)
    REFERENCES dim_pay_period (pay_period_id);

ALTER TABLE fact_deductions
    ADD CONSTRAINT fk_deductions_employee
    FOREIGN KEY (employee_id)
    REFERENCES dim_employee (employee_id);

ALTER TABLE fact_deductions
    ADD CONSTRAINT fk_deductions_pay_period
    FOREIGN KEY (pay_period_id)
    REFERENCES dim_pay_period (pay_period_id);

ALTER TABLE fact_taxes
    ADD CONSTRAINT fk_taxes_employee
    FOREIGN KEY (employee_id)
    REFERENCES dim_employee (employee_id);

ALTER TABLE fact_taxes
    ADD CONSTRAINT fk_taxes_pay_period
    FOREIGN KEY (pay_period_id)
    REFERENCES dim_pay_period (pay_period_id);

ALTER TABLE fact_time_entry
    ADD CONSTRAINT fk_time_employee
    FOREIGN KEY (employee_id)
    REFERENCES dim_employee (employee_id);

ALTER TABLE fact_time_entry
    ADD CONSTRAINT fk_time_pay_period
    FOREIGN KEY (pay_period_id)
    REFERENCES dim_pay_period (pay_period_id);

---------------------------------------------------------------
-- CHECK CONSTRAINTS (BUSINESS RULES)
---------------------------------------------------------------

-- Payroll amounts must not be negative
ALTER TABLE fact_payroll
    ADD CONSTRAINT chk_payroll_amounts_non_negative
    CHECK (
        gross_pay >= 0
        AND net_pay >= 0
        AND total_deductions >= 0
        AND total_taxes >= 0
    );

-- Net pay should not exceed gross pay
ALTER TABLE fact_payroll
    ADD CONSTRAINT chk_net_less_than_gross
    CHECK (net_pay <= gross_pay);

-- Time entries must be non-negative
ALTER TABLE fact_time_entry
    ADD CONSTRAINT chk_time_hours_non_negative
    CHECK (
        regular_hours >= 0
        AND overtime_hours >= 0
        AND total_hours >= 0
    );

---------------------------------------------------------------
-- UNIQUE CONSTRAINTS (DATA QUALITY)
---------------------------------------------------------------

-- One payroll result per employee per pay period
ALTER TABLE fact_payroll
    ADD CONSTRAINT uq_payroll_employee_period
    UNIQUE (employee_id, pay_period_id);

---------------------------------------------------------------
-- INDEXES (QUERY PERFORMANCE)
---------------------------------------------------------------

-- Fact table join and filter optimization
CREATE INDEX idx_fact_payroll_employee
    ON fact_payroll (employee_id);

CREATE INDEX idx_fact_payroll_pay_period
    ON fact_payroll (pay_period_id);

CREATE INDEX idx_fact_payroll_employee_period
    ON fact_payroll (employee_id, pay_period_id);

CREATE INDEX idx_fact_time_entry_employee
    ON fact_time_entry (employee_id);

CREATE INDEX idx_fact_time_entry_pay_period
    ON fact_time_entry (pay_period_id);

-- Dimension filtering
CREATE INDEX idx_dim_employee_department
    ON dim_employee (department_id);

CREATE INDEX idx_dim_employee_location
    ON dim_employee (location_id);

---------------------------------------------------------------
-- END OF FILE
---------------------------------------------------------------
