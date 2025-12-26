DROP TABLE IF EXISTS ml_ready.ml_training_data_dominant;

CREATE TABLE ml_ready.ml_training_data_dominant AS
WITH RankedTrees AS (
    SELECT 
        plot_id,
        survey_year,
        years_from_raster,
        common_name,
        field_ht_ft,
        sat_ht_ft,
        -- compare max field height to satellite height
		-- classify as is_disurbed or not
        CASE 
            WHEN (survey_year <= 2020 AND (field_ht_ft - sat_ht_ft) > 40) THEN 1
            WHEN (survey_year > 2020 AND (sat_ht_ft - field_ht_ft) > 40) THEN 1
            ELSE 0 
        END AS is_disturbed,
		-- rank trees by height within a given plot; will select tallest tree
        ROW_NUMBER() OVER(PARTITION BY plot_id ORDER BY field_ht_ft DESC) as height_rank
    FROM ml_ready.ml_training_data_static
)
SELECT 
    plot_id,
    survey_year,
    years_from_raster,
    common_name,
    field_ht_ft,
    sat_ht_ft,
    is_disturbed
FROM RankedTrees
WHERE height_rank = 1;

-- assigning 2 primary keys to further minimize possibility of dup records
ALTER TABLE ml_ready.ml_training_data_dominant ADD PRIMARY KEY (plot_id, field_ht_ft);

