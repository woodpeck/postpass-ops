import { $ } from 'bun'

export const format = async (filePathAndName: string) => {
  await $`prettier './${filePathAndName}' --write`
}
