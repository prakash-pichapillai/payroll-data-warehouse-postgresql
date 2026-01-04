-- Purpose: Track active headcount over time
-- Business Owner: HR
-- Question: How does employee headcount change by pay period?

SELECT
    pp.pay_period_id,
    COUNT(DISTINCT e.employee_id) AS headcount
FROM fact_payroll p
JOIN dim_employee e
    ON p.employee_id = e.employee_id
JOIN dim_pay_period pp
    ON p.pay_period_id = pp.pay_period_id
GROUP BY pp.pay_period_id
ORDER BY pp.pay_period_id;
