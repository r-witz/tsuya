<!--
  Home: the four rules, shown live. Pick a cover — one of the samples, or your own — and the engine
  (accentFromImage) runs right here, in the browser: the whole shell takes its accent and its ambient
  (DESIGN.md, Surface; #lib/material/home-accent.svelte.ts).
-->
<script lang="ts">
  import { onDestroy, onMount } from 'svelte';
  import { accentFromImage, type ImageAccent } from '@tsuya/core';
  import { Button } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
  import { COVERS, renderCover } from '#lib/material/covers.ts';
  import { homeAccent } from '#lib/material/home-accent.svelte.ts';

  // DESIGN.md, "The four rules"
  const RULES = [
    {
      title: 'Content gives the colour',
      text: 'The accent is computed from the content in view. Its hue is kept; its lightness moves into a readable band for each mode.',
    },
    {
      title: 'Content lights the background',
      text: 'The leading content, scaled, blurred and saturated, lights the top of the screen, at an opacity computed so text on it stays readable.',
    },
    {
      title: 'Glass only above content',
      text: 'Bars, menus, sheets and toasts are glass, tinted by the accent. Never glass on a flat background.',
    },
    {
      title: 'Grain on backgrounds',
      text: 'A film grain sits under the content, never on text or glass.',
    },
  ];

  interface Pick {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  // a sample before it is picked: its accent is computed the first time it is
  interface Sample {
    name: string;
    src: string;
    canvas: HTMLCanvasElement;
    pair?: ImageAccent;
  }

  let picks = $state<Sample[]>([]);
  let current = $state(-1);
  let uploaded = $state<Pick | null>(null);
  const active = $derived.by((): Pick | null => {
    if (current === -1) return uploaded;
    const pick = picks[current];
    return pick?.pair ? { name: pick.name, src: pick.src, pair: pick.pair } : null;
  });

  // drawn at 256 (the picker shows 96, the ambient blurs it away), each one's accent computed when it is first
  // picked: a phone's first seconds stay free of long tasks
  onMount(() => {
    const draw = (index: number): void => {
      const cover = COVERS[index];
      if (!cover) return;
      const canvas = renderCover(cover, 256);
      picks.push({ name: cover.name, src: canvas.toDataURL('image/jpeg', 0.92), canvas });
      if (index === 0) choose(0);
      // one cover per task
      setTimeout(() => {
        draw(index + 1);
      });
    };
    draw(0);
  });

  onDestroy(() => {
    homeAccent.clear();
  });

  function choose(index: number): void {
    current = index;
    uploaded = null;
    const pick = picks[index];
    if (!pick) return;
    pick.pair ??= accentFromImage(pick.canvas);
    homeAccent.set(pick.pair, pick.src);
  }

  async function onUpload(event: Event): Promise<void> {
    const file = (event.currentTarget as HTMLInputElement).files?.[0];
    if (!file) return;
    const src = URL.createObjectURL(file);
    const image = new Image();
    image.src = src;
    await image.decode();
    uploaded = { name: file.name, src, pair: accentFromImage(image) };
    current = -1;
    homeAccent.set(uploaded.pair, uploaded.src);
  }
</script>

<svelte:head>
  <title>tsuya — a design system for Svelte and Flutter</title>
</svelte:head>

<section class="hero">
  <p class="t-label">Design system · Svelte and Flutter</p>
  <h1 class="t-display-m">Content gives the colour.</h1>
  <p class="t-body-l t-muted lead">
    Neutral surfaces, familiar layouts, and one material that comes from whatever is on screen. Pick a cover below: this
    page takes its accent and its light, in both modes, with every contrast still checked.
  </p>
  <div class="actions">
    <Button variant="primary" href="/getting-started">Get started</Button>
    <Button variant="secondary" href="/components">Browse components</Button>
  </div>
</section>

<section class="picker" aria-labelledby="picker-title">
  <h2 id="picker-title" class="t-title-l">Pick a cover</h2>
  <div class="covers">
    <!-- every cover's place is there from the server's HTML, so drawing them one by one moves nothing -->
    {#each COVERS as cover, i (cover.name)}
      <button
        class="cover t-pressable"
        data-press="none"
        aria-label={cover.name}
        aria-pressed={current === i}
        disabled={!picks[i]}
        onclick={() => {
          choose(i);
        }}
      >
        {#if picks[i]}<img src={picks[i].src} alt="" width="96" height="96" />{/if}
      </button>
    {/each}
    <label class="cover upload t-pressable" data-press="none">
      <input type="file" accept="image/*" onchange={onUpload} />
      <Icon name="upload" />
      <span class="t-caption">Your own</span>
    </label>
  </div>
  <!-- there before a cover is picked too, empty, for the same reason -->
  <p class="readout t-caption t-muted t-tabular">
    {#if active}
      {active.name}: seed {active.pair.seed ?? 'none'} → light {active.pair.light}, dark {active.pair.dark} · ambient
      {active.pair.ambient.light.toFixed(2)} / {active.pair.ambient.dark.toFixed(2)}
    {:else}&nbsp;{/if}
  </p>
</section>

<section class="rules" aria-label="The four rules">
  <ol class="rule-list">
    {#each RULES as rule, i (rule.title)}
      <li class="rule">
        <span class="index t-title-l t-muted t-tabular">{String(i + 1).padStart(2, '0')}</span>
        <div>
          <p class="t-title-s">{rule.title}</p>
          <p class="t-body t-muted">{rule.text}</p>
        </div>
      </li>
    {/each}
  </ol>
</section>

<style>
  .hero {
    padding-block: var(--t-space-48) var(--t-space-32);
  }
  .lead {
    max-width: 60ch;
    margin-top: var(--t-space-12);
  }
  .actions {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-12);
    margin-top: var(--t-space-24);
  }
  .picker {
    padding-block: var(--t-space-32);
  }
  .covers {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-12);
    margin-top: var(--t-space-16);
  }
  .cover {
    display: grid;
    place-items: center;
    width: 96px;
    height: 96px;
    padding: 0;
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
    overflow: hidden;
    background: var(--t-fill);
    color: var(--t-text-muted);
  }
  .cover img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .cover[aria-pressed='true'] {
    outline: var(--t-state-focus-width) solid var(--t-accent);
    outline-offset: var(--t-state-focus-offset);
  }
  .upload {
    flex-direction: column;
    gap: var(--t-space-4);
  }
  /* the icon takes its host's size, so a 96 px tile would give it all of it */
  .upload :global(svg) {
    width: var(--t-size-icon-lg);
    height: var(--t-size-icon-lg);
  }
  .upload input {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(100%);
  }
  .readout {
    margin-top: var(--t-space-16);
  }
  .rules {
    padding-block: var(--t-space-32) var(--t-space-64);
  }
  .rule-list {
    margin: 0;
    padding: 0;
    list-style: none;
  }
  .rule {
    display: flex;
    gap: var(--t-space-16);
    padding-block: var(--t-space-16);
    border-top: 1px solid var(--t-border);
  }
  .rule p {
    margin: 0;
  }
  .rule p + p {
    margin-top: var(--t-space-4);
  }
  .index {
    flex: none;
    width: 2ch;
  }
</style>
