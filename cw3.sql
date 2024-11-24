CREATE EXTENSION postgis;
SELECT PostGIS_Version();

SELECT * FROM buildings_2018;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'water_lines_2019';

--shp2pgsql.exe "D:\mary\Astudia\semestr7\bazy danych\bdp\T2019_KAR_BUILDINGS.shp" public.buildings_2019 | psql -h localhost -p 5432 -U postgres -d cw3

--zadanie1
SELECT 
    COALESCE(b2018.polygon_id, b2019.polygon_id) AS polygon_id,
    CASE 
        WHEN b2018.polygon_id IS NULL THEN 'Wybudowany w 2019'
        WHEN b2019.polygon_id IS NULL THEN 'Usuniety w 2019' 
        WHEN b2018.height != b2019.height OR ST_Equals(b2018.geom, b2019.geom) = FALSE THEN 'Wyremontowany w 2019'
    END AS change_type
FROM buildings_2018 b2018
FULL OUTER JOIN buildings_2019 b2019
ON b2018.polygon_id = b2019.polygon_id
WHERE 
    b2018.polygon_id IS NULL OR 
    b2019.polygon_id IS NULL OR
    b2018.height != b2019.height OR 
    ST_Equals(b2018.geom, b2019.geom) = FALSE;

--zadanie2
select * from poi_2018; 

WITH new_buildings AS (
    SELECT 
        COALESCE(b2018.polygon_id, b2019.polygon_id) AS polygon_id,
        b2019.geom AS geom
    FROM buildings_2018 b2018
    FULL OUTER JOIN buildings_2019 b2019
    ON b2018.polygon_id = b2019.polygon_id
    WHERE 
        b2018.polygon_id IS NULL OR
        b2019.polygon_id IS NULL OR 
        b2018.height != b2019.height OR 
        ST_Equals(b2018.geom, b2019.geom) = FALSE 
),
new_poi AS (
    SELECT 
        poi2019.*
    FROM poi_2019 poi2019
    LEFT JOIN poi_2018 poi2018
    ON poi2019.poi_id = poi2018.poi_id
    WHERE poi2018.poi_id IS NULL
),
poi_near_buildings AS (
    SELECT 
        np.poi_id,
        np.type,
        np.geom,
        nb.polygon_id AS building_polygon_id
    FROM new_poi np
    JOIN new_buildings nb
    ON ST_DWithin(np.geom, nb.geom, 500)
)
SELECT 
    pnb.type AS poi_type,
    COUNT(*) AS poi_count
FROM poi_near_buildings pnb
GROUP BY pnb.type
ORDER BY poi_count DESC;

--zadanie3 
CREATE TABLE streets_reprojected AS
SELECT 
    gid,
    link_id,
    nref_in_id,
    fr_speed_l,
    to_speed_l,
    ST_Transform(ST_SetSRID(geom, 4326), 31467) AS geom,
    ref_in_id,
    st_name,
    speed_cat,
    dir_travel,
    func_class
FROM streets_2019;

--zadanie4
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY, geom GEOMETRY(Point)
);

INSERT INTO input_points (geom)
VALUES
    (ST_MakePoint(8.36093, 49.03174)),
    (ST_MakePoint(8.39876, 49.00644)); 
SELECT * FROM input_points;
--zadanie5
UPDATE input_points
SET geom = ST_SetSRID(geom, 31468);
SELECT ST_SRID(geom) FROM input_points LIMIT 1;

--zadanie6
SELECT ST_SRID(geom) FROM street_node_2019 LIMIT 1;
UPDATE street_node_2019
SET geom = ST_SetSRID(geom, 31468);

WITH line AS (
    SELECT 
        ST_MakeLine(ARRAY(SELECT geom FROM input_points ORDER BY id)) AS line_geom
),
przeciecie AS (
    SELECT 
        sn.node_id,
        sn.gid,
        sn.geom AS przeciecie_geom,
        sn.intersect
    FROM street_node_2019 sn,
         line l
    WHERE ST_DWithin(sn.geom, l.line_geom, 200)
)
SELECT 
    p.node_id,
    p.gid,
    p.przeciecie_geom,
    p.intersect
FROM przeciecie p;

--zadanie7
SELECT * FROM land_use_2019;
SELECT COUNT(DISTINCT p.poi_id) AS liczba_sklepow_sportowych
FROM poi_2019 AS p
JOIN land_use_2019 AS l
    ON ST_DWithin(p.geom, l.geom, 300)  
WHERE l.type = 'Park (City/County)'  
  AND p.type = 'Sporting Goods Store';  

--zadanie8
CREATE TABLE T2019_KAR_BRIDGES (
    gid SERIAL PRIMARY KEY,  
    railway_gid INT,      
    waterline_gid INT,      
    geom GEOMETRY(Point, 31468)
);
UPDATE railways_2019
SET geom = ST_SetSRID(geom, 31468);
UPDATE water_lines_2019
SET geom = ST_SetSRID(geom, 31468);

INSERT INTO T2019_KAR_BRIDGES (railway_gid, waterline_gid, geom)
SELECT
    r.gid AS railway_gid,            
    w.gid AS waterline_gid,         
    ST_Intersection(r.geom, w.geom) AS geom 
FROM
    railways_2019 AS r               
JOIN
    water_lines_2019 AS w              
ON
    ST_Intersects(r.geom, w.geom); 
SELECT * FROM T2019_KAR_BRIDGES;

