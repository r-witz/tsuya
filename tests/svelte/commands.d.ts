// The browser commands of vitest.config.ts, as the tests call them.
import '@vitest/browser-playwright'; // the Playwright provider types the CDP session
import 'vitest/browser';

declare module 'vitest/browser' {
  interface BrowserCommands {
    /** Playwright's page.emulateMedia: reducedMotion, colorScheme, forcedColors, contrast. */
    emulateMedia: (options: {
      reducedMotion?: 'reduce' | 'no-preference' | null;
      colorScheme?: 'light' | 'dark' | 'no-preference' | null;
      forcedColors?: 'active' | 'none' | null;
      contrast?: 'more' | 'no-preference' | null;
    }) => Promise<void>;
  }
}
