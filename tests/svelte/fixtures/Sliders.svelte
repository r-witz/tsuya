<!-- A plain slider and one with a custom valueLabel. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Slider, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: number;
    min?: number;
    max?: number;
    step?: number;
    disabled?: boolean;
    dir?: 'ltr' | 'rtl';
    withLabel?: boolean;
    /** No `min`, `max` or `step`: the defaults. */
    bare?: boolean;
    /** Puts the slider in a scroller and reports `input` and `change` to this. */
    record?: (name: string) => void;
  }

  let {
    value = $bindable(40),
    min = 0,
    max = 100,
    step,
    disabled = false,
    dir = 'ltr',
    withLabel = false,
    bare = false,
    record,
  }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="width: 300px; padding: var(--t-space-16); {record ? 'height: 120px; overflow-y: auto' : ''}">
    {#if bare}
      <Slider bind:value label="Volume" />
    {:else}
      <Slider
        bind:value
        {min}
        {max}
        {step}
        {disabled}
        oninput={() => record?.('input')}
        onchange={() => record?.('change')}
        label="Volume"
        valueLabel={withLabel ? (v) => `${String(v)} songs` : undefined}
      />
    {/if}
    {#if record}<div style="height: 600px"></div>{/if}
  </div>
</TsuyaProvider>
