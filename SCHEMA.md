# Database Schema

The currently deployed database is a relatively straightforward osm2pgsql "flex backend" 
import with coordinates in EPSG:4326.

The import configuration is set out in [./postpass.lua](postpass.lua); osm2pgsql
is then called with `-o flex` and `-S postpass.lua` to ingest that.

All tags are stored in one PostgreSQL column using the `jsonb` data type. 
See https://www.postgresql.org/docs/current/datatype-json.html for details about
using `jsonb` columns in PostgreSQL.

See [INDEXES.md](./INDEXES.md) for a list of indexes.

You have access to the following tables and columns:

## Main (Geometry) Tables

These three tables contain the actual geometry objects. 

### postpass_point

Contains points built from (tagged) OSM nodes. The `osm_id` column
is the actual OSM id of the node. The `osm_type` column is always 'N'.

    CREATE TABLE postpass_point (
        osm_type character(1) NOT NULL,
        osm_id bigint NOT NULL,
        tags jsonb,
        geom geometry(Point,4326)
    );

### postpass_line

Contains lines built from OSM relations or ways. The `osm_id` column
is the actual OSM id of the object, and `osm_type` is either 'W' 
or 'R'.

    CREATE TABLE postpass_line (
        osm_type character(1) NOT NULL,
        osm_id bigint NOT NULL,
        tags jsonb,
        geom geometry(MultiLineString,4326)
    );

### postpass_polygon

Contains polygons built from OSM relations or ways. The `osm_id` column
is the actual OSM id of the object, and `osm_type` is either 'W' 
or 'R'.

    CREATE TABLE postpass_polygon (
        osm_type character(1) NOT NULL,
        osm_id bigint NOT NULL,
        tags jsonb,
        geom geometry(MultiPolygon,4326)
    );

## Middle Tables

`osm2pgsql` uses so-called "middle tables" to record the raw OSM ways and 
relations. You can access these tables to analyse the relationship between
ways and relations even if they are not relevant for rendering.

Read more about these "middle tables" in the [osm2pgsl documentation](https://osm2pgsql.org/doc/manual.html#middle).

Note that there is no table for OSM nodes - for performance reasons, 
node coordinates are kept in a "flat nodes" file and not in the database.

### planet_osm_ways

Models OSM ways. Note the `tags` column is not a `hstore` type
like in the geometry tables, but a `jsonb`.

    CREATE TABLE public.planet_osm_ways (
        id bigint NOT NULL,
        nodes bigint[] NOT NULL,
        tags jsonb
    );

### planet_osm_rels

Models OSM relations. Note the `tags` column is not a `hstore` type
like in the geometry tables, but a `jsonb`.

CREATE TABLE public.planet_osm_rels (
    id bigint NOT NULL,
    members jsonb NOT NULL,
    tags jsonb
);

## Views

### Combined Views

For many queries, you might want to combine points and polygons. This can inflate queries
through excessive use of UNIONs. Therefore, four views have been created to model all possible
unions between the three geometry tables:

    CREATE VIEW postpass_pointlinepolygon AS
        SELECT * FROM postpass_point
        UNION ALL SELECT * FROM postpass_line
        UNION ALL SELECT * FROM postpass_polygon;

    CREATE VIEW postpass_pointpolygon AS
        SELECT * FROM postpass_point
        UNION ALL SELECT * FROM postpass_polygon;

    CREATE VIEW postpass_pointline AS
        SELECT * FROM postpass_point
        UNION ALL SELECT * FROM postpass_line;

    CREATE VIEW postpass_linepolygon AS
        SELECT * FROM postpass_line
        UNION ALL SELECT * FROM postpass_polygon;

### Compatibility Views

For backwards compatiblity with the data schema used in the 0.1 version of Postpass
(which was the default OSM Carto schema), we have created views that mimick the old
`planet_osm_point`, `planet_osm_line`, and `planet_osm_polygon` tables. Note that 
there is no `planet_osm_roads`, and neither do these tables have a `way_area` or
a `z_order` column.

Accessing the "tags" column in these views will be somewhat slow because of the 
conversion from the `jsonb` to the `hstore` data type.


    CREATE VIEW planet_osm_point AS SELECT
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

    CREATE VIEW planet_osm_line AS SELECT
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

    CREATE VIEW planet_osm_polygon AS SELECT
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

