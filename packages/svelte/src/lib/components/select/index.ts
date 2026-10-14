// Select, with its composed parts as Select.Root, Select.Trigger and so on.
import Content from './SelectContent.svelte';
import Group from './SelectGroup.svelte';
import Item from './SelectItem.svelte';
import Root from './SelectRoot.svelte';
import Separator from './SelectSeparator.svelte';
import Trigger from './SelectTrigger.svelte';
import Simple from './Select.svelte';

// typed by name, so that its declaration can be written; marked pure, or an app that never uses it still bundles
// it (Object.assign changes its first argument)
export const Select: typeof Simple & {
  Root: typeof Root;
  Trigger: typeof Trigger;
  Content: typeof Content;
  Item: typeof Item;
  Group: typeof Group;
  Separator: typeof Separator;
} = /* @__PURE__ */ Object.assign(Simple, { Root, Trigger, Content, Item, Group, Separator });
