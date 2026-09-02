import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: 'list',
  use: {
    baseURL: process.env.EATWHAT_URL || 'http://localhost:5174',
    trace: 'on-first-retry',
  },
  webServer: process.env.EATWHAT_URL
    ? undefined
    : {
        command: 'pnpm dev',
        url: 'http://localhost:5174',
        reuseExistingServer: !process.env.CI,
        timeout: 30000,
      },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
})
