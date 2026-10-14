import { fileURLToPath } from 'node:url';

import { svelte } from '@sveltejs/vite-plugin-svelte';
import { playwright } from '@vitest/browser-playwright';
import { defineConfig } from 'vitest/config';

// Three projects: node (the build and the engine), ssr (Svelte components rendered on the server) and
// svelte (components and primitives in Chromium, Firefox and WebKit). TSUYA_BROWSERS narrows the browsers where one
// cannot launch: TSUYA_BROWSERS=chromium,firefox npm test.
const browsers = (process.env['TSUYA_BROWSERS'] ?? 'chromium,firefox,webkit').split(',');
// @tsuya/svelte imports @tsuya/core by name: in the repository that is core's source (as in the TypeScript configs'
// `paths`), so that the tests and the type checks need no build of core first
const resolve = {
  alias: [
    { find: /^@tsuya\/core$/, replacement: fileURLToPath(new URL('packages/core/src/index.ts', import.meta.url)) },
    {
      find: /^@tsuya\/core\/primitives$/,
      replacement: fileURLToPath(new URL('packages/core/src/primitives/index.ts', import.meta.url)),
    },
  ],
};

export default defineConfig({
  test: {
    projects: [
      { test: { name: 'node', include: ['tests/core/**/*.test.ts', 'tests/scripts/**/*.test.ts'] } },
      {
        plugins: [svelte({ configFile: false })],
        resolve,
        test: { name: 'ssr', include: ['tests/svelte/ssr/*.test.ts'] },
      },
      {
        plugins: [svelte({ configFile: false })],
        resolve,
        test: {
          name: 'svelte',
          include: ['tests/svelte/*.test.ts'],
          setupFiles: ['tests/svelte/setup.ts'],
          browser: {
            enabled: true,
            provider: playwright(),
            headless: true,
            screenshotFailures: false,
            instances: [
              ...browsers.map((browser) => ({ browser: browser as 'chromium' | 'firefox' | 'webkit' })),
              // a phone, for the touch targets (touch through Chromium's emulation)
              ...(browsers.includes('chromium')
                ? [
                    {
                      browser: 'chromium' as const,
                      name: 'chromium-touch',
                      include: ['tests/svelte/targets.test.ts'],
                      provider: playwright({ contextOptions: { hasTouch: true, isMobile: true } }),
                    },
                  ]
                : []),
            ],
            // the system settings the material follows, such as reduced motion (tests/svelte/commands.d.ts); WebKit
            // keeps reduced motion after a reset to null, so a reset is to no-preference
            commands: {
              emulateMedia: ({ page }, options: Parameters<typeof page.emulateMedia>[0]) =>
                page.emulateMedia(
                  options?.reducedMotion === null ? { ...options, reducedMotion: 'no-preference' } : options,
                ),
            },
          },
        },
      },
    ],
  },
});
