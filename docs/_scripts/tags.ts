import { writeFile } from 'fs/promises'
import z from 'zod'
import { fetchImportTimestamp } from './fetchImportTimestamp'
import { RELEVANT_TABLES } from './utils/constants'
import { curlData } from './utils/curl'
import { format } from './utils/format'
import { log } from './utils/log'

async function fetchRowData(table: string) {
  const query = `
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_name = '${table}'
  `

  const schema = z.object({
    result: z.array(z.object({ column_name: z.string(), data_type: z.string() })),
  })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  // console.log('fetchRowData', data.result)
  return data.result.sort((a, b) => a.column_name.localeCompare(b.column_name))
}

async function fetchTagsKeys(table: string) {
  const query = `
SELECT DISTINCT skeys(tags) AS key
FROM ${table}
TABLESAMPLE SYSTEM (1)
  `

  const schema = z.object({
    result: z.array(z.object({ key: z.string() })),
  })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  // console.log('fetchTagsKeys', data.result)
  return data.result.sort((a, b) => a.key.localeCompare(b.key))
}

async function generateMarkdown() {
  const importTimestamp = await fetchImportTimestamp()

  RELEVANT_TABLES.forEach(async (table) => {
    log('Starting', table)

    const rowData = await fetchRowData(table)
    const tagsKeys = await fetchTagsKeys(table)
    const markdown = `
# \`${table}\`

## Rows

Some tags have separate rows.

| Row       | Row type |
|------------------|-----------|
${rowData.map(({ column_name, data_type }) => `| ${column_name} | ${data_type} |`).join('\n')}

## Tags in \`tags\`

Based on a sample of 1 % of the data due to timouts.

| Tag       |
|------------------|
${tagsKeys.map(({ key }) => `| ${key} |`).join('\n')}

Import date ${importTimestamp?.toISOString()}
`
    const filename = `../${table}.md`
    await writeFile(filename, markdown.trim())
    await format(filename)
    log(`${filename} has been generated.`)
  })
}

async function main() {
  generateMarkdown()
}

main()
