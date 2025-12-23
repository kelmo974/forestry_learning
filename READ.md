

# 🌲 Tennessee Forest Canopy Height: ML & Spatial ETL

> **Project Goal:** Aligning USFS FIA ground survey data with satellite canopy height rasters to create a robust, ML-ready dataset for biomass modeling.

---

## 📖 Project Overview

*Briefly describe the "Why" here. For example:*
This project addresses the gap between ground-level forestry inventory and high-resolution satellite height models. By joining thousands of tree-level measurements with spatial rasters, we are building a model to predict forest structure across the state of Tennessee.

---

## 🛠 Tech Stack & Libraries

### **Database & GIS**

* **PostgreSQL / PostGIS:** Used for spatial joins, coordinate transformations, and data indexing.
* **pgAdmin 4:** Database management and query visualization.

### **Python Libraries**

* `pandas`: Data manipulation and Excel/CSV ingestion.
* `sqlalchemy`: Postgres database connection and ETL.
* `openpyxl`: Excel engine for reading master species lists.
* `XGBoost` / `Scikit-Learn`: (Planned) For predictive modeling.

---

## 🏗 Data Pipeline & Architecture

The data flows through three logical layers in our Postgres schema:

1. **Bronze (Raw):** Direct imports of `TN_PLOT`, `TN_TREE`, and `TN_COND` CSVs.

<p>align='center'><img src='project_screenshots/raw_tabular_in_postgres.png' width ='500' /></p>

2. **Silver (Cleaned):** Type-casted columns, geometry creation, and spatial indexing.
3. **Gold (ML-Ready):** Final view joining trees to rasters with data quality flags.

### **Database Schema Preview**

---

## 🚧 Roadblocks & Solutions

| Roadblock | Resolution |
| --- | --- |
| **Case-Sensitivity Errors:** Postgres failing on uppercase CSV headers (e.g., `"CONDID"`). | Developed a dynamic SQL script to batch-rename all columns to lowercase. |
| **Data Type Mismatches:** Integer columns containing strings like `"972.0"`. | Implemented a two-step casting process: `::numeric::int` to strip decimals during ETL. |
| **Query Performance:** Spatial joins taking minutes to return only a few rows. | Created **GIST Spatial Indexes** on the plot geometries and raster convex hulls. |
| **Temporal Discrepancy:** Comparing 1980s ground data to 2020 satellite imagery. | Filtered dataset for `invyr >= 2015` and added a QA flagging system. |

---

## 📊 Quality Assurance (Bonus Task)

We implemented a dynamic flagging system to ensure the ML model only trains on high-integrity data.

* **EXCLUDE_NO_RASTER:** Plot falls outside satellite tile coverage.
* **EXCLUDE_EXTREME_OUTLIER:** >70ft difference between ground and space (potential sensor noise).
* **EXCLUDE_POTENTIAL_CHANGE:** Likely harvest detected between 2020 and 2025.

### **QA Flag Distribution**

---

## 🚀 Getting Started

1. Clone the repo.
2. Ensure PostGIS is enabled on your local database.
3. Run `etl_scripts/01_import_species.py` to populate the reference table.
4. Execute the SQL views found in `sql/v_gold_ml_ready.sql`.

---

### Pro-Tips for your Screenshots:

* **The "Hero" Shot:** Take a screenshot of your `v_gold_ml_ready` view in pgAdmin showing the `tree_name`, `field_ht_ft`, and `sat_ht_ft` side-by-side.
* **Performance:** Include a screenshot of the "Query Tool" message showing the `0.8s` execution time to prove your optimization work!

