// Accordion, in parts: Accordion.Root, Accordion.Item, Accordion.Trigger and Accordion.Content.
import Content from './AccordionContent.svelte';
import Item from './AccordionItem.svelte';
import Root from './AccordionRoot.svelte';
import Trigger from './AccordionTrigger.svelte';

// typed by name, so that its declaration can be written
export const Accordion: {
  Root: typeof Root;
  Item: typeof Item;
  Trigger: typeof Trigger;
  Content: typeof Content;
} = { Root, Item, Trigger, Content };
