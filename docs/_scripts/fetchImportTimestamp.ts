import z from 'zod'
import { curlData } from './utils/curl'

// [
//   ({
//     value: 'false',
//     property: 'attributes',
//   },
//   {
//     value: '2',
//     property: 'db_format',
//   },
//   {
//     value: '/nvme/flatnodes-tile/flatnodes.dat',
//     property: 'flat_node_file',
//   },
//   {
//     value: '2025-03-04T14:59:15Z',
//     property: 'import_timestamp',
//   },
//   {
//     value: 'pgsql',
//     property: 'output',
//   },
//   {
//     value: 'planet_osm',
//     property: 'prefix',
//   },
//   {
//     value: '/srv/openstreetmap-carto/openstreetmap-carto.style',
//     property: 'style',
//   },
//   {
//     value: 'true',
//     property: 'updatable',
//   },
//   {
//     value: '1.11.0',
//     property: 'version',
//   },
//   {
//     value: '2025-03-28T13:32:54Z',
//     property: 'current_timestamp',
//   },
//   {
//     value: 'https://planet.osm.org/replication/minute/',
//     property: 'replication_base_url',
//   },
//   {
//     value: '6532713',
//     property: 'replication_sequence_number',
//   },
//   {
//     value: '2025-03-28T13:32:54Z',
//     property: 'replication_timestamp',
//   })
// ]

export async function fetchImportTimestamp() {
  const query = `
    SELECT value as timestamp
    FROM osm2pgsql_properties
    WHERE property = 'import_timestamp'
  `

  const schema = z.object({ result: z.array(z.object({ timestamp: z.coerce.date() })) })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  return data.result[0]?.timestamp
}

async function main() {
  console.log('fetchImportTimestamp', await fetchImportTimestamp())
}
main()
