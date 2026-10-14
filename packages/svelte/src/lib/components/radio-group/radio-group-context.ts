// The context a RadioGroup gives its Radio children (DESIGN.md, RadioGroup): the shared name native radios need, the
// selected value, and how a Radio changes it.
import { getContext, setContext } from 'svelte';

const KEY = Symbol('tsuya.radio-group');

export interface RadioGroupContext {
  readonly name: string;
  readonly value: string | undefined;
  select: (value: string) => void;
}

export function setRadioGroup(context: RadioGroupContext): void {
  setContext(KEY, context);
}

/** The group a Radio renders in; throws if there is none, since a Radio has no meaning on its own. */
export function getRadioGroup(): RadioGroupContext {
  const group = getContext<RadioGroupContext | undefined>(KEY);
  if (!group) throw new Error('tsuya: <Radio> must be used inside a <RadioGroup>.');
  return group;
}
