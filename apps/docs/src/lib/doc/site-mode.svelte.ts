// The site's mode, shared by the shell (which sets it from its menu) and the live previews (which start from what
// it resolves to): `system` follows the reader's colour scheme, the other two force one.
import { MediaQuery } from 'svelte/reactivity';

export type SiteMode = 'system' | 'light' | 'dark';

const prefersDark = new MediaQuery('(prefers-color-scheme: dark)');

export const site = $state<{ mode: SiteMode }>({ mode: 'system' });

/** The mode the site is shown in, never `system`. */
export function resolvedMode(): 'light' | 'dark' {
  if (site.mode !== 'system') return site.mode;
  return prefersDark.current ? 'dark' : 'light';
}
