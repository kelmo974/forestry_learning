# Tennessee Forest Canopy Height: Spatial and Tabular ETL to Feed Machine Learning Model

> **Project Objective:** Create compatibility between ground survey forest data and satellite canopy height rasters to fuel a robust, ML-ready dataset for biomass modeling. We want the model to identify potential beetle killoffs, storm damage, or even illegal deforestation.

---

## Overview

This project addresses the gap between ground-level forestry inventory and satellite canopy height models. By joining thousands of tree measurements captured in the field with with spatial rasters, we can build a model to predict forest structure across the state of Tennessee. 

Sourcing and storing the raw data was critical to provide a solid foundation prior to performing any type of analysis. A database was created in PostgresSQL to house this information.

Tabular data was obtained from the Forest Inventory and Analysis DataMart provided by the U.S. Department of Agriculture. Information regarding the plot of land, condition of the land, and field surveys of trees were of particular interest to this query, so three applicable tables were downloaded from the FIA DataMart. A fourth table, containing the master list of tree species, would later be included from the same source. That raw data can be found here: [FIA DataMart](https://research.fs.usda.gov/products/dataandtools/fia-datamart)

To make a comparison to remote sensing data and demonstrate competency working with raster data, canopy height measurements captured with LiDAR instrumentation at a resolution of 10-m were sourced to then be combined with the tabular data from Tennessee forests. The canopy height data was compiled by EcoVision Lab at the ETH Zurich. The following link offers further details on their research and access to the datasets: [ETH Zurich](https://prs.igp.ethz.ch/research/completed_projects/automated_large-scale_high_carbon_stock.html)

The sourced data was cleaned using Python (Pandas) and imported to Postgres via a separate Python script built on SQLalchemy.

The raw data in PostgreSQL was then passed through Postgis extenstion fucntions so that raster data could be pinned to the existing tabular data. 

With the remote sensing data aligned with the field survey information, query logic was used to build a table that fuels a machine learning model. The key to doing this was calculating an additional field that compares survey dates to raster imaging dates. This will enable the model to make decisions based on available parameters across time. 

A final SQL output titled ml_training_data_dominant containing over 10,000 meaningful records engineered to fuel model features was ingested back into a python environment. 

Performed some light exploratory data analysis just to see if any basic trends were evident. Created a bar chart showing which species had the highest count of 'disturbed' classification. Created a box chart to make sure that filtering for survey data greater than or equal to 2015 was correct under both 'stable' and disturbed categories.

Leaning on XGBoost and Scikit learn, a model was designed and trained on ml_training_data_dominant. The common_names of species was shifted to a target encoded variable. This isn't as reliable as adding a factor like species risk, based on known susceptibility of different tree species to various disturbances. This was a crucial step though, as training on strings is not possible in XGboost. Model execution was successful. A confusion matrix as well as the general confidence performance metrics like precision, recall, and an f-1 score were catalogued. 

The script also succeeded in saving a backup of the SQL table ingested to feed the model. 

To move this from a blackbox script into more of an actionable product, an audit list was generated and also saved into the /data folder. This .csv contains the plot_id values of false positives for disturbed records that the model was able to identify. 
---

## Tech Stack & Libraries

### **Database & GIS**
* **PostgreSQL / PostGIS:** Used for spatial joins, coordinate transformations, and data indexing.
* **pgAdmin 4:** Database management and query visualization.

### **Python Libraries**
* `pandas`: Data manipulation and ingestion of .csv/.xslx files
* `sqlalchemy`: Postgres database connection and ETL.
* `XGBoost` / `Scikit-Learn`: Predictive modeling
* `matplotlib` / `seaborn` : EDA and vizualization tools.

---

## Data Pipeline & Architecture

<p align="left">
  <h3>1. New database and schema created in PostgreSQL</h3>
  <img src="project_screenshots/alter_db_query.png" width="70%" />
</p>

<p align="left">
  <h3>2. Source data downloaded from FIA and ETH domains</h3>
  <ul>
    <li><a href="https://research.fs.usda.gov/products/dataandtools/fia-datamart">FIA DataMart</a></li>
    <li><a href="https://prs.igp.ethz.ch/research/completed_projects/automated_large-scale_high_carbon_stock.html">ETH Zurich</a></li>
  </ul>
</p>

<p align="left">
  <h3>3. Raw data files used to create dataframes in Pandas</h3>
  <img src="project_screenshots/csv_to_dataframe.png" width="70%" />
</p>

<p align="left">
  <h3>4. Pandas used to drop and/or alter column names</h3>
  <img src="project_screenshots/drop_columns.png" width="70%" />
</p>

<p align="left">
  <h3>5. SQLalchemy initializes the engine and loads the dataset</h3>
  <img src="project_screenshots/sqlAlchemy_engine.png" width="70%" /><br><br>
  <img src="project_screenshots/tn_tree_proof.png" width="70%" />
</p>

<p align="left">
  <h3>6. Terminal command used to import all .tif files</h3>
  <img src="project_screenshots/raster_terminal_command.png" width="70%" />
</p>

<p align="left">
  <h3>7. PostGIS extension and indexing</h3>
  <table style="width: 100%; border-collapse: collapse;">
    <tr style="border: none;">
      <th style="text-align: center; border: none;">Raster-specific Extension</th>
      <th style="text-align: center; border: none;">Transform Raster</th>
      <th style="text-align: center; border: none;">Index Geometry</th>
    </tr>
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><img src="project_screenshots/raster_ext_install.png" style="width: 100%;" /></td>
      <td style="width: 33%; border: none;"><img src="project_screenshots/postGIS_raster_transform.png" style="width: 100%;" /></td>
      <td style="width: 33%; border: none;"><img src="project_screenshots/index_geom.png" style="width: 100%;" /></td>
    </tr>
  </table>
</p>

<p align="left">
  <h3>8. Create ML schema</h3>
  <img src="project_screenshots/drop_create_schemas.png" width="70%" />
</p>

<p align="left">
  <h3>9. Joins and SQL logic for ML table creation</h3>
  <img src="project_screenshots/create_ranked_ml_ready.png" width="70%" />
</p>


<p align="left">
  <h3>10. Reconnect to PostgrSQL for ML Table Ingestion</h3>
  <img src="project_screenshots/ml_data_ingestion.png" width="70%" />
  <img src="project_screenshots/ingestion_terminal_proof.png" width="70%" />
</p>

<p align="left">
  <h3>11. EDA for proof of concept prior to ML run</h3>
  <table style="width: 100%; border-collapse: collapse;">
    <tr style="border: none;">
      <th style="text-align: center; border: none;">Species Count</th>
      <th style="text-align: center; border: none;">Time Gap Analysis</th>
    </tr>
    <tr style="border: none;">
      <td style="width: 50%; border: none;">
        <img src="project_screenshots/disturbed_species_cnt.png" style="width: 100%;" />
      </td>
      <td style="width: 50%; border: none;">
        <img src="project_screenshots/time_gap.png" style="width: 100%;" />
      </td>
    </tr>
  </table>
</p>

<p align="left">
  <h3>12. XGBoost model initialization and training</h3>
  <img src="project_screenshots/ML_meat.png" width="70%" />
</p>

<p align="left">
  <h3>13. Model run and performance</h3>
  <table style="width: 100%; border-collapse: collapse;">
    <tr style="border: none;">
      <th style="text-align: center; border: none;">Meat of model</th>
      <th style="text-align: center; border: none;">Performance stats</th>
    </tr>
    <tr style="border: none;">
      <td style="width: 50%; border: none;">
        <img src="project_screenshots/ML_meat.png" style="width: 100%;" />
      </td>
      <td style="width: 50%; border: none;">
        <img src="project_screenshots/model_performance.png" style="width: 100%;" />
      </td>
    </tr>
  </table>
</p>

<p align="left">
  <h3>14. Importance of features to the model</h3>
  <img src="project_screenshots/model_results.png" width="70%" />
</p>

<p align="left">
  <h3>15. Actionable list of false positives</h3>
  <img src="project_screenshots/false_positive_audit.png" width="70%" />
</p>

### **Database Schema Preview**
| Overview Schema | ML Ready Schema | Raw Data Schema |
| :---: | :---: | :---: |
| ![Schema Overview](project_screenshots/schema_overview.png) | ![ML Schema](project_screenshots/ml_schema.png) | ![Raw Schema](project_screenshots/raw_data_schema.png) |

---

## Roadblocks & Solutions

| Roadblock | Resolution |
| --- | --- |
| **Case-Sensitivity Errors:** Postgres failed on uppercase CSV headers (e.g., `"CONDID"`). | Developed a dynamic SQL script to batch-rename all columns to lowercase. |
| **Data Type Mismatches:** Integer columns containing numbers as strings like `"972.0"`. | Casted across datatypes on multiple fieldes process account for decimals during ETL. |
| **Query Performance:** At first, joining the tabular and raster data caused the query to timeout before completion. | Created **GIST Spatial Indexes** on the plot geometries and so that it would no longer need to scan full table to find each row. |
| **Time Discrepancies:** Comparing 1980 field survey data to 2020 satellite imagery. | Filtered dataset for `invyr >= 2015` and added a QA flagging system. |
| **Species Code Meaning:** Attempting to answer questions about the data was complicated by the species codes being only numeric. | Downloaded, cleaned, and integrated the species reference list to the schema. | 
| **Satellite Canopy Height vs Understory:** I became concered about the 'sat_ht_ft' value being applied to such a wide number of trees in a given plot. Upon investigating, it sounds like a common issue when relying on 10-m LiDAR resolution in forestry research. Telling the ML model that a slew of trees measured at 15 feet in the field produced a satellite height measuremnt of 70 feet is liable to confuse the model as these are more or less false positives. | Made the executive decision to rank tree height within each plot. This shrinks the total record count dramaticallly - from approximately 340k records to just over 10,000. I'd rather feed the model meaningful, high-value data than overwhelm it with noise. | 
| **Give the Model a Sense of Time:** | The raw data includes snapshots in time by displaying the field survey year and we know that that raster data came from 2020. This isn't enough for a machine learning model to consider the passage of time in its decision tree. | Calculated an additional column that outputs the number of years on either side of the remote sensing that the field survey was conducted. |


* a data dictionary of sorts that simply guides users through the meaning/content of a given table or record would be handy |
* perhaps 7 years of forest growth is considered too much time. Should I have limited the survey history further?
* some thoughts on pre-raster tabular data (2015-2019, sweetspot (2020), and post-raster 2021-2022)

---

## Data Quality Assurance

While reviewing the intitial output, I noticed a several thousand NULL values in field_ht_ft.  

I thought that perhaps these would be localized to a specific area or 
maybe belong to a particular species. Even with further investigation, no real pattern stood out. This could simply be representation in the dataset of how difficult
collecting field data can be.

This was a critical catch as nearly 8% of all records in the ml_training_data_static table had a null field height measurement value. This would've caused the ML model to error as models can't train on empty targets. 

<p align="left">
  <h3>NULL Field Height Issue</h3>
  <img src="project_screenshots/NULL_field_height_issue.png" width="70%" />
</p>

This analysis encountered a crossroads of sorts when it came time to decide if it would be worth injecting every individual tree surveyed in a given plot or whether to key only on the taller (or tallest) trees that would've been captured in the remote sensing data. The SQL lgoic was revised so that a ranking system was applied to each tree (by plot_id) of the entire cleaned dataset. This enabled me to make a comparison of field to raster data with much more truth while avoiding the noise of several hundred thousand trees whose data are not reflected in the LiDAR data. 

To acheive this, I implemented a quality check, embedded as a CASE statement, that dynamically flags records to ensure the ML model only trains on high-integrity data as well as classifiying those records as "stable" or "disturbed". The ranking was handled by moving this logic inside of a CTE then selecting and filtering based on that logged data.

<p align="left">
  <h3>Disturbed Count</h3>
  <img src="project_screenshots/disturbed_count.png" width="70%" />
</p>

It was also necessary to give the model a bit of context for the passsage of time. This could be described as feature engineering in a data science role. The output table does have the survey year included. However, without a calculation of that value with respect to the year in which the raster data was compiled, the model wouldn't know to use time as as part of its prediction. This is a key ingredient to the whole process.

<p align="left">
  <h3>Years Until or Since LiDAR Imaging</h3>
  <img src="project_screenshots/years_from_raster.png" width="70%" />
</p>
---

## Conclusion

1. Findings: Eight false positives generated from the model execution. Precisions of .97, recall .98, f-1 score 0f .98. sat_ht_ft field identified as most important feature to the model

2. Significance: The false positives no placed into a quasi-audit file provide the forestry team with cause to further investigate those specific areas. It's possible that this list captures hyper localized storms, illegal deforestation, or some unknown pest that toppled trees.

3. Room for improvement:
Noticed some common_tree name values with spaces or different joining characters. The species reference listed was integrated later in the process and I was sure to format the field names accordingly, but should've reviewed and sychronized the values within as well. The model succeeded to a high degree in what it set out to do considering the parameters it was fed. It would be interesting to include some other basics such as elevation and slope to see how they affect the predictions. A true risk factor feature would be very handy to introduce as opposed to the model inferring and assigning that lightly-weighted variable to the model. I'd like to work with spectral signatures someday. It stands to reason that the color aspect of satellite images could prove to be extremely useful in such analyses. 



---

## 🚀 Getting Started

1. Clone the repo.
2. Ensure PostGIS is enabled on your local database.
3. Run `etl_scripts/01_import_species.py` to populate the reference table.
4. Execute the SQL views found in `sql/v_gold_ml_ready.sql`.