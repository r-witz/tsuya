// The code every component page shows, highlighted while the site is prerendered: each example of the page's folder
// in lib/examples, by its file name ('Primary'), with the HTML it renders folded under it, and each Dart snippet of
// its flutter.ts, by its export name ('FLUTTER_PRIMARY'). A page reads them with #lib/doc/code.ts.
import { format } from 'prettier';
import type { Component } from 'svelte';
import { render } from 'svelte/server';

import { highlightCode } from '#lib/server/highlight.ts';
import Markup from '#lib/server/Markup.svelte';

import type { LayoutServerLoad } from './$types';

const examples = import.meta.glob<string>('/src/lib/examples/*/*.svelte', {
  query: '?raw',
  import: 'default',
  eager: true,
});
const components = import.meta.glob<Component>('/src/lib/examples/*/*.svelte', { import: 'default', eager: true });
const snippets = import.meta.glob<Record<string, string>>('./*/flutter.ts', { eager: true });

/**
 * The HTML an example renders, for a page without a framework: what the server renders, less what only Svelte reads
 * (its hydration comments, the attributes that hold an image's load or error until it hydrates) and the classes of the
 * example's own styles.
 */
async function markup(example: Component): Promise<string> {
  const { body } = render(Markup, { props: { example } });
  const html = body
    .slice(body.indexOf('<tsuya-example>') + '<tsuya-example>'.length, body.lastIndexOf('</tsuya-example>'))
    .replace(/<!--[^]*?-->/g, '')
    .replace(/ on[a-z]+="this\.__e=event"/g, '')
    .replace(/ ?\bsvelte-[a-z0-9]+\b/g, '')
    .replace(/ class=""/g, '');
  return format(html, { parser: 'html', printWidth: 120 });
}

export const load: LayoutServerLoad = async ({ url }) => {
  // '/components/button' → 'button'; the index has no slug, and no code
  const slug = url.pathname.split('/')[2] ?? '';
  const folder = `/src/lib/examples/${slug}/`;
  const code: Record<string, string> = {};
  for (const [path, source] of Object.entries(examples)) {
    const example = components[path];
    if (!path.startsWith(folder) || !example) continue;
    const html = await highlightCode(await markup(example), 'html');
    code[path.slice(folder.length, -'.svelte'.length)] =
      `${await highlightCode(source, 'svelte')}<details class="markup"><summary>HTML</summary>${html}</details>`;
  }
  for (const [name, source] of Object.entries(snippets[`./${slug}/flutter.ts`] ?? {}))
    code[name] = await highlightCode(source, 'dart');
  return { code };
};
