SELECT * from ml_ready.ml_training_data_static
WHERE 1=1
AND field_ht_ft IS NULL
-- AND qa_status != 'KEEP'
LIMIT 100;

SELECT COUNT (*)
FROM raw_data.v_cleaned_forest_data;
-- WHERE field_ht_ft IS NULL

SELECT COUNT (*)
FROM ml_ready.ml_training_data_static
WHERE field_ht_ft IS NULL;

SELECT common_name, COUNT(*) 
FROM ml_ready.ml_training_data_static
WHERE field_ht_ft IS NULL
GROUP BY common_name
ORDER BY COUNT(*) DESC;


SELECT DISTINCT survey_year 
FROM ml_ready.ml_training_data_static
ORDER BY survey_year DESC

SELECT 
    MIN(sat_ht_ft) as min_sat, 
    MAX(sat_ht_ft) as max_sat, 
    AVG(sat_ht_ft) as avg_sat,
    COUNT(*) as total_rows
FROM ml_ready.ml_training_data_static;

select count(*) from ml_ready.ml_training_data_static;

SELECT COUNT (*)
FROM ml_ready.ml_training_data_static 
WHERE 1=1
AND field_ht_ft IS  NULL
-- GROUP BY is_disturbed;