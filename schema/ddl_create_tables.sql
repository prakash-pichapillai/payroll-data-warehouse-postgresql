-- Parent Company
CREATE TABLE dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name TEXT NOT NULL,
    legal_entity_name TEXT NOT NULL,
    headquarters_country TEXT NOT NULL,
    established_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Business Entities (Divisions)
CREATE TABLE dim_entity (
    entity_id INTEGER PRIMARY KEY,
    company_id INTEGER NOT NULL,
    entity_code TEXT NOT NULL UNIQUE,
    entity_name TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    description TEXT,
    established_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id)
);

-- Locations (Countries and States/Provinces)
CREATE TABLE dim_location (
    location_id INTEGER PRIMARY KEY,
    country_code TEXT NOT NULL,
    country_name TEXT NOT NULL,
    state_province_code TEXT,
    state_province_name TEXT,
    currency_code TEXT NOT NULL,
    timezone TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Departments
CREATE TABLE dim_department (
    department_id INTEGER PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    department_code TEXT NOT NULL,
    department_name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (entity_id) REFERENCES dim_entity(entity_id),
    UNIQUE(entity_id, department_code)
);

-- Employees
CREATE TABLE dim_employee (
    employee_id INTEGER PRIMARY KEY,
    employee_number TEXT NOT NULL UNIQUE,
    entity_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    termination_date DATE,
    employment_status TEXT NOT NULL CHECK(employment_status IN ('Active', 'Terminated', 'On Leave')),
    employment_type TEXT NOT NULL CHECK(employment_type IN ('Full-Time', 'Part-Time', 'Contract')),
    job_title TEXT NOT NULL,
    job_level TEXT NOT NULL,
    manager_id INTEGER,
    annual_salary DECIMAL(15,2) NOT NULL,
    pay_frequency TEXT NOT NULL CHECK(pay_frequency IN ('Bi-Weekly', 'Monthly')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (entity_id) REFERENCES dim_entity(entity_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (manager_id) REFERENCES dim_employee(employee_id)
);

-- Date Dimension
CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    week INTEGER NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name TEXT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL,
    holiday_name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pay Periods
CREATE TABLE dim_pay_period (
    pay_period_id INTEGER PRIMARY KEY,
    location_id INTEGER NOT NULL,
    pay_frequency TEXT NOT NULL CHECK(pay_frequency IN ('Bi-Weekly', 'Monthly')),
    period_number INTEGER NOT NULL,
    period_year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    UNIQUE(location_id, pay_frequency, period_year, period_number)
);

-- Time Entries Fact
CREATE TABLE fact_time_entry (
    time_entry_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,
    regular_hours DECIMAL(5,2) NOT NULL DEFAULT 0,
    overtime_hours DECIMAL(5,2) NOT NULL DEFAULT 0,
    total_hours DECIMAL(5,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES dim_pay_period(pay_period_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    UNIQUE(employee_id, date_id)
);

-- Earnings Fact
CREATE TABLE fact_earnings (
    earning_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    earning_type TEXT NOT NULL CHECK(earning_type IN ('Regular Pay', 'Overtime Pay')),
    hours DECIMAL(5,2),
    rate DECIMAL(15,2) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency_code TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES dim_pay_period(pay_period_id)
);

-- Deductions Fact
CREATE TABLE fact_deductions (
    deduction_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    deduction_type TEXT NOT NULL CHECK(deduction_type IN ('Health Insurance', '401k', 'Retirement', 'Superannuation', 'RRSP')),
    deduction_category TEXT NOT NULL CHECK(deduction_category IN ('Pre-Tax', 'Post-Tax')),
    amount DECIMAL(15,2) NOT NULL,
    currency_code TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES dim_pay_period(pay_period_id)
);

-- Taxes Fact
CREATE TABLE fact_taxes (
    tax_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    tax_type TEXT NOT NULL,
    tax_jurisdiction TEXT NOT NULL CHECK(tax_jurisdiction IN ('Federal', 'State', 'Provincial', 'National')),
    taxable_income DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,4),
    tax_amount DECIMAL(15,2) NOT NULL,
    currency_code TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES dim_pay_period(pay_period_id)
);

-- Payroll Summary Fact
CREATE TABLE fact_payroll (
    payroll_id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    gross_pay DECIMAL(15,2) NOT NULL,
    total_deductions DECIMAL(15,2) NOT NULL,
    total_taxes DECIMAL(15,2) NOT NULL,
    net_pay DECIMAL(15,2) NOT NULL,
    currency_code TEXT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method TEXT NOT NULL CHECK(payment_method IN ('Direct Deposit', 'Check', 'Wire Transfer')),
    payment_status TEXT NOT NULL CHECK(payment_status IN ('Pending', 'Processed', 'Paid', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES dim_pay_period(pay_period_id),
    UNIQUE(employee_id, pay_period_id)
);
