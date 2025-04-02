import chalk from 'chalk'

export const log = (scope: string, ...rest: Array<string | string[] | Record<string, any>>) => {
  console.log(chalk.inverse(scope), ...rest)
}
