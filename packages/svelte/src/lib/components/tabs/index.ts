// Tabs, in parts: Tabs.Root, Tabs.List, Tabs.Trigger and Tabs.Content.
import Content from './TabsContent.svelte';
import List from './TabsList.svelte';
import Root from './TabsRoot.svelte';
import Trigger from './TabsTrigger.svelte';

// typed by name, so that its declaration can be written
export const Tabs: {
  Root: typeof Root;
  List: typeof List;
  Trigger: typeof Trigger;
  Content: typeof Content;
} = { Root, List, Trigger, Content };
