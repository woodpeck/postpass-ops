import z from 'zod'
import { curlData } from './utils/curl'

async function fetch() {
  const query = `
SELECT
    pid,
    usename AS username,
    datname AS database_name,
    state,
    query,
    query_start,
    application_name
FROM
    pg_stat_activity
WHERE
    state = 'active'
ORDER BY
    query_start DESC
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
