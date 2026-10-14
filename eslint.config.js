// Linting for development only: TypeScript with type information, Svelte, and Prettier owning the
// formatting. Generated files are left out: the build checks them instead.
import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import { defineConfig } from 'eslint/config';
import svelte from 'eslint-plugin-svelte';
import globals from 'globals';
import ts from 'typescript-eslint';

export default defineConfig(
  {
    ignores: [
      '**/node_modules/',
      '**/dist/',
      '**/build/',
      '**/.svelte-kit/',
      'test-results/',
      'playwright-report/',
      '.claude/',
      'packages/flutter/',
      'packages/core/src/tokens.ts',
    ],
  },
  js.configs.recommended,
  ts.configs.strictTypeChecked,
  svelte.configs.recommended,
  prettier,
  svelte.configs.prettier,
  {
    languageOptions: {
      globals: { ...globals.node, ...globals.browser },
      parserOptions: {
        projectService: true,
        extraFileExtensions: ['.svelte'],
      },
    },
  },
  {
    files: ['**/*.svelte', '**/*.svelte.ts'],
    languageOptions: { parserOptions: { parser: ts.parser } },
  },
  { files: ['**/*.js', '**/*.mjs'], extends: [ts.configs.disableTypeChecked] },
  // a rule for SvelteKit apps: a component of the library links where the app tells it, already resolved
  { files: ['packages/svelte/**'], rules: { 'svelte/no-navigation-without-resolve': 'off' } },
);
