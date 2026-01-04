-- Purpose: Reconcile gross pay to net pay
-- Business Owner: Finance / Audit
-- Risk Addressed: Payroll calculation and processing errors
-- Notes: Allows for rounding tolerance to avoid false positives

WITH payroll_reconciliation AS (
    SELECT
        p.employee_id,
        p.pay_period_id,
        p.gross_pay,
        COALESCE(p.total_deductions, 0) AS total_deductions,
        COALESCE(p.total_taxes, 0) AS total_taxes,
        p.net_pay,
        ROUND(
            p.gross_pay
            - COALESCE(p.total_deductions, 0)
            - COALESCE(p.total_taxes, 0),
            2
        ) AS calculated_net_pay
    FROM fact_payroll p
)
SELECT
    employee_id,
    pay_period_id,
    gross_pay,
    total_deductions,
    total_taxes,
    net_pay,
    calculated_net_pay,
    ROUND(net_pay - calculated_net_pay, 2) AS variance
FROM payroll_reconciliation
WHERE ABS(net_pay - calculated_net_pay) > 0.01
ORDER BY pay_period_id, employee_id;
