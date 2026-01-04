-- Purpose: Identify employees paid without deductions
-- Business Owner: Compliance / Payroll
-- Risk Addressed: Statutory deduction non-compliance

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    p.pay_period_id,
    p.gross_pay
FROM fact_payroll p
JOIN dim_employee e
    ON p.employee_id = e.employee_id
LEFT JOIN fact_deductions d
    ON p.employee_id = d.employee_id
   AND p.pay_period_id = d.pay_period_id
WHERE d.deduction_id IS NULL
  AND p.gross_pay > 0;
