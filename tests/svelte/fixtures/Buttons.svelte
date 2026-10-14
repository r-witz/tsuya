<!-- Buttons of every variant and size, an icon button, and a spinner alone. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, IconButton, Spinner, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    loading?: boolean;
    pressed?: boolean;
    disabled?: boolean;
    custom?: number;
    onpress?: (name: string) => void;
  }

  let { loading = false, pressed = false, disabled = false, custom = 64, onpress = () => {} }: Props = $props();
</script>

{#snippet star()}<svg viewBox="0 0 24 24" data-testid="icon"
    ><path d="M12 3l3 6 6 1-4 4 1 6-6-3-6 3 1-6-4-4 6-1z" /></svg
  >{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div style="display: flex; flex-direction: column; align-items: flex-start; gap: 8px; padding: var(--t-space-16)">
    {#each ['primary', 'secondary', 'ghost', 'danger', 'glass'] as const as variant (variant)}
      <Button
        {variant}
        onclick={() => {
          onpress(variant);
        }}>{variant}</Button
      >
    {/each}
    {#each ['sm', 'md', 'lg'] as const as size (size)}
      <Button
        {size}
        icon={star}
        {loading}
        {disabled}
        data-testid="sized-{size}"
        onclick={() => {
          onpress(size);
        }}>Save {size}</Button
      >
    {/each}
    <Button
      {loading}
      data-testid="plain"
      onclick={() => {
        onpress('plain');
      }}>Send the message</Button
    >
    <Button href="/settings" {disabled}>Settings</Button>
    <div style="width: 120px"><Button block>A label far too long to fit</Button></div>
    <IconButton
      label="Shuffle"
      {pressed}
      icon={star}
      onclick={() => {
        onpress('shuffle');
      }}
    />
    <IconButton label="Small" size="sm" icon={star} />
    <IconButton label="Large" size="lg" variant="plain" icon={star} />
    <IconButton label="Play" size={custom} variant="accent" icon={star} />
    <Spinner />
    <Spinner size="lg" label="Loading the album" />
  </div>
</TsuyaProvider>
