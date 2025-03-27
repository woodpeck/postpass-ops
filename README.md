# Postpass Operations

I am currently running an instance of the 
[Postpass service](https://github.com/woodpeck/postpass) on 
Geofabrik servers at https://postpass.geofabrik.de/.

Try it out:

    curl -g http://postpass.geofabrik.de/api/0.1/interpreter --data-urlencode "data=
        SELECT name, way 
        FROM planet_osm_point
        WHERE amenity='fast_food' 
        AND way && st_setsrid(st_makebox2d(st_makepoint(8.34,48.97),st_makepoint(8.46,49.03)), 4326)"

Or: https://overpass-turbo.eu/s/21b9

    {{data:sql,server=https://postpass.geofabrik.de/api/0.1/}}
    
    SELECT name, way
    FROM planet_osm_point
    WHERE amenity='fast_food'
    AND way && {{bbox}}



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
