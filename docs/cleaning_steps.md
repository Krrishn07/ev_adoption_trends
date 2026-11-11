# Data Cleaning & Preparation Steps

This document records the data quality checks and cleaning steps applied to the raw VAHAN vehicle registration dataset before analysis and SQL ingestion.

---

## 1. Raw Dataset Overview
* **Source File**: `data/raw/ev_registrations_raw.csv`
* **Rows / Columns**: `418,372` rows, `9` columns (`id`, `date`, `state_name`, `state_code`, `office_name`, `office_code`, `fuel_type`, `category`, `registrations`)
* **Date Range**: `2019-01-01` to `2024-05-01`
* **Missing Values**: `0` nulls across all columns

---

## 2. Issues Identified During Audit
1. **Business-Key Duplicates**: While exact full-row duplicates were `0`, checking by `(date, state_name, office_name, fuel_type)` found `61` overlapping source records.
2. **Implausible Reporting Outliers**:
   * **Petrol records**: Several RTO offices reported identical corrupted values exceeding `15 million` in March 2020.
   * **EV records**: Certain RTO offices (*Hindupur Rta*, *Sikar Vehicle Fitness Center*, *Lower Siang*) reported `300,000+` EV registrations in a single month, distorting monthly trends and state totals.
3. **Useless Constant Column**: The `category` column held only a single value (`Fuel`) across all rows.
4. **Data Type Issues**:
   * `date` was stored as plain text (`object`).
   * `registrations` was stored as `float64` (`2.0`, `15.0`) instead of whole vehicle counts.

---

## 3. Cleaning Decisions Applied
1. **Filtered for Electric Vehicles**: Isolated pure EVs using `fuel_type` in `['Electric(Bov)', 'Pure Ev']` *(hybrids excluded to keep EV adoption separate)*.
2. **Outlier Cutoff (`<= 10,000`)**: Excluded records exceeding `10,000` registrations per RTO office per month across both EV trend analysis and cross-fuel comparison.
3. **Dropped Redundant Columns**: Removed `category` (constant `'Fuel'`) and temporary `year_month` column so the SQL table remains normalized.
4. **Standardized Data Types**:
   * Converted `date` to datetime / `DATE` (`YYYY-MM-DD`).
   * Cast `registrations` to `int` (`INT` in SQL Server).

---

## 4. Final Cleaned Output
* **Output File**: `data/cleaned/ev_registrations_clean.csv`
* **Cleaned Rows**: `56,486` EV registration records (`4,684,184` total EVs across `34` states/UTs)
* **Columns Exported**: `id, date, state_name, state_code, office_name, office_code, fuel_type, registrations`

