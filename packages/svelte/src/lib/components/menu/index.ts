// Menu, with its parts as Menu.Root, Menu.Trigger and so on.
import CheckboxItem from './MenuCheckboxItem.svelte';
import Content from './MenuContent.svelte';
import Item from './MenuItem.svelte';
import Label from './MenuLabel.svelte';
import RadioGroup from './MenuRadioGroup.svelte';
import RadioItem from './MenuRadioItem.svelte';
import Root from './MenuRoot.svelte';
import Separator from './MenuSeparator.svelte';
import Trigger from './MenuTrigger.svelte';

// typed by name, so that its declaration can be written
export const Menu: {
  Root: typeof Root;
  Trigger: typeof Trigger;
  Content: typeof Content;
  Item: typeof Item;
  CheckboxItem: typeof CheckboxItem;
  RadioGroup: typeof RadioGroup;
  RadioItem: typeof RadioItem;
  Separator: typeof Separator;
  Label: typeof Label;
} = { Root, Trigger, Content, Item, CheckboxItem, RadioGroup, RadioItem, Separator, Label };
