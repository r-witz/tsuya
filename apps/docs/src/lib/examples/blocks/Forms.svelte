<!--
  Forms: one column, every label always visible, 16 between fields. A field is checked when it loses focus,
  and, once it shows an error, on every change, so the error goes away as soon as it is fixed. On submit every field
  is checked and the focus goes to the first one in error. The actions come last: a full-width primary at the bottom
  on a phone, at the end of the row on desktop.
-->
<script lang="ts">
  import { Button, Checkbox, Field, Screen, ScreenBar, Select, Textarea, TextInput, toast } from '@tsuya/svelte';

  type Name = 'name' | 'email' | 'topic';

  // each rule returns the error, which says what to do next, or an empty string
  const RULES: Record<Name, (value: string | undefined) => string> = {
    name: (v) => ((v ?? '').trim().length < 2 ? 'Enter your name, at least 2 letters.' : ''),
    email: (v) => (/^\S+@\S+\.\S+$/.test(v ?? '') ? '' : 'Enter an email address like nora@example.com.'),
    topic: (v) => (v ? '' : 'Choose what your message is about.'),
  };
  const TOPICS = [
    { value: 'bug', label: 'Something is broken' },
    { value: 'idea', label: 'An idea' },
    { value: 'billing', label: 'Billing' },
  ];

  let values = $state<{ name: string; email: string; topic: string | undefined; message: string; copy: boolean }>({
    name: '',
    email: '',
    topic: undefined,
    message: '',
    copy: true,
  });
  let errors = $state<Record<Name, string>>({ name: '', email: '', topic: '' });
  let submitting = $state(false);
  let width = $state(0);
  // the controls, to move the focus to the first error
  let nameInput = $state<HTMLInputElement | null>(null);
  let emailInput = $state<HTMLInputElement | null>(null);
  let topicSelect = $state<HTMLButtonElement | null>(null);

  const phone = $derived(width < 600);

  /** On blur: the field is checked. */
  function check(field: Name) {
    errors[field] = RULES[field](values[field]);
  }

  /** On change: a field already in error is checked again at once, any other waits for its blur. */
  function change(field: Name, value: string | undefined) {
    values[field] = value as string;
    if (errors[field]) check(field);
  }

  function submit(event: SubmitEvent) {
    event.preventDefault();
    const fields: [Name, HTMLElement | null][] = [
      ['name', nameInput],
      ['email', emailInput],
      ['topic', topicSelect],
    ];
    for (const [field] of fields) check(field);
    const first = fields.find(([field]) => errors[field]);
    if (first) {
      first[1]?.focus();
      return;
    }
    submitting = true;
    setTimeout(() => {
      submitting = false;
      toast('Message sent', { icon: 'check' });
    }, 800);
  }
</script>

<Screen>
  <!-- the screen's own width decides about the actions, not the 560 the form itself is held to -->
  <div bind:clientWidth={width}>
    <div class="page">
      <ScreenBar title="Contact us" onBack={() => {}} backLabel="Back" />

      <!-- novalidate: the page does the checking, and says what to do next in its own words -->
      <form class="form" novalidate onsubmit={submit}>
        <Field label="Name" required error={errors.name}>
          {#snippet control(props)}
            <TextInput
              {...props}
              autocomplete="name"
              bind:ref={nameInput}
              bind:value={
                () => values.name,
                (v: string) => {
                  change('name', v);
                }
              }
              onblur={() => {
                check('name');
              }}
            />
          {/snippet}
        </Field>

        <Field label="Email" required hint="We only use it to answer you." error={errors.email}>
          {#snippet control(props)}
            <TextInput
              {...props}
              type="email"
              autocomplete="email"
              bind:ref={emailInput}
              bind:value={
                () => values.email,
                (v: string) => {
                  change('email', v);
                }
              }
              onblur={() => {
                check('email');
              }}
            />
          {/snippet}
        </Field>

        <Select
          label="Topic"
          required
          placeholder="Choose a topic"
          options={TOPICS}
          error={errors.topic}
          bind:ref={topicSelect}
          bind:value={
            () => values.topic,
            (v: string | undefined) => {
              change('topic', v);
            }
          }
          onblur={() => {
            check('topic');
          }}
        />

        <Field label="Message" optional>
          {#snippet control(props)}<Textarea {...props} bind:value={values.message} />{/snippet}
        </Field>

        <Checkbox bind:checked={values.copy}>Send me a copy</Checkbox>

        <div class="actions">
          {#if !phone}<Button variant="ghost" type="reset">Cancel</Button>{/if}
          <Button variant="primary" type="submit" block={phone} loading={submitting}>Send message</Button>
        </div>
      </form>
    </div>
  </div>
</Screen>

<style>
  .page {
    max-width: 560px;
    margin-inline: auto;
    padding-top: var(--t-space-12);
  }
  /* one column, 16 between the fields */
  .form {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-16);
    margin-top: var(--t-space-24);
  }
  .actions {
    display: flex;
    justify-content: flex-end;
    gap: var(--t-space-8);
    margin-top: var(--t-space-8);
  }
</style>
