# Time Zones

Time zones are recorded in OpenStreetMap as relations using the
tag `boundary=time_zone`.

## Postpass query

This query loads all time zone boundaries from OpenStreetMap:

    curl -o timezones.geojson  
       -g "http://postpass.geofabrik.de/api/0.1/interpreter \
       --data-urlencode "data=
          SELECT * 
          FROM planet_osm_polygon
          WHERE boundary='time_zone'"

The query takes about 120 seconds and produces a 500 MB GeoJSON file.

