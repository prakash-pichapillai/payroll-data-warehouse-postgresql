-- Purpose: Track payroll cost trends by location and period
-- Business Owner: Finance
-- Question: How is payroll spend changing over time by region?

SELECT
    l.country_name,
    dt.year,
    dt.month,
    SUM(p.gross_pay) AS total_gross_pay
FROM fact_payroll p
JOIN dim_employee e
    ON p.employee_id = e.employee_id
JOIN dim_location l
    ON e.location_id = l.location_id
JOIN dim_pay_period pp
    ON p.pay_period_id = pp.pay_period_id
JOIN dim_date dt
    ON pp.pay_date = dt.full_date
GROUP BY l.country_name, dt.year, dt.month
ORDER BY l.country_name, dt.year, dt.month;
