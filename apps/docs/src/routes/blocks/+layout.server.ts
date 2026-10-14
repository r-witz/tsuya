// The code of every block's page, highlighted while the site is prerendered: its example in lib/examples/blocks,
// named after the block (content-page → ContentPage.svelte), also as text for the copy button. BlockPage.svelte reads
// it; the index has none.
import { highlightCode } from '#lib/server/highlight.ts';

import type { LayoutServerLoad } from './$types';

const sources = import.meta.glob<string>('/src/lib/examples/blocks/*.svelte', {
  query: '?raw',
  import: 'default',
  eager: true,
});

export const load: LayoutServerLoad = async ({ url }) => {
  const slug = url.pathname.split('/')[2] ?? '';
  const name = slug.replace(/(?:^|-)(\w)/g, (_, letter: string) => letter.toUpperCase());
  const source = sources[`/src/lib/examples/blocks/${name}.svelte`];
  return source === undefined ? {} : { example: { source, html: await highlightCode(source, 'svelte') } };
};
