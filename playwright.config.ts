import { defineConfig, devices } from '@playwright/test';

// Chromium, Firefox and WebKit in CI; Safari itself is checked by hand before a release. TSUYA_BROWSERS narrows the
// browsers where one cannot launch, as for Vitest: TSUYA_BROWSERS=chromium,firefox npm run test:web.
const browsers = (process.env['TSUYA_BROWSERS'] ?? 'chromium,firefox,webkit').split(',');

export default defineConfig({
  testDir: 'tests/web',
  forbidOnly: !!process.env['CI'],
  reporter: process.env['CI'] ? 'github' : 'list',
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ].filter((project) => browsers.includes(project.name)),
});
