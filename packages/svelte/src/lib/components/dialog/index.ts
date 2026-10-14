// Dialog, in parts: Dialog.Root, Dialog.Trigger, Dialog.Content, Dialog.Title, Dialog.Description, Dialog.Actions and
// Dialog.Close.
import Actions from './DialogActions.svelte';
import Close from './DialogClose.svelte';
import Content from './DialogContent.svelte';
import Description from './DialogDescription.svelte';
import Root from './DialogRoot.svelte';
import Title from './DialogTitle.svelte';
import Trigger from './DialogTrigger.svelte';

// typed by name, so that its declaration can be written
export const Dialog: {
  Root: typeof Root;
  Trigger: typeof Trigger;
  Content: typeof Content;
  Title: typeof Title;
  Description: typeof Description;
  Actions: typeof Actions;
  Close: typeof Close;
} = { Root, Trigger, Content, Title, Description, Actions, Close };
