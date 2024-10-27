CREATE EXTENSION postgis;

CREATE TABLE buildings (
 id serial PRIMARY KEY,
 geometry geometry,
 name varchar(30)
);

CREATE TABLE roads (
id serial PRIMARY KEY,
geometry geometry,
name varchar(30)
);

CREATE TABLE poi (
id serial PRIMARY KEY,
geometry geometry,
name varchar(30)
);

--TRUNCATE TABLE poi RESTART IDENTITY;
INSERT INTO poi (geometry, name)
VALUES ('POINT(1 3.5)'::geometry, 'G'),
		('POINT(5.5 1.5)'::geometry, 'H'),
		('POINT(9.5 6)'::geometry, 'I'),
		('POINT(6.5 6)'::geometry, 'J'),
		('POINT(6 9.5)'::geometry, 'K');

SELECT * FROM poi;


INSERT INTO roads (geometry,name)
VALUES ('LINESTRING(0 4.5, 12 4.5)'::geometry, 'RoadX'),
		('LINESTRING(7.5 10.5, 7.5 0)'::geometry, 'RoadY');
SELECT * FROM roads;

INSERT INTO buildings (geometry, name)
VALUES ('POLYGON((10.5 5.4, 10.5 1.5, 8 1.5, 8 4, 10.5 5.4))'::geometry, 'BuildingA'),
('POLYGON((6 7, 6 5, 4 5, 4 7, 6 7))'::geometry, 'BuildingB'),
('POLYGON((5 8, 5 6, 3 6, 3 8, 5 8))'::geometry, 'BuildingC'),
('POLYGON((10 9, 10 8, 9 8, 9 9, 10 9))'::geometry, 'BuildingD'),
('POLYGON((2 2, 2 1, 1 1, 1 2, 2 2))'::geometry, 'BuildingF');

SELECT * FROM buildings;

--a
SELECT SUM(st_Length(geometry)) FROM roads;

--b
SELECT ST_AsText(geometry) AS wkt_geometry,
ST_Area(geometry),
ST_Perimeter(geometry)
FROM buildings
WHERE name = 'BuildingA';

--c
SELECT name, ST_Area(geometry)
FROM Buildings
ORDER BY name ASC;

--d
SELECT name, ST_perimeter(geometry)
FROM buildings
ORDER BY (st_Area(geometry)) DESC
LIMIT 2;

--e
SELECT ST_Distance(b.geometry, p.geometry) AS distance
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'K';

--f
SELECT ST_Area(ST_Difference(c.geometry, ST_Buffer(b.geometry, 0.5)))
FROM buildings c, buildings b
WHERE c.name = 'BuildingC' AND b.name = 'BuildingB';

--g
SELECT b.*
FROM buildings b
JOIN roads r ON r.name = 'RoadX'
WHERE ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_PointN(r.geometry, 1));

--h
SELECT ST_SRID(geometry) AS srid
FROM buildings
WHERE name = 'BuildingC';
UPDATE buildings
SET geometry = ST_SetSRID(geometry, 4326)
WHERE name = 'BuildingC';

SELECT ST_Area(ST_Difference(c.geometry, 
              ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 4326))) AS area_difference
FROM buildings c
WHERE c.name = 'BuildingC';




