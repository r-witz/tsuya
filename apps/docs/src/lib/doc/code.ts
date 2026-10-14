// The highlighted code of the current component page, by name, as routes/components/+layout.server.ts loads it:
// code('Primary') is lib/examples/<page>/Primary.svelte and the HTML it renders, code('FLUTTER_PRIMARY') the snippet
// of the page's flutter.ts.
import { page } from '$app/state';

/** Throws on an unknown name, so that a page cannot show code that does not exist: the build fails instead. */
export function code(name: string): string {
  const html = page.data.code?.[name];
  if (html === undefined) throw new Error(`${page.url.pathname} has no code named ${name}`);
  return html;
}
