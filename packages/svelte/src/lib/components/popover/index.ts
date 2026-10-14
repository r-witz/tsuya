// Popover, with its parts as Popover.Root, Popover.Trigger and Popover.Content.
import Content from './PopoverContent.svelte';
import Root from './PopoverRoot.svelte';
import Trigger from './PopoverTrigger.svelte';

// typed by name, so that its declaration can be written
export const Popover: {
  Root: typeof Root;
  Trigger: typeof Trigger;
  Content: typeof Content;
} = { Root, Trigger, Content };
