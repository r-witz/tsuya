// Sheet, in parts: Sheet.Root, Sheet.Content and Sheet.Title.
import Content from './SheetContent.svelte';
import Root from './SheetRoot.svelte';
import Title from './SheetTitle.svelte';

// typed by name, so that its declaration can be written
export const Sheet: {
  Root: typeof Root;
  Content: typeof Content;
  Title: typeof Title;
} = { Root, Content, Title };
