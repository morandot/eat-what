import { test, expect, type Page } from '@playwright/test'

const BASE = process.env.EATWHAT_URL || 'http://localhost:5173'

async function boot(page: Page) {
  await page.goto(BASE, { waitUntil: 'domcontentloaded' })
  // Wait for Vue to mount
  await page.waitForSelector('#app', { state: 'visible' })
  // Wait for pixel font or app-root
  await page.waitForSelector('.app-root', { state: 'visible', timeout: 15000 })
}

test.describe('EatWhat Smoke Test', () => {
  test.beforeEach(async ({ page }) => {
    await boot(page)
  })

  test('page loads with correct title and brand', async ({ page }) => {
    await expect(page).toHaveTitle('EatWhat - 像素风随机食物抽取器')
    await expect(page.locator('.brand-name')).toHaveText('EATWHAT')
  })

  test('hero subtitle is visible', async ({ page }) => {
    await expect(page.locator('.hero-subtitle')).toContainText('解决「这餐吃什么」的终极难题')
  })

  test('tab switcher shows 吃什么 / 喝什么', async ({ page }) => {
    await expect(page.locator('.tab-btn').first()).toContainText('吃什么')
    await expect(page.locator('.tab-btn').nth(1)).toContainText('喝什么')
  })

  test('result display shows initial state', async ({ page }) => {
    await expect(page.locator('.inline-text')).toContainText('等待抽取中')
  })

  test('roll button shows "开始抽取" initially', async ({ page }) => {
    await expect(page.locator('.btn-content')).toContainText('开始抽取')
  })

  test('clicking roll triggers animation and shows result', async ({ page }) => {
    const btn = page.locator('.main-roll-btn')
    await btn.click()

    // Should show rolling state
    await expect(page.locator('.btn-content')).toContainText('抽取中')

    // Wait for roll to complete (max 15 rounds * 80ms + slowdown)
    await page.waitForFunction(() => {
      const btn = document.querySelector('.btn-content')
      return btn && !btn.textContent?.includes('抽取中')
    }, { timeout: 10000 })

    // Should show result and "开始抽取" again
    await expect(page.locator('.btn-content')).toContainText('开始抽取')
  })

  test('switching tab from 吃什么 to 喝什么', async ({ page }) => {
    const drinkTab = page.locator('.tab-btn').nth(1)
    await drinkTab.click()
    await expect(drinkTab).toHaveClass(/is-active/)
  })

  test('history list shows entries after rolling', async ({ page }) => {
    const btn = page.locator('.main-roll-btn')
    await btn.click()
    await page.waitForFunction(() => {
      const btn = document.querySelector('.btn-content')
      return btn && !btn.textContent?.includes('抽取中')
    }, { timeout: 10000 })

    // History should have at least one entry
    const count = await page.locator('.count').textContent()
    expect(parseInt(count || '0')).toBeGreaterThanOrEqual(1)
  })

  test('sound toggle button exists and is clickable', async ({ page }) => {
    const soundBtn = page.locator('.icon-btn')
    await expect(soundBtn).toBeVisible()
    await soundBtn.click()
    // Should not crash
    await expect(soundBtn).toBeVisible()
  })

  test('footer is visible with NoPress link', async ({ page }) => {
    await expect(page.locator('.app-footer')).toBeVisible()
    await expect(page.locator('.footer-link')).toContainText('NoPress')
  })

  test('layout does not shift after rolling', async ({ page }) => {
    // Record layout before roll
    const beforeLayout = await page.evaluate(() => {
      const root = document.querySelector('.app-root')
      return root ? root.getBoundingClientRect().width : 0
    })

    const btn = page.locator('.main-roll-btn')
    await btn.click()
    await page.waitForFunction(() => {
      const btn = document.querySelector('.btn-content')
      return btn && !btn.textContent?.includes('抽取中')
    }, { timeout: 10000 })

    const afterLayout = await page.evaluate(() => {
      const root = document.querySelector('.app-root')
      return root ? root.getBoundingClientRect().width : 0
    })

    expect(afterLayout).toBe(beforeLayout)
  })

  test('clear history button works', async ({ page }) => {
    // Roll once to create history
    await page.locator('.main-roll-btn').click()
    await page.waitForFunction(() => {
      const btn = document.querySelector('.btn-content')
      return btn && !btn.textContent?.includes('抽取中')
    }, { timeout: 10000 })

    // Click clear
    await page.locator('.clear-btn').click()

    // Should show empty state
    await expect(page.locator('.empty-state')).toContainText('暂无抽取记录')
  })
})
