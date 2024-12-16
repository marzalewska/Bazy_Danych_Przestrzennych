--raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d "D:\mary\Astudia\semestr7\bazy danych\PostGIS raster - dane" rasters.dem | psql -d postgis_raster_ut -U postgres
--raster2pgsql.exe -s 3763 -N -32767 -t 128x128 -I -C -M -d "D:\mary\Astudia\semestr7\bazy danych\PostGIS raster - dane" rasters.landsat8 | psql -d postgis_raster_ut -U postgres


SELECT * FROM raster_columns;

CREATE SCHEMA zalewska;
DROP table IF EXISTS zalewska.intersects;

CREATE TABLE zalewska.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table zalewska.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON zalewska.intersects
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'intersects'::name,'rast'::name);

SELECT * FROM zalewska.intersects;

DROP table IF EXISTS zalewska.clip;

CREATE TABLE zalewska.clip AS
SELECT ST_Clip(a.rast, b.geom, true) AS rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

alter table zalewska.clip
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_clip_rast_gist ON zalewska.clip
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'clip'::name,'rast'::name);

SELECT * FROM zalewska.clip;

--DROP table IF EXISTS zalewska.union;
CREATE TABLE zalewska.union AS
SELECT ST_Union(rast) AS rast
FROM zalewska.clip;

alter table zalewska.union
add column rid SERIAL PRIMARY KEY;
CREATE INDEX idx_union_rast_gist ON zalewska.union
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'union'::name,'rast'::name);
SELECT * FROM zalewska.union;

CREATE TABLE zalewska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zalewska.porto_parishes
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_porto_parishes_rast_gist ON zalewska.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'porto_parishes'::name,'rast'::name);

SELECT * FROM zalewska.porto_parishes

DRoP TABLE zalewska.porto_parishes; 
CREATE TABLE zalewska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zalewska.porto_parishes
add column rid SERIAL PRIMARY KEY;
CREATE INDEX idx_porto_parishes_rast_gist ON zalewska.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'porto_parishes'::name,'rast'::name);
SELECT * FROM zalewska.porto_parishes;

DROP TABLE zalewska.porto_parishes; --> drop table porto_parishes first
CREATE TABLE zalewska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

alter table zalewska.porto_parishes
add column rid SERIAL PRIMARY KEY;
CREATE INDEX idx_porto_parishes_rast_gist ON zalewska.porto_parishes
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'porto_parishes'::name,'rast'::name);
SELECT * FROM zalewska.porto_parishes;


DROP TABLE IF EXISTS zalewska.intersection;
create table zalewska.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);
SELECT * FROM zalewska.intersection;

CREATE TABLE zalewska.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);
SELECT * FROM zalewska.dumppolygons

CREATE TABLE zalewska.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;
CREATE INDEX idx_landsat_nir_rast_gist ON zalewska.landsat_nir
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'landsat_nir'::name,'rast'::name);
SELECT * FROM zalewska.landsat_nir;

CREATE TABLE zalewska.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);
CREATE INDEX idx_paranhos_dem_rast_gist ON zalewska.paranhos_dem
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'paranhos_dem'::name,'rast'::name);
SELECT * FROM zalewska.paranhos_dem;

CREATE TABLE zalewska.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM zalewska.paranhos_dem AS a;

CREATE INDEX idx_paranhos_slope_rast_gist ON zalewska.paranhos_slope
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('zalewska'::name,
'paranhos_slope'::name,'rast'::name);
SELECT * FROM zalewska.paranhos_slope;


CREATE TABLE zalewska.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3','32BF',0) AS rast
FROM zalewska.paranhos_slope AS a;

CREATE INDEX idx_paranhos_slope_reclass_rast_gist ON zalewska.paranhos_slope_reclass
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zalewska'::name,
'paranhos_slope_reclass'::name,'rast'::name);

SELECT * FROM zalewska.paranhos_slope_reclass;

SELECT st_summarystats(a.rast) AS stats
FROM zalewska.paranhos_dem AS a;

SELECT st_summarystats(ST_Union(a.rast))
FROM zalewska.paranhos_dem AS a;

WITH t AS (
	SELECT st_summarystats(ST_Union(a.rast)) AS stats
	FROM zalewska.paranhos_dem AS a)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

create table zalewska.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;
CREATE INDEX idx_tpi30_rast_gist ON zalewska.tpi30
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('zalewska'::name,
'tpi30'::name,'rast'::name);;

CREATE TABLE zalewska.porto_ndvi AS
	WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
	r.rast, 1,
	r.rast, 4,
	'([rast2.val] - [rast1.val]) / ([rast2.val] +
	[rast1.val])::float','32BF'
	) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON zalewska.porto_ndvi
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('zalewska'::name,
'porto_ndvi'::name,'rast'::name);
SELECT * FROM zalewska.porto_ndvi;


create or replace function zalewska.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); 
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE zalewska.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
	r.rast, ARRAY[1,4],
	'zalewska.ndvi(double precision[],
	integer[],text[])'::regprocedure, --> This is the function!
	'32BF'::text
	) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON zalewska.porto_ndvi2
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('zalewska'::name,
'porto_ndvi2'::name,'rast'::name);
SELECT * FROM zalewska.porto_ndvi2;

SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM zalewska.porto_ndvi;