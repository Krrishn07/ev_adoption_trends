# EV Adoption Trends in India (2019–2024)

A data analysis project using **Python** and **Microsoft SQL Server** to track Electric Vehicle (EV) registration growth across India from January 2019 to May 2024 (VAHAN dataset).

---

## Project Approach

* **Python (`ev_adoption_analysis.ipynb`)**: Audited 418,372 raw rows, removed reporting outliers, compared EVs against Petrol/Diesel/CNG, and exported a clean EV dataset.
* **SQL Server (`sql/`)**: Imported the cleaned EV data (`56,486` rows, `4.68M` total EVs) and wrote analytical queries using CTEs and Window Functions (`LAG`, `DENSE_RANK`, `ROW_NUMBER`).

---

## Project Structure

```text
ev_adoption_trends/
├── data/
│   ├── raw/ev_registrations_raw.csv        # Raw VAHAN dataset (all fuel types)
│   └── cleaned/ev_registrations_clean.csv  # Cleaned EV records exported for SQL
├── python/ev_adoption_analysis.ipynb       # EDA, data cleaning & visualizations
├── sql/
│   ├── 01_schema_and_setup.sql             # Verification, NULL checks & indexes
│   └── 02_business_queries.sql             # 5 core EV adoption queries
├── docs/
│   └── cleaning_steps.md                   # Detailed data audit & cleaning log
└── README.md
```

---

## Data Cleaning Highlights

* **Outlier Removal**: Excluded implausible RTO spikes (`>10,000` registrations/month per office, such as *Hindupur RTA* and *Sikar Vehicle Fitness Center*).
* **Schema Cleanup**: Dropped the constant `category` column, formatted `date` as `DATE`, and cast `registrations` from `float` to `INT`.

---

## Key Findings

* **Accelerating Growth**: EV registrations surged **+185.7% in 2022** and **+48.7% in 2023**, peaking in **March 2024** (`217,765` registrations in one month).
* **Faster Milestones**: Reaching the 1st million EVs took **33 months**; reaching the 4th million took just **7 months**.
* **Top 5 States Hold 52.3% Share**: *Uttar Pradesh, Maharashtra, Rajasthan, Tamil Nadu,* and *Karnataka* account for over half of all EV registrations.
* **Fuel Market Context**: Petrol and Diesel still dominate total historical volume, but EVs are the fastest-growing segment.

---

## Recommendations

* **Focus Charging Networks**: Prioritize fast chargers in top-volume state corridors and leading RTO hubs (*Pune, Lucknow, Surat, Bengaluru South, Dwarka*).
* **Support Lagging States**: Introduce targeted state incentives across the remaining 29 states/UTs sharing `47.7%` of the market.
* **Plan for Fiscal Peaks**: Align inventory with recurring year-end spikes (e.g., March).

---

## Limitations

* Dataset covers **Jan 2019 – May 2024** (so 2024 reflects 5 months only).
* Measures new vehicle registrations, not total active vehicles on the road.
* Excludes external factors like charging infrastructure, income, or 2W/3W/4W vehicle splits.

---

## How to Run

1. **Python**: Run [`python/ev_adoption_analysis.ipynb`](python/ev_adoption_analysis.ipynb) to view plots and regenerate the clean CSV.
2. **SQL Server**: Import `data/cleaned/ev_registrations_clean.csv` into database `ev_db` (with `date` as `DATE` and `registrations` as `INT`), then execute [`01_schema_and_setup.sql`](sql/01_schema_and_setup.sql) and [`02_business_queries.sql`](sql/02_business_queries.sql).
