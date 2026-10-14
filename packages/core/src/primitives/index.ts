// @tsuya/core/primitives: the behaviours of the components, without a framework. Each is an attachment: call it with
// an element, and call what it returns to detach it (a Svelte component takes it with {@attach …}).
export type { Attachment } from './attachment.ts';
export {
  anchored,
  place,
  type Align,
  type AnchoredOptions,
  type Placement,
  type PlaceOptions,
  type Rect,
  type Side,
} from './anchored.ts';
export { announce, HIDDEN } from './announcer.ts';
export { dismissable, type DismissableOptions, type DismissReason } from './dismissable.ts';
export { focusReturn, focusScope, tabbables, type FocusScopeOptions } from './focus.ts';
export { modal } from './modal.ts';
export { rovingFocus, type RovingOptions } from './roving.ts';
export { swipeDown, type SwipeOptions } from './swipe.ts';
export { currentHost, topLayer, watchHosts } from './top-layer.ts';
export { typeahead, typed, TYPEAHEAD_TIMEOUT } from './typeahead.ts';
