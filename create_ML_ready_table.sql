-- DROP TABLE IF EXISTS ml_ready.training_data_static;

CREATE TABLE ml_ready.training_data_static AS
WITH base_data AS (
    SELECT 
        p.cn AS plot_id,
        p.invyr::numeric::int AS survey_year,
        s.common_name,
        s.genus,
        CASE 
            WHEN s.common_name ILIKE '%pine%' OR s.common_name ILIKE '%cedar%' 
                 OR s.common_name ILIKE '%fir%' THEN 'Softwood'
            ELSE 'Hardwood'
        END AS wood_type,
        t.ht::numeric AS field_ht_ft,
        ST_Value(r.rast, p.geom) * 3.28084 AS sat_ht_ft
    FROM raw_data.tn_plot p
    JOIN raw_data.tn_cond c ON p.cn = c.plt_cn
    JOIN raw_data.tn_tree t ON c.plt_cn = t.plt_cn::bigint AND c.condid = t.condid::int
    -- Using your correctly named species table
    LEFT JOIN raw_data.species_list s ON t.spcd::numeric::int = s.spcd
    JOIN raw_data.canopy_tiles r ON ST_Intersects(r.rast, p.geom)
    WHERE p.invyr::int >= 2015
)
SELECT * FROM (
    SELECT 
        *,
		------ this is where we do some data quality flagging --------
        CASE 
            -- 'sat_ht_ft' missing would indicate "outside of .tif boundaries" or potential of cloud opacity conditions	
			WHEN sat_ht_ft IS NULL OR sat_ht_ft = 0 THEN 'EXCLUDE_NO_RASTER'
			-- somwhat arbirtrary choice of 65ft discrepancy to discard as outlier (to control model variance)
            WHEN ABS(field_ht_ft - sat_ht_ft) > 65 THEN 'EXCLUDE_EXTREME_OUTLIER'
			-- too large a gap between field measurement and LiDAR measurement of canopy height (mulitple trees on a plot and we want canopy-definers)
            WHEN field_ht_ft < 10 AND sat_ht_ft > 40 THEN 'EXCLUDE_UNDERSTORY'
            ELSE 'KEEP'
        END AS qa_status
    FROM base_data
) sub
WHERE qa_status = 'KEEP';

-- issuing 3 primary keys to minimize possibility of dup records
ALTER TABLE ml_ready.training_data_static ADD PRIMARY KEY (plot_id, field_ht_ft, );