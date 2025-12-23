-- CREATE OR REPLACE VIEW raw_data.v_cleaned_forest_data AS
-- SELECT 
--     -- id and time
--     p.cn AS plot_id,
--     p.invyr,
--     -- condition data
--     c.fortypcd as forest_type,
--     c.stdage as stand_age,
--     c.slope,
--     -- tree data strings cast to numbers
--     t.spcd::int as species_code,
--     t.ht::double precision as field_ht_ft,
--     t.dia::double precision as diameter_in,
--     -- extract height from the raster (pixel value)
--     -- meters to feet (3.28084) to match tabular data
--     ST_Value(r.rast, ST_SetSRID(ST_MakePoint(p.lon, p.lat), 4326)) * 3.28084 AS sat_ht_ft
-- FROM raw_data.tn_plot p
-- JOIN raw_data.tn_cond c ON p.cn = c.plt_cn
-- JOIN raw_data.tn_tree t ON c.plt_cn = t.plt_cn::bigint
-- 	AND c.condid = t.condid::int
-- JOIN raw_data.canopy_tiles r ON ST_Intersects(r.rast, ST_SetSRID(ST_MakePoint(p.lon, p.lat), 4326))
-- WHERE t.ht IS NOT NULL;

-- -- added revised version in attempt to optimize view access
-- CREATE OR REPLACE VIEW raw_data.v_corrected_forest_data AS
-- SELECT 
--     p.cn AS plot_id,
--     p.invyr,
--     c.fortypcd,
--     c.stdage as stand_age,
--     t.spcd::int as species_code,
--     NULLIF(t.ht, '')::double precision as field_ht_ft,
--     ST_Value(r.rast, p.geom) * 3.28084 AS sat_ht_ft
-- FROM raw_data.tn_plot p
-- JOIN raw_data.tn_cond c ON p.cn = c.plt_cn
-- JOIN raw_data.tn_tree t 
--     ON c.plt_cn = NULLIF(TRIM(t.plt_cn), '')::numeric::bigint 
--     AND c.condid = NULLIF(TRIM(t.condid), '')::numeric::int
-- JOIN raw_data.canopy_tiles r ON ST_Intersects(r.rast, p.geom);

-- 2nd full revision after struggling with float vs string in tn_plot
CREATE OR REPLACE VIEW raw_data.v_cleaned_forest_data AS
SELECT 
    p.cn AS plot_id,
    p.invyr::int,
    c.fortypcd,
    c.stdage as stand_age,
    t.spcd as species_code,
    t.ht as field_ht_ft,
    ST_Value(r.rast, p.geom) * 3.28084 AS sat_ht_ft
FROM raw_data.tn_plot p
JOIN raw_data.tn_cond c ON p.cn = c.plt_cn
JOIN raw_data.tn_tree t ON c.plt_cn = t.plt_cn::bigint AND c.condid = t.condid::int
JOIN raw_data.canopy_tiles r ON ST_Intersects(r.rast, p.geom);