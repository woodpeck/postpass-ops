import { writeFile } from 'fs/promises'
import z from 'zod'
import { fetchImportTimestamp } from './fetchImportTimestamp'
import { fetchTables } from './fetchTables'
import { RELEVANT_TABLES } from './utils/constants'
import { curlData } from './utils/curl'
import { format } from './utils/format'
import { log } from './utils/log'

async function fetchRowCount(table: string) {
  const query = `
    SELECT COUNT(*) AS row_count
    FROM ${table}
  `

  const schema = z.object({ result: z.array(z.object({ row_count: z.number().or(z.null()) })) })
  const data = await curlData<z.infer<typeof schema>>(query, schema)
  // console.log('fetchRowCount', data.result)
  return data.result[0]?.row_count || 0
}

async function rowCounts(tables: Awaited<ReturnType<typeof fetchTables>>) {
  const tableData = []

  for (const table of tables) {
    const rowCount = await fetchRowCount(table)
    tableData.push({ table, rowCount })
  }
  return tableData
}

async function generateMarkdown(tableData: Awaited<ReturnType<typeof rowCounts>>) {
  const importTimestamp = await fetchImportTimestamp()
  const markdown = `
# Database Tables

| Table Name       | Row Count |
|------------------|-----------|
${tableData
  .map(({ table, rowCount }) => {
    const count = rowCount.toLocaleString('en', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })
    const name = RELEVANT_TABLES.includes(table) ? `[${table}](./${table}.md)` : table

    return `| ${name} | ${count} |`
  })
  .join('\n')}

Import date ${importTimestamp?.toISOString()}
`

  const filename = '../index.md'
  await writeFile(filename, markdown.trim())
  await format(filename)
  log(`${filename} has been generated.`)
}

async function main() {
  const tables = await fetchTables()
  const tableData = await rowCounts(tables)

  generateMarkdown(tableData)
}

main()
