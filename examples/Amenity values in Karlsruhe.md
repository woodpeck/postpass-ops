# Amenity values in Karlsruhe

Normally the backend will try to create a GeoJSON from your
query, and fails if your query does not yield a geometry column.
If you pass the URL parameter `options[geojson]=false` you can 
disable GeoJSON creation, and retrieve a standard JSON instead.

## Postpass query

This query counts different amenity values in Karlsruhe:

    curl -g https://postpass.geofabrik.de/api/0.2/interpreter \
       --data-urlencode "options[geojson]=false" \
       --data-urlencode "data=
          SELECT count(*), tags->>'amenity' as amenity
          FROM postpass_point
          WHERE tags?'amenity'
          AND geom && st_makeenvelope(8.34,48.97,8.46,49.03,4326)
          GROUP BY amenity"

Note that a simple bounding box is used; alternatively one could join
with the `postpass_polygon` table to use the exact admin boundary.

