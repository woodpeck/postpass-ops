import { $ } from 'bun'
import z, { ZodSchema } from 'zod'
import { log } from './utils/log'

const curlData = async <T>(apiUrl: string, query: string, schema: ZodSchema<T>) => {
  log(
    'QUERYING',
    `curl -g ${apiUrl} --header "Host: postpass.geofabrik.de" --data-urlencode "options[geojson]=false" --data-urlencode "data=${query}"`,
  )
  let resultString = ''
  let resultError = ''
  try {
    const { stdout, stderr } =
      await $`curl -g ${apiUrl} --header "Host: postpass.geofabrik.de" --data-urlencode "options[geojson]=false" --data-urlencode "data=${query}"`
    resultString = stdout.toString('utf-8')
    const result = JSON.parse(resultString)
    resultError = stderr.toString('utf-8')
    return schema.parse(result)
  } catch (error) {
    // TODO: Refactor expose error reason which is likely a timeout
    // The TIMEOUT is an HTML response
    // It shows like this here:
    //   JSON Parse error: Unrecognized token '<'
    // The original response is…
    //   <html><body><h1>504 Gateway Time-out</h1>
    //   The server didn't respond in time.
    //   </body></html>
    console.error('curlData FAILED', { error, resultString, resultError })
    return { result: [], failed: true }
  }
}

async function fetch(apiUrl: string) {
  const query = `
SELECT
    pid,
    usename AS username,
    datname AS database_name,
    state,
    query,
    query_start
    application_name
FROM
    pg_stat_activity
WHERE
    state = 'active'
ORDER BY
    query_start DESC`

  const schema = z.object({ result: z.any() })
  const data = await curlData<z.infer<typeof schema>>(apiUrl, query, schema)
  console.log('fetch', data.result)
  return data.result
}

async function main() {
  const API_URLS = [
    'http://postpass1.geofabrik.de/api/0.1/interpreter',
    'http://postpass2.geofabrik.de/api/0.1/interpreter',
  ]
  const data = []
  for (const apiUrl of API_URLS) {
    data.push(await fetch(apiUrl))
  }
  return data.flat()
}

main()
