import z from 'zod'
import { curlData } from './utils/curl'

export async function fetchTables() {
  const query = `
    SELECT *
    FROM osm2pgsql_properties
  `

  const schema = z.object({ result: z.array(z.object({ table_name: z.string() })) })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  return data.result.map((row) => row.table_name).sort((a, b) => a.localeCompare(b))
}
