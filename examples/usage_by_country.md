# Usage by country

https://wiki.openstreetmap.org/wiki/DE%3ATag%3Aadmin_level%3D2

`admin_level=2`

```sql
SELECT
    admin.name AS country,
    COUNT(point.*) AS ref_count
FROM
    planet_osm_point AS point
JOIN
    planet_osm_polygon AS admin
ON
    ST_Contains(admin.way, point.way)
WHERE
    point.tags @> 'natural=>tree' -- Filter for objects with "natural=tree"
    AND point.tags ? 'ref'        -- Ensure the "ref" tag exists
    AND admin.tags @> 'admin_level=>2' -- Filter for admin_level=2 polygons
GROUP BY
    admin.name
ORDER BY
    ref_count DESC;
```
