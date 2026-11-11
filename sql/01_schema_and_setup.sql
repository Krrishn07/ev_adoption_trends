-- Database Setup & Initial Checks
-- Project: EV Adoption Trends in India
-- Table: ev_registrations_clean

USE ev_db;
GO

-- 1. Check total rows imported (should be 56,486)
SELECT COUNT(*) AS total_rows
FROM ev_registrations_clean;
GO

-- 2. Preview the first 10 rows
SELECT TOP 10 
    id,
    date,
    state_name,
    office_name,
    fuel_type,
    registrations
FROM ev_registrations_clean
ORDER BY date DESC;
GO

-- 3. Check date range and total EV volume
SELECT 
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    SUM(CAST(registrations AS BIGINT)) AS total_ev_registered,
    COUNT(DISTINCT state_name) AS total_states,
    COUNT(DISTINCT office_name) AS total_rto_offices
FROM ev_registrations_clean;
GO

-- 4. Verify no missing values in key columns
SELECT 
    COUNT(CASE WHEN date IS NULL THEN 1 END) AS missing_dates,
    COUNT(CASE WHEN state_name IS NULL THEN 1 END) AS missing_states,
    COUNT(CASE WHEN registrations IS NULL THEN 1 END) AS missing_registrations
FROM ev_registrations_clean;
GO

-- 5. Add basic indexes on date and state for faster query performance
CREATE INDEX idx_ev_date ON ev_registrations_clean(date);
CREATE INDEX idx_ev_state ON ev_registrations_clean(state_name);
GO
