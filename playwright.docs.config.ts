import { defineConfig, devices } from '@playwright/test';

// Chromium only: the components are tested in every engine by tests/svelte and tests/web; this suite checks the site.
// Against the built, prerendered site through vite preview, not a dev server, so this tests exactly what a static
// host would serve.
export default defineConfig({
  testDir: 'tests/docs',
  forbidOnly: !!process.env['CI'],
  reporter: process.env['CI'] ? 'github' : 'list',
  webServer: {
    command: 'npm run -w docs build && npm run -w docs preview -- --port 4174 --strictPort',
    url: 'http://localhost:4174',
    // never reused: a preview started before the last build serves the files it listed then, so new ones 404
    reuseExistingServer: false,
    // the build is part of it: a CI runner has two or four cores
    timeout: 300_000,
  },
  use: { baseURL: 'http://localhost:4174' },
  // the project's name is part of the visual baselines' file names
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
