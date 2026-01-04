-- Purpose: Reconcile gross pay to net pay
-- Business Owner: Finance / Audit
-- Risk Addressed: Payroll calculation errors

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
SELECT
    employee_id,
    pay_period_id,
    gross_pay,
    total_deductions,
    total_taxes,
    net_pay,
    calculated_net_pay,
    net_pay - calculated_net_pay AS variance
FROM reconciliation
WHERE net_pay <> calculated_net_pay;
