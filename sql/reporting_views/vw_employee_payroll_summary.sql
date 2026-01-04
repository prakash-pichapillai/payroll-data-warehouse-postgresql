-- Purpose: Simplified payroll view for reporting and analytics

CREATE OR REPLACE VIEW vw_employee_payroll_summary AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    l.country_name,
    p.pay_period_id,
    p.gross_pay,
    p.total_deductions,
    p.total_taxes,
    p.net_pay
FROM fact_payroll p
JOIN dim_employee e ON p.employee_id = e.employee_id
JOIN dim_department d ON e.department_id = d.department_id
JOIN dim_location l ON e.location_id = l.location_id;
