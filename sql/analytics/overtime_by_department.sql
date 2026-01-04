-- Purpose: Analyze overtime dependency by department
-- Business Owner: HR / Operations
-- Question: Which departments rely heavily on overtime?

SELECT
    d.department_name,
    ROUND(
        SUM(te.overtime_hours) /
        NULLIF(SUM(te.total_hours), 0) * 100,
        2
    ) AS overtime_percentage
FROM fact_time_entry te
JOIN dim_employee e
    ON te.employee_id = e.employee_id
JOIN dim_department d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY overtime_percentage DESC;
