// Field, TextInput, Textarea and SearchInput (DESIGN.md, Inputs; G5, G6, G9): the values of the field box, the same
// for a select's trigger, the label, hint and error wired to the control, the clear and show-password buttons, a text
// area that grows, the search pill.
import { expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { labelsFr } from '../../packages/core/src/labels.ts';
import { light } from '../../packages/core/src/tokens.ts';
import FieldBoxes from './fixtures/FieldBoxes.svelte';
import Form from './fixtures/Form.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string, pseudo?: string) =>
  getComputedStyle(element, pseudo).getPropertyValue(property);

test('the label names the control, the hint describes it, required is announced and not marked', async () => {
  const screen = await render(Form, { required: true });
  const email = screen.getByRole('textbox', { name: 'Email' });
  await expect.element(email).toHaveAccessibleDescription('Your work email');
  await expect.element(email).toBeRequired();
  await expect.element(email).not.toHaveAttribute('aria-invalid');
  await screen.rerender({ required: false, optional: true });
  await expect.element(screen.getByRole('textbox', { name: 'Email Optional' })).toBeInTheDocument();
});

test('an error takes the place of the hint, marks the control invalid and is its error message', async () => {
  const screen = await render(Form, { error: 'Enter an email address' });
  const email = screen.getByRole('textbox', { name: 'Email' });
  await expect.element(email).toBeInvalid();
  await expect.element(email).toHaveAccessibleDescription('Enter an email address');
  await expect.element(email).toHaveAccessibleErrorMessage('Enter an email address');
  expect(screen.container.textContent).not.toContain('Your work email');
  const box = email.element().parentElement as HTMLElement;
  expect(hexOf(box, 'border-top-color')).toBe(light.color.danger);
  expect(hexOf(screen.getByText('Enter an email address').element())).toBe(light.color.danger);
});

test('the field box: its height, boundary, radius, padding and type; the placeholder in text-muted', async () => {
  const screen = await render(Form);
  const input = screen.getByRole('textbox', { name: 'Email' }).element();
  const box = input.parentElement as HTMLElement;
  expect(box.getBoundingClientRect().height).toBe(44);
  expect(style(box, 'border-top-width')).toBe('1px');
  expect(hexOf(box, 'border-top-color')).toBe(light.color.borderStrong.slice(0, 7));
  expect(style(box, 'border-top-left-radius')).toBe('12px');
  expect(style(box, 'padding-left')).toBe('12px');
  expect(style(input, 'font-size')).toBe('15px');
  expect(hexOf(input, 'color')).toBe(light.color.text.slice(0, 7));
  const muted = rgbaOfHex(light.color.textMuted);
  expect(rgbaOf(screen.getByText('Email').element())).toEqual(muted);
  expect(rgbaOf(screen.getByText('Your work email').element())).toEqual(muted);
  expect(rgbaOf(input, 'color', '::placeholder')).toEqual(muted);
});

test('focus turns the boundary accent and two pixels thick, inside the box', async () => {
  const screen = await render(Form);
  const input = screen.getByRole('textbox', { name: 'Email' });
  const box = input.element().parentElement as HTMLElement;
  const before = box.getBoundingClientRect();
  await input.click();
  expect(hexOf(box, 'border-top-color')).toBe(light.color.accent.slice(0, 7));
  expect(style(box, 'box-shadow')).toMatch(/ 0px 0px 0px 1px inset$/);
  expect(box.getBoundingClientRect()).toEqual(before);
});

// the boxes of FieldBoxes: the text input's, around its input; the text area and the select trigger themselves
const fieldBoxes = () => ({
  input: page.getByRole('textbox', { name: 'Text' }).element().parentElement as HTMLElement,
  textarea: page.getByRole('textbox', { name: 'Area' }).element() as HTMLElement,
  trigger: page.getByRole('combobox', { name: 'Choice' }).element() as HTMLElement,
});

test.each([
  { state: 'valid', invalid: false, edge: light.color.borderStrong, focus: light.color.accent },
  { state: 'invalid', invalid: true, edge: light.color.danger, focus: light.color.danger },
])('one field box ($state): a text input, a text area and a select trigger, at rest and focused', async (each) => {
  await render(FieldBoxes, { invalid: each.invalid });
  const boxes = fieldBoxes();
  const drawn = [];
  (document.activeElement as HTMLElement | null)?.blur();
  for (const [name, box] of Object.entries(boxes)) {
    const rest = [
      hexOf(box, 'border-top-color'),
      style(box, 'border-top-left-radius'),
      rgbaOf(box, 'background-color'),
    ];
    // from the keyboard, as a select trigger shows its focus only then
    await userEvent.tab();
    const ring = style(box, 'box-shadow').replace(/^.*\) /, '');
    drawn.push([name, ...rest, hexOf(box, 'border-top-color'), hexOf(box, 'box-shadow'), ring]);
  }
  const [edge, focus] = [each.edge.slice(0, 7), each.focus.slice(0, 7)];
  const fill = rgbaOfHex(light.color.fill);
  expect(drawn).toEqual(
    Object.keys(boxes).map((name) => [name, edge, '12px', fill, focus, focus, '0px 0px 0px 1px inset']),
  );
});

test('one field box (disabled): a text input, a text area and a select trigger, dimmed alike', async () => {
  await render(FieldBoxes, { disabled: true });
  const drawn = Object.entries(fieldBoxes()).map(([name, box]) => [name, style(box, 'opacity'), style(box, 'cursor')]);
  expect(drawn).toEqual(Object.keys(fieldBoxes()).map((name) => [name, '0.38', 'default']));
});

test('a press beside the input, in the box, focuses the input', async () => {
  const screen = await render(Form);
  const input = screen.getByRole('textbox', { name: 'Email' });
  const box = input.element().parentElement as HTMLElement;
  // in the padding, halfway down: a corner is outside the rounded box
  await userEvent.click(page.elementLocator(box), { position: { x: 6, y: 22 } });
  await expect.element(input).toHaveFocus();
});

test('the clear button comes with text, empties the field and gives focus back', async () => {
  const screen = await render(Form, { clearable: true });
  const input = screen.getByRole('textbox', { name: 'Email' });
  expect(screen.container.querySelector('button[aria-label="Clear"]')).toBeNull();
  await input.fill('ada@example.com');
  const clear = screen.getByRole('button', { name: 'Clear' });
  await clear.click();
  await expect.element(input).toHaveValue('');
  await expect.element(input).toHaveFocus();
  await expect.element(clear).not.toBeInTheDocument();
});

test('a password can be shown and hidden, with the names of the labels', async () => {
  const screen = await render(Form, { labels: labelsFr });
  const show = screen.getByRole('button', { name: 'Afficher le mot de passe' });
  const password = screen.getByLabelText('Password');
  await expect.element(password).toHaveAttribute('type', 'password');
  await show.click();
  await expect.element(password).toHaveAttribute('type', 'text');
  await screen.getByRole('button', { name: 'Masquer le mot de passe' }).click();
  await expect.element(password).toHaveAttribute('type', 'password');
});

test('a text area is twice a control tall, grows with its lines up to maxRows, then scrolls', async () => {
  const screen = await render(Form);
  const notes = screen.getByRole('textbox', { name: 'Notes' });
  const height = () => notes.element().getBoundingClientRect().height;
  expect(height()).toBe(88);
  await notes.fill('1\n2\n3\n4');
  const four = height();
  expect(four).toBeGreaterThan(88);
  await notes.fill('1\n2\n3\n4\n5\n6\n7\n8');
  expect(height()).toBe(four);
  expect(notes.element().scrollHeight).toBeGreaterThan(notes.element().clientHeight);
});

test('the search field: a pill named by its label, small, with a clear button, glass over content', async () => {
  const screen = await render(Form, { glass: true, searchSize: 'sm' });
  const search = screen.getByRole('searchbox', { name: 'Search' });
  const box = search.element().parentElement as HTMLElement;
  expect(style(box, 'border-top-left-radius')).toBe('999px');
  expect(box.getBoundingClientRect().height).toBe(32);
  expect(hexOf(box, 'background-color')).toBe(light.color.glassControl.slice(0, 7));
  expect(style(box, 'backdrop-filter')).toMatch(/blur/);
  await search.fill('jazz');
  await screen.getByRole('button', { name: 'Clear' }).click();
  await expect.element(search).toHaveValue('');
});

test("the search field is medium by default, as Flutter's TextField.search", async () => {
  const screen = await render(Form);
  const box = screen.getByRole('searchbox', { name: 'Search' }).element().parentElement as HTMLElement;
  expect(box.getBoundingClientRect().height).toBe(44);
});

test('a disabled field: dimmed, no clear button', async () => {
  const screen = await render(Form, { disabled: true, clearable: true, email: 'ada@example.com' });
  const input = screen.getByRole('textbox', { name: 'Email' });
  await expect.element(input).toBeDisabled();
  expect(style(input.element().parentElement as HTMLElement, 'opacity')).toBe('0.38');
  expect(screen.container.querySelector('button[aria-label="Clear"]')).toBeNull();
});
