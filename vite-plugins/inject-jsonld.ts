import { readFileSync } from 'node:fs'
import type { Plugin } from 'vite'

const FOODS_SRC = 'src/data/foods.ts'
const PLACEHOLDER = '<!-- @inject-itemlist-jsonld -->'

const extractNames = (src: string, name: string): string[] => {
  const m = src.match(new RegExp(`export const ${name} = \\[([\\s\\S]*?)\\] as const`))
  if (!m) throw new Error(`Cannot find ${name} in ${FOODS_SRC}`)
  return [...m[1].matchAll(/'([^']+)'/g)].map(x => x[1])
}

const buildItemList = (name: string, items: string[]): object => ({
  '@context': 'https://schema.org',
  '@type': 'ItemList',
  name,
  itemListElement: items.map((n, i) => ({ '@type': 'ListItem', position: i + 1, name: n }))
})

export const injectItemListJsonLd = (): Plugin => ({
  name: 'inject-itemlist-jsonld',
  transformIndexHtml(html) {
    const src = readFileSync(FOODS_SRC, 'utf8')
    const lists = [
      buildItemList('EatWhat 内置美食列表', extractNames(src, 'FOODS')),
      buildItemList('EatWhat 内置饮品列表', extractNames(src, 'DRINKS'))
    ]
    const tag = `<script type="application/ld+json">${JSON.stringify(lists)}</script>`
    if (!html.includes(PLACEHOLDER)) {
      throw new Error(`Missing placeholder ${PLACEHOLDER} in index.html`)
    }
    return html.replace(PLACEHOLDER, tag)
  }
})
