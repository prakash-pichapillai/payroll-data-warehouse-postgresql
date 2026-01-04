-- Indexes for performance
CREATE INDEX idx_employee_entity ON dim_employee(entity_id);
CREATE INDEX idx_employee_department ON dim_employee(department_id);
CREATE INDEX idx_employee_location ON dim_employee(location_id);
CREATE INDEX idx_employee_status ON dim_employee(employment_status);
CREATE INDEX idx_pay_period_dates ON dim_pay_period(start_date, end_date);
CREATE INDEX idx_time_entry_employee ON fact_time_entry(employee_id);
CREATE INDEX idx_time_entry_period ON fact_time_entry(pay_period_id);
CREATE INDEX idx_earnings_employee ON fact_earnings(employee_id);
CREATE INDEX idx_earnings_period ON fact_earnings(pay_period_id);
CREATE INDEX idx_deductions_employee ON fact_deductions(employee_id);
CREATE INDEX idx_deductions_period ON fact_deductions(pay_period_id);
CREATE INDEX idx_taxes_employee ON fact_taxes(employee_id);
CREATE INDEX idx_taxes_period ON fact_taxes(pay_period_id);
CREATE INDEX idx_payroll_employee ON fact_payroll(employee_id);
CREATE INDEX idx_payroll_period ON fact_payroll(pay_period_id);
