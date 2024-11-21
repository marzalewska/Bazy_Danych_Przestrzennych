CREATE EXTENSION postgis;
CREATE TABLE obiekty (nazwa VARCHAR(9), geometry geometry);

INSERT INTO obiekty("nazwa", geometry)
VALUES('obiekt1', ST_CollectionExtract(
		ST_CurveToLine(
			ST_GeomFromEWKT(
	 			'SRID=0;GEOMETRYCOLLECTION(
					 LINESTRING(0 1, 1 1),
				 	 CIRCULARSTRING(1 1, 2 0, 3 1),
				 	 CIRCULARSTRING(3 1, 4 2, 5 1),
				 	 LINESTRING(5 1, 6 1)
	 			)')))),
('obiekt2', 
	ST_SetSRID(
		ST_BuildArea(
			ST_Collect(
				ARRAY[
					'LINESTRING(10 6, 14 6)',
					'CIRCULARSTRING(14 6, 16 4, 14 2)',
					'CIRCULARSTRING(14 2, 12 0, 10 2)',
					'LINESTRING(10 2, 10 6)',
					ST_Buffer(ST_POINT(12, 2), 1, 6000)
				]
			)), 0)),
('obiekt3', 
	ST_GeomFromEWKT(
		'SRID=0;POLYGON((10 17, 12 13, 7 15, 10 17))')),
('obiekt4', 
	ST_GeomFromEWKT(
		'SRID=0;LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)')),
('obiekt5', 
	ST_GeomFromEWKT(
		'SRID=0;MULTIPOINT((30 50 59), (38 32 234))')),
('obiekt6', 
	ST_SetSRID(
		ST_Collect(
			'LINESTRING(1 1, 3 2)',
			'POINT(4 2)'), 0));

--zadanie2
WITH geometries AS (
    SELECT 
        (SELECT geometry FROM obiekty WHERE "nazwa" = 'obiekt3') AS geom3,
        (SELECT geometry FROM obiekty WHERE "nazwa" = 'obiekt4') AS geom4
)
SELECT 
    ST_Area(ST_Buffer(ST_ShortestLine(geometries.geom3, geometries.geom4), 5)) AS buffer_area
FROM geometries;

--zadanie3
WITH closed_line AS (
    SELECT 
        ST_MakePolygon(ST_AddPoint(geometry, ST_StartPoint(geometry))) AS new_geometry
    FROM obiekty
    WHERE "nazwa" = 'obiekt4'
)
UPDATE obiekty
SET geometry = (SELECT new_geometry FROM closed_line)
WHERE "nazwa" = 'obiekt4';

--zadanie4
INSERT INTO obiekty ("nazwa", geometry)
SELECT 'obiekt7', ST_Collect(geometry)
FROM obiekty
WHERE "nazwa" = 'obiekt3' OR "nazwa" = 'obiekt4'

--zadanie5
SELECT ST_Area(ST_Buffer(ST_Union(ST_Force3D(geometry)), 5)) 
FROM obiekty
WHERE NOT ST_HasArc(geometry)


