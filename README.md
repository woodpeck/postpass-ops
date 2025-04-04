# Postpass Operations

I am currently running an instance of the 
[Postpass service](https://github.com/woodpeck/postpass) on 
Geofabrik servers at https://postpass.geofabrik.de/.

Try it out:

    curl -g http://postpass.geofabrik.de/api/0.2/interpreter --data-urlencode "data=
        SELECT tags, geom 
        FROM postpass_point
        WHERE tags->>'amenity'='fast_food' 
        AND geom && st_setsrid(st_makebox2d(st_makepoint(8.34,48.97),
           st_makepoint(8.46,49.03)), 4326)"

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

## FOSSGIS talk 

I presented the software with many examples at FOSSGIS 2025, and here
are the (German) slides of that presentation: 
[fossgis-talk.pdf](./fossgis-talk.pdf)

## Announcements on public forums

* [German forum on 03 Apr 25](https://community.openstreetmap.org/t/postpass-eine-offentlich-nutzbare-osm-postgis/128283)
