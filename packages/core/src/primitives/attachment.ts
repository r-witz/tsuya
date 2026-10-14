/**
 * A behaviour attached to an element: call it with the element, and call what it returns to detach it. Svelte's
 * `{@attach …}` takes it as it is.
 */
export type Attachment<T extends Element> = (element: T) => () => void;
