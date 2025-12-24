DROP TABLE IF EXISTS ml_ready.ml_training_data_static

CREATE TABLE ml_ready.ml_training_data_static AS
SELECT 
    sub.plot_id,
    sub.survey_year,
    sub.years_from_raster,
    sub.common_name,
    sub.field_ht_ft,
    sub.sat_ht_ft,
    CASE
		------------- classify as disturbed or not_disturbed ---------------------------
        WHEN (sub.survey_year <= 2020 AND (sub.field_ht_ft - sub.sat_ht_ft) > 40) THEN 1
        WHEN (sub.survey_year > 2020 AND (sub.sat_ht_ft - sub.field_ht_ft) > 40) THEN 1
        ELSE 0 
    END AS is_disturbed
	------------- classify as disturbed or not_disturbed ---------------------------
	FROM (
    SELECT 
        p.cn AS plot_id,
        p.invyr::numeric::int AS survey_year,
        (2020 - p.invyr::numeric::int) AS years_from_raster,
        s.common_name,
        t.ht::numeric AS field_ht_ft,
        (ST_Value(r.rast, p.geom) * 3.28084) AS sat_ht_ft
    FROM raw_data.tn_plot p
    JOIN raw_data.tn_cond c ON p.cn = c.plt_cn
    JOIN raw_data.tn_tree t ON c.plt_cn = t.plt_cn::bigint AND c.condid::numeric::int = t.condid::numeric::int
    LEFT JOIN raw_data.species_list s ON t.spcd::numeric::int = s.spcd
    JOIN raw_data.canopy_tiles r ON ST_Intersects(r.rast, p.geom)
    -- filter our NULL field_hit_ft and those = 0
	WHERE t.ht IS NOT NULL 
      AND t.ht::numeric > 0 
      AND ST_Value(r.rast, p.geom) IS NOT NULL 
      AND ST_Value(r.rast, p.geom) > 0
	  ) sub;
	  
-- issuing 3 primary keys to minimize possibility of dup records
ALTER TABLE ml_ready.ml_training_data_static ADD PRIMARY KEY (plot_id, field_ht_ft);

