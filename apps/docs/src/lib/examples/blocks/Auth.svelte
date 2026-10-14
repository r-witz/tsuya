<!--
  Auth: sign in, sign up and reset password, on the brand accent and the glow. No content leads here, so the
  accent is the brand's (accentFromColor, computed once) and the top of the screen is lit by the neutral glow, which
  Screen shows whenever it has no ambient image. One column, no card; the one accent action is the full-width button.
  Fields are checked on blur, then on every change once they show an error (see the Forms block).
-->
<script lang="ts">
  import { accentFromColor } from '@tsuya/core';
  import { AccentRegion, Banner, Button, Checkbox, Field, Screen, TextInput, toast } from '@tsuya/svelte';
  import { tick } from 'svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  type View = 'signin' | 'signup' | 'reset';
  type Name = 'name' | 'email' | 'password';

  const BRAND = accentFromColor('#6C5CE7');
  const TITLES: Record<View, [string, string]> = {
    signin: ['Welcome back', 'Sign in to pick up where you left off.'],
    signup: ['Create your account', 'Your library, on every device.'],
    reset: ['Reset your password', 'We will email you a link to choose a new one.'],
  };

  let view = $state<View>('signin');
  let values = $state({ name: '', email: '', password: '', keep: true });
  let errors = $state<Record<Name, string>>({ name: '', email: '', password: '' });
  let busy = $state(false);
  let sent = $state(false);
  let heading = $state<HTMLHeadingElement | null>(null);

  // the fields each view asks for, in order
  const FIELDS: Record<View, Name[]> = {
    signin: ['email', 'password'],
    signup: ['name', 'email', 'password'],
    reset: ['email'],
  };

  function message(field: Name): string {
    const value = values[field];
    if (field === 'name') return value.trim().length < 2 ? 'Enter your name, at least 2 letters.' : '';
    if (field === 'email') return /^\S+@\S+\.\S+$/.test(value) ? '' : 'Enter an email address like nora@example.com.';
    if (view === 'signup') return value.length < 8 ? 'Choose a password of at least 8 characters.' : '';
    return value ? '' : 'Enter your password.';
  }

  function check(field: Name) {
    errors[field] = message(field);
  }

  async function go(next: View) {
    view = next;
    sent = false;
    errors = { name: '', email: '', password: '' };
    await tick();
    heading?.focus(); // the new screen is announced from its title
  }

  function submit(event: SubmitEvent) {
    event.preventDefault();
    const fields = FIELDS[view];
    for (const field of fields) check(field);
    const first = fields.find((field) => errors[field]);
    if (first) {
      (event.currentTarget as HTMLFormElement).querySelector<HTMLInputElement>(`[name="${first}"]`)?.focus();
      return;
    }
    busy = true;
    setTimeout(() => {
      busy = false;
      if (view === 'reset') sent = true;
      else toast(view === 'signin' ? 'Signed in' : 'Account created', { icon: 'check' });
    }, 800);
  }
</script>

<AccentRegion pair={BRAND} style="display: contents">
  <Screen>
    <div class="page">
      <div class="brand">
        <span class="mark"><BlockIcon name="play" /></span>
        <span class="t-title-m">Cadence</span>
      </div>

      <header>
        <h1 class="t-display-s" tabindex="-1" bind:this={heading}>{TITLES[view][0]}</h1>
        <p class="t-body">{TITLES[view][1]}</p>
      </header>

      {#if sent}
        <Banner tone="success" title="Check your inbox">
          If {values.email} has an account, a link to reset the password is on its way.
        </Banner>
      {/if}

      <form class="form" novalidate onsubmit={submit}>
        {#each FIELDS[view] as field (field)}
          {#if field === 'name'}
            <Field label="Name" required error={errors.name}>
              {#snippet control(props)}
                <TextInput
                  {...props}
                  name="name"
                  autocomplete="name"
                  bind:value={values.name}
                  onblur={() => {
                    check('name');
                  }}
                  oninput={() => {
                    if (errors.name) check('name');
                  }}
                />
              {/snippet}
            </Field>
          {:else if field === 'email'}
            <Field label="Email" required error={errors.email}>
              {#snippet control(props)}
                <TextInput
                  {...props}
                  name="email"
                  type="email"
                  autocomplete="email"
                  bind:value={values.email}
                  onblur={() => {
                    check('email');
                  }}
                  oninput={() => {
                    if (errors.email) check('email');
                  }}
                />
              {/snippet}
            </Field>
          {:else}
            <Field
              label="Password"
              required
              hint={view === 'signup' ? 'At least 8 characters.' : undefined}
              error={errors.password}
            >
              {#snippet control(props)}
                <TextInput
                  {...props}
                  name="password"
                  type="password"
                  autocomplete={view === 'signup' ? 'new-password' : 'current-password'}
                  bind:value={values.password}
                  onblur={() => {
                    check('password');
                  }}
                  oninput={() => {
                    if (errors.password) check('password');
                  }}
                />
              {/snippet}
            </Field>
          {/if}
        {/each}

        {#if view === 'signin'}<Checkbox bind:checked={values.keep}>Keep me signed in</Checkbox>{/if}

        <Button variant="primary" type="submit" block loading={busy}>
          {view === 'signin' ? 'Sign in' : view === 'signup' ? 'Create account' : 'Send the link'}
        </Button>
      </form>

      <!-- the other ways through: plain, so that the primary stays the one accent action -->
      <nav class="others" aria-label="Other ways">
        {#if view === 'signin'}
          <Button variant="ghost" size="sm" onclick={() => go('reset')}>Forgot your password?</Button>
          <Button variant="ghost" size="sm" onclick={() => go('signup')}>Create an account</Button>
        {:else}
          <Button variant="ghost" size="sm" onclick={() => go('signin')}>
            {view === 'signup' ? 'I already have an account' : 'Back to sign in'}
          </Button>
        {/if}
      </nav>
    </div>
  </Screen>
</AccentRegion>

<style>
  .page {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-24);
    max-width: 400px;
    margin-inline: auto;
    padding-top: var(--t-space-48);
  }
  .brand {
    display: flex;
    align-items: center;
    gap: var(--t-space-12);
  }
  .mark {
    display: grid;
    place-items: center;
    width: var(--t-size-control-lg);
    height: var(--t-size-control-lg);
    border-radius: var(--t-radius-full);
    background: var(--t-accent);
    color: var(--t-on-accent);
  }
  .mark :global(svg) {
    width: var(--t-size-icon);
    height: var(--t-size-icon);
  }
  header h1,
  header p {
    margin: 0;
  }
  header h1 {
    outline: none;
  }
  header p {
    margin-top: var(--t-space-8);
    color: var(--t-text-muted);
  }
  .form {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-16);
  }
  .others {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: var(--t-space-8);
  }
</style>
