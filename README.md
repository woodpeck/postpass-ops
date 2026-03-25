# Postpass Operations

I am currently running an instance of the 
[Postpass service](https://github.com/woodpeck/postpass) on 
Geofabrik servers at https://postpass.geofabrik.de/.

Try it out:

    curl -g https://postpass.geofabrik.de/api/0.2/interpreter --data-urlencode "data=
        SELECT tags, geom 
        FROM postpass_point
        WHERE tags->>'amenity'='fast_food' 
        AND geom && st_makeenvelope(8.34,48.97,8.46,49.03,4326)"

Or: https://overpass-turbo.eu/s/21wP

    {{data:sql,server=https://postpass.geofabrik.de/api/0.2/}}
    
    SELECT tags, geom
    FROM postpass_point
    WHERE tags->>'amenity'='fast_food'
    AND geom && {{bbox}}

Or: https://overpass-ultra.us/#m=14.00/51.9640/7.6129&q=LQhQBcE8AcFMC4AE0D2Bnc0CGa2hMKAMoCiAMiQMIAqi4WA5mgDSIOwoC2oAYgEoB5ALLJ0mHGgD6qAJYA7cKADqACRJ8SdRmmAA+XQHIsnWHJlQDAXgMAzHOEk2UKACYHQAQQByAETYdORAAyIMQiakkhLABrWBI5ADdYABsUOAAKAG9MgHc0UwBfAuYAFgBmACYANgBKUCA

    ---
    type: postpass
    ---
    SELECT tags, geom
    FROM postpass_point
    WHERE tags->>'amenity'='fast_food'
    AND geom && ST_MakeEnvelope({{wsen}},4326)


This repository does not contain any software. It is intended to document details 
about this particular instance (such as which database schema is currently available,
which software version is running and so on).

Please use the "issues" feature of this repository if you want to discuss operational
issues.

## Database schema

See [SCHEMA.md](./SCHEMA.md) for a description of the database schema.

The data can be imported with:

    osm2pgsql -O flex -S ./postpass.lua INPUT_FILENAME.osm.pbf
    psql -f views.sql

This need a version of `osm2pgsql` with at least commit
[`61ac7152`](https://github.com/osm2pgsql-dev/osm2pgsql/commit/61ac71521d00d1dc401b14e97a810f11dbcf9d26).
`v2.2.0` does not have this commit.

## Talk slides  

I presented the software with many examples at the State of the Map and State
of the Map EU conferences in 2025, and here are the [talk slides](./sotm-talk.pdf). A German-language presentation was also held at FOSSGIS 2025 [(slides)](./fossgis-talk.pdf) but caution, this was an earlier version and many things in that talk are not accurate for the currently running version.

## Announcements on public forums

* [German OSM forum on 03 Apr 25](https://community.openstreetmap.org/t/postpass-eine-offentlich-nutzbare-osm-postgis/128283)
* [International OSM forum on 11 Apr 25](https://community.openstreetmap.org/t/postpass-a-public-osm-postgis-instance/128649)
