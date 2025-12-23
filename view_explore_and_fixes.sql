-- select * from raw_data.tn_cond
-- limit 1
-- WHERE tn_cond."PLT_CN" IN (163376701010854)
-- ALTER TABLE raw_data.tn_cond RENAME COLUMN "SLOPE" TO slope
-- Rename the CN column in tn_plot
-- ALTER TABLE raw_data.tn_plot RENAME COLUMN "CN" TO cn;

-- -- Rename the PLT_CN in the other tables
-- ALTER TABLE raw_data.tn_cond RENAME COLUMN "PLT_CN" TO plt_cn;
-- ALTER TABLE raw_data.tn_cond RENAME COLUMN "CONDID" TO condid;

-- select * from raw_data.tn_plot
-- LIMIT 1

-- -- ALTER TABLE raw_data.tn_plot RENAME COLUMN "INVYR" TO invyr
-- select * from raw_data.v_cleaned_forest_data
-- limit 1

-- Create a spatial index on the raster tiles
-- CREATE INDEX idx_canopy_rast_gist ON raw_data.canopy_tiles USING gist (ST_ConvexHull(rast));

-- Create a spatial index on the plot locations (if not already there)
-- First, we ensure the plot has a geometry column it can actually index
-- ALTER TABLE raw_data.tn_plot ADD COLUMN IF NOT EXISTS geom geometry(Point, 4326);
-- UPDATE raw_data.tn_plot SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

-- CREATE INDEX idx_tn_plot_geom_gist ON raw_data.tn_plot USING gist (geom);

-- SELECT * from raw_data.v_corrected_forest_data
-- LIMIT 5

-- ALTER TABLE raw_data.tn_tree 
--   ALTER COLUMN condid TYPE INT USING NULLIF(TRIM(condid), '')::numeric::int,
--   ALTER COLUMN plt_cn TYPE BIGINT USING NULLIF(TRIM(plt_cn), '')::numeric::bigint,
--   ALTER COLUMN spcd TYPE INT USING NULLIF(TRIM(spcd), '')::numeric::int,
--   ALTER COLUMN ht TYPE NUMERIC USING NULLIF(TRIM(ht), '')::numeric;

-- -- 2. Fix the Condition Table
-- ALTER TABLE raw_data.tn_cond 
--   ALTER COLUMN condid TYPE INT USING NULLIF(TRIM(condid::text), '')::numeric::int,
--   ALTER COLUMN plt_cn TYPE BIGINT USING NULLIF(TRIM(plt_cn::text), '')::numeric::bigint;

-- -- 3. Fix the Plot Table (The "Join Key")
-- ALTER TABLE raw_data.tn_plot 
--   ALTER COLUMN cn TYPE BIGINT USING NULLIF(TRIM(cn::text), '')::numeric::bigint;

-- SELECT * from raw_data.v_silver_forest_data
-- where invyr >= 2015

-- select * from raw_data.species_list
-- limit 20

-- DROP TABLE raw_data.tn_cond;
-- DROP TABLE raw_data.tn_plot;
-- -- DROP TABLE raw_data.tn_tree;

-- SELECT * FROM raw_data.tn_tree
-- LIMIT 10

-- convert lat & lon to spatial data by applying WGS84 projection 
-- create new column in tn_plot for this
ALTER TABLE raw_data.tn_plot 
ADD COLUMN geom geometry(Point, 4326);
-- lat and long get used in the raster PostGIS raster function
UPDATE raw_data.tn_plot 
SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326)
WHERE lon IS NOT NULL AND lat IS NOT NULL;
-- index create so that this can be referenced by main query
CREATE INDEX idx_tn_plot_geom ON raw_data.tn_plot USING GIST (geom);
