-- Purpose: Improve query performance for payroll analytics

CREATE INDEX idx_employee_entity ON dim_employee(entity_id);
CREATE INDEX idx_employee_department ON dim_employee(department_id);
CREATE INDEX idx_employee_location ON dim_employee(location_id);
