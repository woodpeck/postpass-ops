# Database Schema

The currently deployed database uses a standard "OpenStreetMap Carto"
database schema with coordinates in EPSG:4326.

Some OSM tags have their own columns; all tags that do not have their
own column are accessed via the `hstore` column `tags`. See https://www.postgresql.org/docs/current/hstore.html for details about using hstore columns in PostgreSQL.

You have access to the following tables and columns:

## Main (Geometry) Tables

These four tables contain the actual geometry objects. The standard OpenStreetMap Carto setup is focused on map rendering, so it is possible that some objects that are not relevant for rendering will not be reflected in these tables.

### planet_osm_point

Contains points built from (tagged) OSM nodes. The `osm_id` column
is the actual OSM id of the node.

    CREATE TABLE public.planet_osm_point (
        osm_id bigint,
        access text,
        "addr:housename" text,
        "addr:housenumber" text,
        admin_level text,
        aerialway text,
        aeroway text,
        amenity text,
        barrier text,
        boundary text,
        building text,
        highway text,
        historic text,
        junction text,
        landuse text,
        layer integer,
        leisure text,
        lock text,
        man_made text,
        military text,
        name text,
        "natural" text,
        oneway text,
        place text,
        power text,
        railway text,
        ref text,
        religion text,
        shop text,
        tourism text,
        water text,
        waterway text,
        tags public.hstore,
        way public.geometry(Point,4326)
    );

### planet_osm_line

Contains lines built from OSM relations or ways. The `osm_id` column
is the actual OSM id if the geometry comes from a way, and the negative
of the OSM id if it comes from a relation.

    CREATE TABLE public.planet_osm_line (
        osm_id bigint,
        access text,
        "addr:housename" text,
        "addr:housenumber" text,
        "addr:interpolation" text,
        admin_level text,
        aerialway text,
        aeroway text,
        amenity text,
        barrier text,
        bicycle text,
        bridge text,
        boundary text,
        building text,
        construction text,
        covered text,
        foot text,
        highway text,
        historic text,
        horse text,
        junction text,
        landuse text,
        layer integer,
        leisure text,
        lock text,
        man_made text,
        military text,
        name text,
        "natural" text,
        oneway text,
        place text,
        power text,
        railway text,
        ref text,
        religion text,
        route text,
        service text,
        shop text,
        surface text,
        tourism text,
        tracktype text,
        tunnel text,
        water text,
        waterway text,
        way_area real,
        z_order integer,
        tags public.hstore,
        way public.geometry(LineString,4326)
    );


### planet_osm_polygon

Contains polygons built from OSM relations or ways. The `osm_id` column
is the actual OSM id if the geometry comes from a way, and the negative
of the OSM id if it comes from a relation.

    CREATE TABLE public.planet_osm_polygon (
        osm_id bigint,
        access text,
        "addr:housename" text,
        "addr:housenumber" text,
        "addr:interpolation" text,
        admin_level text,
        aerialway text,
        aeroway text,
        amenity text,
        barrier text,
        bicycle text,
        bridge text,
        boundary text,
        building text,
        construction text,
        covered text,
        foot text,
        highway text,
        historic text,
        horse text,
        junction text,
        landuse text,
        layer integer,
        leisure text,
        lock text,
        man_made text,
        military text,
        name text,
        "natural" text,
        oneway text,
        place text,
        power text,
        railway text,
        ref text,
        religion text,
        route text,
        service text,
        shop text,
        surface text,
        tourism text,
        tracktype text,
        tunnel text,
        water text,
        waterway text,
        way_area real,
        z_order integer,
        tags public.hstore,
        way public.geometry(Geometry,4326)
    );

### planet_osm_roads

Note: The `planet_osm_roads` table contains a subset of the `planet_osm_line`
table; it is intended for improved performance when rendering on lower zoom 
levels. It does not only contain roads, but typically "larger linear 
infrastructure objects". 

    CREATE TABLE public.planet_osm_roads (
        osm_id bigint,
        access text,
        "addr:housename" text,
        "addr:housenumber" text,
        "addr:interpolation" text,
        admin_level text,
        aerialway text,
        aeroway text,
        amenity text,
        barrier text,
        bicycle text,
        bridge text,
        boundary text,
        building text,
        construction text,
        covered text,
        foot text,
        highway text,
        historic text,
        horse text,
        junction text,
        landuse text,
        layer integer,
        leisure text,
        lock text,
        man_made text,
        military text,
        name text,
        "natural" text,
        oneway text,
        place text,
        power text,
        railway text,
        ref text,
        religion text,
        route text,
        service text,
        shop text,
        surface text,
        tourism text,
        tracktype text,
        tunnel text,
        water text,
        waterway text,
        way_area real,
        z_order integer,
        tags public.hstore,
        way public.geometry(LineString,4326)
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


