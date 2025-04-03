# Buffer around Germany

You can access any PostGIS geometry operations, for example
ST_BUFFER. The database has data in lat/lon degrees, so a buffer
size would normally be specified in degrees (with 1 degree being
100km at the equator), but you can also convert the geometry
to a "geography" data type (using the `::geography` type cast)
and then PostGIS uses metres.

## Postpass query

This query creates a 1000 metre buffer around the boundary of Germany:

    curl -o germany.geojson \
       -g "http://postpass.geofabrik.de/api/0.2/interpreter" \
       --data-urlencode "data=
          SELECT st_buffer(geom::geography, 1000)::geometry
          FROM postpass_polygon
          WHERE tags->>'boundary'='administrative'
          AND tags->>'admin_level'='2'
          AND tags->>'name'='Deutschland'

You could also reference the Germany polygon by ID which would be 
a little quicker.
