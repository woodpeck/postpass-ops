# Highway lengths in Karlsruhe

Normally the backend will try to create a GeoJSON from your
query, and fails if your query does not yield a geometry column.
If you pass the URL parameter `options[geojson]=false` you can 
disable GeoJSON creation, and retrieve a standard JSON instead.

Geometry functions like `st_length` would normally yield a lenght
in degrees, but casting the geometry to a geography data type with
`::geography` will make PostGIS operate in metres.

## Postpass query

This query sums up the lengths of different highway types in Karlsruhe:

    curl -g https://postpass.geofabrik.de/api/0.2/interpreter \
       --data-urlencode "options[geojson]=false" \
       --data-urlencode "data=
          SELECT sum(st_length(geom::geography)) AS sum,
             tags->>'highway' AS highway
          FROM postpass_line
          WHERE tags?'highway'
          AND geom && st_makeenvelope(8.34,48.97,8.46,49.03,4326)
          GROUP BY highway"

Note that a simple bounding box is used; alternatively one could join 
with the `postpass_polygon` table to use the exact admin boundary.
