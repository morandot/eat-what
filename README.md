# EatWhat

[中文](./README.zh-CN.md)

A pixel-art random picker for quickly deciding "what to eat / what to drink."

## Features

- Two picker modes: “What to Eat” and “What to Drink”
- Built-in pixel-art SVG icons, matched to each result by name
- Automatically saves pick history locally — persists after refresh, never uploaded
- Click any history entry to instantly recall that result
- One-click clear for all pick history
- Toggleable sound effects

## Tech Stack

- Vue 3
- Vite
- TypeScript
- Plain CSS

## Getting Started

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
```

Build output goes to `dist/`.

## Customization

Food and drink lists, along with their pixel SVG data, are located in:

- `src/data/foods.ts`

The current implementation uses a direct "name → SVG pixel data" mapping — no emoji and no fuzzy category icons.

Analytics (Optional)

To enable analytics on your own deployment, set these environment variables (e.g. in Vercel):

- `VITE_SELINE_TOKEN⁠`
- `VITE_GA_ID⁠`

See ⁠`.env.example⁠` for reference. Scripts only load when the variables are present.

## Search Engine Indexing (Bing / IndexNow)

The site ships everything Bing needs to crawl and index it quickly:

- `public/robots.txt` — allows all crawlers and points at the sitemap
- `public/sitemap.xml` — the canonical URL list
- `public/<key>.txt` — the IndexNow key file, served from the site root
- `index.html` — canonical URL, `robots` meta, Open Graph / Twitter cards, and WebApplication + ItemList JSON-LD

### Submitting URLs to IndexNow

IndexNow pushes changed URLs to Bing, Yandex, Seznam and Naver immediately, instead of waiting for the next crawl.

```bash
npm run indexnow              # submit every <loc> in public/sitemap.xml
npm run indexnow -- <url>...  # submit specific URLs
```

The script preflights the key file (it must return HTTP 200 and match its filename), then posts to `https://api.indexnow.org/indexnow`. Run it after each deploy that changes content.

This runs automatically via `.github/workflows/indexnow.yml`, which fires on Vercel's `deployment_status: success` so URLs are only pushed once they are actually live. Trigger it manually from the Actions tab if needed.

To rotate the key: add a new `public/<newkey>.txt` containing the key itself, delete the old one, deploy, then re-run `npm run indexnow`.

### One-time setup in Bing Webmaster Tools

1. Add the site at <https://www.bing.com/webmasters> — verification can reuse the Google Search Console property or a DNS/meta tag.
2. **Sitemaps** → submit `https://eatwhat.nopress.net/sitemap.xml`.
3. **IndexNow** → opt in. Submissions then appear under *URLs submitted in the last 10 hours* with source `Self`.
4. Optionally use **URL Inspection** to request indexing of individual URLs.

## License

[MIT License](./LICENSE)