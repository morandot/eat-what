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

## License

[MIT License](./LICENSE)