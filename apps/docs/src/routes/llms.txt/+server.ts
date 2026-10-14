// /llms.txt: what an agent reads first. It points at DESIGN.md, the contract, and lists every page of the site
// with its one-line summary, grouped as the page tree is (#lib/content/nav.ts).
import { NAV } from '#lib/content/nav.ts';

import type { RequestHandler } from './$types';

export const prerender = true;

export const GET: RequestHandler = () => {
  const lines = [
    '# tsuya',
    '',
    '> A design system for Svelte 5 and Flutter: neutral surfaces, familiar layouts, one material that comes from the',
    '> content on screen.',
    '',
    'Before changing a user interface built with tsuya, read [DESIGN.md](/DESIGN.md): the contract both packages',
    "implement, with every token's name and every component's rules. The pages below are this site's.",
    ...NAV.flatMap((group) => [
      '',
      `## ${group.label}`,
      '',
      ...group.entries.map((entry) => `- [${entry.title}](/${entry.slug}): ${entry.summary}`),
    ]),
  ];
  return new Response(lines.join('\n') + '\n', { headers: { 'content-type': 'text/plain; charset=utf-8' } });
};
