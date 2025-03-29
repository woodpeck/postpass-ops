import { $ } from 'bun'
import { type ZodSchema } from 'zod'
import { API_URL } from './constants'
import { log } from './log'

/** @desc Excape `"` to work with curl; Remove `;` at the end. */
const excapeQuery = (query: string) => {
  query = query.trim().endsWith(';') ? query.trim().slice(0, -1) : query
  return query.replaceAll('"', '\"')
}

export const curlData = async <T>(query: string, schema: ZodSchema<T>) => {
  log(
    'QUERYING',
    `curl -g ${API_URL} --data-urlencode "options[geojson]=false" --data-urlencode "data=${excapeQuery(query)}"`,
  )
  try {
    const result =
      await $`curl -g ${API_URL} --data-urlencode "options[geojson]=false" --data-urlencode "data=${excapeQuery(query)}"`.json()

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
    console.error('curlData FAILED', error)
    return { result: [], failed: true }
  }
}

export const curlGeojson = async (query: string) => {
  log('QUERYING', `curl -g ${API_URL} --data-urlencode "data=${excapeQuery(query)}"`)
  const { stdout } = await $`curl -g ${API_URL} --data-urlencode "data=${excapeQuery(query)}"`
  const json = stdout.toJSON()
  return json
}
