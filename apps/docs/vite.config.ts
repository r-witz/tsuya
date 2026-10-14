// The docs site: prerendered by @sveltejs/adapter-static; pages can be written in Markdown (mdsvex) with
// live Svelte examples. @sveltejs/kit 3 folds its configuration (what used to be svelte.config.js) into this plugin.
// Syntax highlighting (shiki) happens where each page pre-renders its code blocks at build time
// (src/lib/server/highlight.ts); mdsvex's own `highlight` option below reaches the same helper so a fenced code
// block typed directly in a .svx page is highlighted the same way.

import { readFileSync } from 'node:fs';

import adapter from '@sveltejs/adapter-static';
import { sveltekit } from '@sveltejs/kit/vite';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import { escapeSvelte, mdsvex } from 'mdsvex';
import { defineConfig, type Plugin } from 'vite';

import { highlightCode } from './src/lib/server/highlight.ts';

// `import size from './shot.png?size'`: the [width, height] of a PNG, read from its header, so that an <img> can carry
// both before the file has loaded (GalleryShot.svelte)
const pngSize = (): Plugin => ({
  name: 'png-size',
  enforce: 'pre',
  load(id) {
    if (!id.endsWith('.png?size')) return null;
    // 8 bytes of signature, 4 of chunk length, 4 of "IHDR", then the width and the height, each 4 bytes big-endian
    const header = readFileSync(id.slice(0, -'?size'.length)).subarray(16, 24);
    return `export default [${String(header.readUInt32BE(0))}, ${String(header.readUInt32BE(4))}];`;
  },
});

export default defineConfig({
  plugins: [
    pngSize(),
    sveltekit({
      // .md: the repository's CHANGELOG.md, shown as the Changelog page as it is
      extensions: ['.svelte', '.svx', '.md'],
      preprocess: [
        mdsvex({
          extensions: ['.svx', '.md'],
          highlight: {
            async highlighter(code, lang) {
              const html = escapeSvelte(await highlightCode(code, lang ?? 'text'));
              // mdsvex splices this HTML straight into the page's own markup (unlike CodeBlock.svelte's {@html}),
              // so the compiler lints it directly; shiki's own tabindex="0" on <pre> (a deliberate affordance: a
              // scrollable code block should be focusable) reads as a11y_no_noninteractive_tabindex there, a false
              // positive this silences instead of losing the affordance.
              return `<!-- svelte-ignore a11y_no_noninteractive_tabindex -->\n${html}`;
            },
          },
        }),
        vitePreprocess(),
      ],
      adapter: adapter(),
      // every route is prerendered to static files; a broken internal link or anchor fails the build
      prerender: { handleHttpError: 'fail', handleMissingId: 'fail' },
    }),
  ],
});
