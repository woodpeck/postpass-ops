import z from 'zod'
import { curlData } from './utils/curl'

// admin.osm_id AS country_osm_id,
async function fetch() {
  const query = `
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
    point.natural = 'tree'
    AND point.tags ? 'ref'
    AND admin.boundary='administrative'
    AND admin.admin_level = '2'
GROUP BY
    admin.name
`

  const schema = z.object({ result: z.any() })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  console.log('fetch', data.result)
  return data.result
}

async function main() {
  fetch()
}

main()
