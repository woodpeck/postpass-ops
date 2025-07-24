# Highways with mtb:scale in Switzerland

The `mtb:scale` tag contains information about the 
usability of a path for mountain biking.

## Postpass query

This query exports all highways in Switzerland that have the
`mtb:scale` tag.

The query uses the numeric ID of the Switzerland polygon for 
performance, but a query that searches for "an adminlevel 2 
polygon named Switzerland" would also be possible.

    curl -o paths.geojson \
       -g https://postpass.geofabrik.de/api/0.2/interpreter \
       --data-urlencode "data=
          SELECT ways.geom, ways.tags->>'highway' as highway,
             ways.tags->>'mtb:scale' as mtbscale
          FROM postpass_line ways, postpass_polygon switzerland
          WHERE ways.tags?'highway' AND ways.tags?'mtb:scale'
          AND switzerland.osm_id=51701 and switzerland.osm_type='R'
          AND st_contains(switzerland.geom, ways.geom)"

The query takes about 5 seconds and produces a 90 MB GeoJSON file.

