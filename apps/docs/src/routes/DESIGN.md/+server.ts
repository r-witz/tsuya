// /DESIGN.md: the repository's DESIGN.md, the contract every package ships, as it is, for an agent to read.
import design from '../../../../../DESIGN.md?raw';

import type { RequestHandler } from './$types';

export const prerender = true;

export const GET: RequestHandler = () =>
  new Response(design, { headers: { 'content-type': 'text/markdown; charset=utf-8' } });
