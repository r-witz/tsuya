// The value of a control as a form sends it, in a hidden input: text as it is, anything else in JSON.
export const formValue = (value: unknown): string =>
  value === undefined ? '' : typeof value === 'string' ? value : JSON.stringify(value);
