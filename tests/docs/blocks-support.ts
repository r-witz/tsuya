// Shared by the Blocks specs.
import type { Page } from '@playwright/test';

/** A block's live example frame, found by its name. */
export const frameOf = (page: Page, title: string) =>
  page.getByRole('region', { name: `${title}, live example`, exact: true });
