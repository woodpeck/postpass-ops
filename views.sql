-- Combined views

CREATE OR REPLACE VIEW postpass_pointlinepolygon AS
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, NULL::float as area_m2 FROM postpass_point
	UNION ALL
	SELECT osm_type, osm_id, tags, geom, length_m, NULL::float as area_m2 FROM postpass_line
	UNION ALL
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, area_m2 FROM postpass_polygon;

CREATE OR REPLACE VIEW postpass_pointpolygon AS
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, NULL::float as area_m2 FROM postpass_point
	UNION ALL
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, area_m2 FROM postpass_polygon;

CREATE OR REPLACE VIEW postpass_pointline AS
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, NULL::float as area_m2 FROM postpass_point
	UNION ALL
	SELECT osm_type, osm_id, tags, geom, length_m, NULL::float as area_m2 FROM postpass_line;

CREATE OR REPLACE VIEW postpass_linepolygon AS
	SELECT osm_type, osm_id, tags, geom, length_m, NULL::float as area_m2 FROM postpass_line
	UNION ALL
	SELECT osm_type, osm_id, tags, geom, NULL::float as length_m, area_m2 FROM postpass_polygon;


-- Compatibility Views for backwards compatibility with postpass 0.1

CREATE OR REPLACE VIEW planet_osm_point AS SELECT
	osm_id,
	tags->>'access' AS access,
	tags->>'addr:housename' AS "addr:housename",
	tags->>'addr:housenumber' AS "addr:housenumber",
	tags->>'admin_level' AS admin_level,
	tags->>'aerialway' AS aerialway,
	tags->>'aeroway' AS aeroway,
	tags->>'amenity' AS amenity,
	tags->>'barrier' AS barrier,
	tags->>'boundary' AS boundary,
	tags->>'building' AS building,
	tags->>'highway' AS highway,
	tags->>'historic' AS historic,
	tags->>'junction' AS junction,
	tags->>'landuse' AS landuse,
	tags->>'layer' AS layer,
	tags->>'leisure' AS leisure,
	tags->>'lock' AS lock,
	tags->>'man_made' AS man_made,
	tags->>'military' AS military,
	tags->>'name' AS name,
	tags->>'natural' AS "natural",
	tags->>'oneway' AS oneway,
	tags->>'place' AS place,
	tags->>'power' AS power,
	tags->>'railway' AS railway,
	tags->>'ref' AS ref,
	tags->>'religion' AS religion,
	tags->>'shop' AS shop,
	tags->>'tourism' AS tourism,
	tags->>'water' AS water,
	tags->>'waterway' AS waterway,
	(SELECT hstore(array_agg(key), array_agg(value)) FROM jsonb_each_text(tags))::hstore AS tags,
	geom AS way
	FROM postpass_point;

CREATE OR REPLACE VIEW planet_osm_line AS SELECT
	CASE WHEN osm_type = 'R' THEN -osm_id ELSE osm_id END as osm_id,
	tags->>'access' AS access,
	tags->>'addr:housename' AS "addr:housename",
	tags->>'addr:housenumber' AS "addr:housenumber",
	tags->>'addr:interpolation' AS "addr:interpolation",
	tags->>'admin_level' AS admin_level,
	tags->>'aerialway' AS aerialway,
	tags->>'aeroway' AS aeroway,
	tags->>'amenity' AS amenity,
	tags->>'barrier' AS barrier,
	tags->>'bicycle' AS bicycle,
	tags->>'bridge' AS bridge,
	tags->>'boundary' AS boundary,
	tags->>'building' AS building,
	tags->>'construction' AS construction,
	tags->>'covered' AS covered,
	tags->>'foot' AS foot,
	tags->>'highway' AS highway,
	tags->>'historic' AS historic,
	tags->>'horse' AS horse,
	tags->>'junction' AS junction,
	tags->>'landuse' AS landuse,
	tags->>'layer' AS layer,
	tags->>'leisure' AS leisure,
	tags->>'lock' AS lock,
	tags->>'man_made' AS man_made,
	tags->>'military' AS military,
	tags->>'name' AS name,
	tags->>'natural' AS "natural",
	tags->>'oneway' AS oneway,
	tags->>'place' AS place,
	tags->>'power' AS power,
	tags->>'railway' AS railway,
	tags->>'ref' AS ref,
	tags->>'religion' AS religion,
	tags->>'route' AS route,
	tags->>'service' AS service,
	tags->>'shop' AS shop,
	tags->>'surface' AS surface,
	tags->>'tourism' AS tourism,
	tags->>'tracktype' AS tracktype,
	tags->>'tunnel' AS tunnel,
	tags->>'water' AS water,
	tags->>'waterway' AS waterway,
	null as way_area,
	null as z_order,
	(SELECT hstore(array_agg(key), array_agg(value)) FROM jsonb_each_text(tags))::hstore AS tags,
	geom AS way
	FROM postpass_line;

CREATE OR REPLACE VIEW planet_osm_polygon AS SELECT
	CASE WHEN osm_type = 'R' THEN -osm_id ELSE osm_id END as osm_id,
	tags->>'access' AS access,
	tags->>'addr:housename' AS "addr:housename",
	tags->>'addr:housenumber' AS "addr:housenumber",
	tags->>'addr:interpolation' AS "addr:interpolation",
	tags->>'admin_level' AS admin_level,
	tags->>'aerialway' AS aerialway,
	tags->>'aeroway' AS aeroway,
	tags->>'amenity' AS amenity,
	tags->>'barrier' AS barrier,
	tags->>'bicycle' AS bicycle,
	tags->>'bridge' AS bridge,
	tags->>'boundary' AS boundary,
	tags->>'building' AS building,
	tags->>'construction' AS construction,
	tags->>'covered' AS covered,
	tags->>'foot' AS foot,
	tags->>'highway' AS highway,
	tags->>'historic' AS historic,
	tags->>'horse' AS horse,
	tags->>'junction' AS junction,
	tags->>'landuse' AS landuse,
	tags->>'layer' AS layer,
	tags->>'leisure' AS leisure,
	tags->>'lock' AS lock,
	tags->>'man_made' AS man_made,
	tags->>'military' AS military,
	tags->>'name' AS name,
	tags->>'natural' AS "natural",
	tags->>'oneway' AS oneway,
	tags->>'place' AS place,
	tags->>'power' AS power,
	tags->>'railway' AS railway,
	tags->>'ref' AS ref,
	tags->>'religion' AS religion,
	tags->>'route' AS route,
	tags->>'service' AS service,
	tags->>'shop' AS shop,
	tags->>'surface' AS surface,
	tags->>'tourism' AS tourism,
	tags->>'tracktype' AS tracktype,
	tags->>'tunnel' AS tunnel,
	tags->>'water' AS water,
	tags->>'waterway' AS waterway,
	(SELECT hstore(array_agg(key), array_agg(value)) FROM jsonb_each_text(tags))::hstore AS tags,
	geom AS way
	FROM postpass_polygon;

