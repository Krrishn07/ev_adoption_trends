-- Business Analysis Queries
-- Project: EV Adoption Trends in India
-- Database: ev_db

USE ev_db;
GO


-- 1. How fast are EV registrations growing year-over-year (YoY)?
-- We use LAG() to compare each year's volume with the previous year.

WITH yearly_totals AS (
    SELECT 
        YEAR(date) AS reg_year,
        SUM(CAST(registrations AS BIGINT)) AS total_ev
    FROM ev_registrations_clean
    GROUP BY YEAR(date)
)
SELECT 
    reg_year,
    total_ev,
    LAG(total_ev) OVER (ORDER BY reg_year) AS prev_year_ev,
    total_ev - LAG(total_ev) OVER (ORDER BY reg_year) AS yoy_change,
    CAST(
        ROUND(
            (total_ev - LAG(total_ev) OVER (ORDER BY reg_year)) * 100.0 / 
            LAG(total_ev) OVER (ORDER BY reg_year), 
            2
        ) AS DECIMAL(10, 2)
    ) AS yoy_growth_pct
FROM yearly_totals
ORDER BY reg_year;
GO


-- 2. Which states were the top 3 EV leaders for each year?
-- Using DENSE_RANK() with PARTITION BY to see how state rankings shifted.

WITH state_ranks AS (
    SELECT 
        YEAR(date) AS reg_year,
        state_name,
        SUM(CAST(registrations AS BIGINT)) AS total_ev,
        DENSE_RANK() OVER (
            PARTITION BY YEAR(date) 
            ORDER BY SUM(CAST(registrations AS BIGINT)) DESC
        ) AS rank_in_year
    FROM ev_registrations_clean
    GROUP BY YEAR(date), state_name
)
SELECT 
    reg_year,
    rank_in_year,
    state_name,
    total_ev
FROM state_ranks
WHERE rank_in_year <= 3
ORDER BY reg_year, rank_in_year;
GO


-- 3. What is the nationwide cumulative running total of EV sales?
-- Uses SUM() OVER to show month-by-month adoption scaling across India.

WITH monthly_totals AS (
    SELECT 
        date,
        FORMAT(date, 'yyyy-MM') AS month_label,
        SUM(CAST(registrations AS BIGINT)) AS monthly_ev
    FROM ev_registrations_clean
    GROUP BY date
)
SELECT 
    month_label,
    monthly_ev,
    SUM(monthly_ev) OVER (ORDER BY date) AS cumulative_ev
FROM monthly_totals
ORDER BY date;
GO


-- 4. Which single RTO office / city has the highest EV volume in each state?
-- Using ROW_NUMBER() partitioned by state to identify key local hubs.

WITH rto_totals AS (
    SELECT 
        state_name,
        office_name,
        SUM(CAST(registrations AS BIGINT)) AS total_ev,
        ROW_NUMBER() OVER (
            PARTITION BY state_name 
            ORDER BY SUM(CAST(registrations AS BIGINT)) DESC
        ) AS rto_rank
    FROM ev_registrations_clean
    GROUP BY state_name, office_name
)
SELECT 
    state_name,
    office_name AS top_rto_office,
    total_ev
FROM rto_totals
WHERE rto_rank = 1
ORDER BY total_ev DESC;
GO


-- 5. How concentrated is the market? Top 5 states vs Rest of India
-- Calculates the combined market share percentage of the top 5 states.

WITH state_summary AS (
    SELECT 
        state_name,
        SUM(CAST(registrations AS BIGINT)) AS state_ev,
        DENSE_RANK() OVER (ORDER BY SUM(CAST(registrations AS BIGINT)) DESC) AS overall_rank
    FROM ev_registrations_clean
    GROUP BY state_name
),
grouped_market AS (
    SELECT 
        CASE 
            WHEN overall_rank <= 5 THEN state_name
            ELSE 'Rest of India'
        END AS market_segment,
        state_ev
    FROM state_summary
)
SELECT 
    market_segment,
    SUM(state_ev) AS total_ev,
    CAST(
        ROUND(SUM(state_ev) * 100.0 / (SELECT SUM(CAST(registrations AS BIGINT)) FROM ev_registrations_clean), 2) 
        AS DECIMAL(10, 2)
    ) AS market_share_pct
FROM grouped_market
GROUP BY market_segment
ORDER BY total_ev DESC;
GO
