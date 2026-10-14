<!-- A standalone chip, a single-selection group and a multiple-selection group. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Chip, ChipGroup, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    standalone?: boolean;
    sort?: string;
    filters?: string[];
    disabled?: boolean;
    dir?: 'ltr' | 'rtl';
  }

  let {
    standalone = $bindable(false),
    sort = $bindable('recent'),
    filters = $bindable([]),
    disabled = false,
    dir = 'ltr',
  }: Props = $props();
</script>

{#snippet star()}<svg viewBox="0 0 24 24" data-testid="icon"><path d="M12 3l9 18H3z" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div style="display: flex; gap: var(--t-space-8); padding: var(--t-space-16)">
    <Chip
      selected={standalone}
      onclick={() => {
        standalone = !standalone;
      }}>Glass</Chip
    >
    <Chip glass selected icon={star}>Starred</Chip>
  </div>
  <div {dir} style="display: flex; flex-direction: column; gap: var(--t-space-16); padding: var(--t-space-16)">
    <ChipGroup bind:value={sort} label="Sort">
      <Chip value="recent">Recent</Chip>
      <Chip value="popular" icon={star}>Popular</Chip>
      <Chip value="az" {disabled}>A–Z</Chip>
    </ChipGroup>
    <ChipGroup bind:value={filters} multiple label="Filters">
      <Chip value="new">New</Chip>
      <Chip value="sale">Sale</Chip>
    </ChipGroup>
  </div>
</TsuyaProvider>
