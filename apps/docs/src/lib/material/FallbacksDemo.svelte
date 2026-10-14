<!--
  Fallbacks (DESIGN.md, Fallbacks): reduced transparency and right-to-left are forceable from the app
  (data-transparency="reduce"; the standard dir attribute, since tsuya's CSS is written with logical properties), so
  they are shown live. Reduced motion and high contrast are read-only system signals (@media queries; see
  primitives/motion.svelte.ts) with no app-side override, so they are explained instead of faked.
-->
<script lang="ts">
  import Icon from '#lib/icons/Icon.svelte';

  let reduceTransparency = $state(false);
  let rtl = $state(false);
</script>

<div class="fallback">
  <label class="t-body">
    <input type="checkbox" bind:checked={reduceTransparency} />
    Reduce transparency
  </label>
  <div class="art" data-transparency={reduceTransparency ? 'reduce' : undefined}>
    <div class="glass t-glass" data-shadow="lg">
      <p class="t-body-strong">Glass</p>
      <p class="t-caption t-muted">
        {reduceTransparency ? 'Opaque, no blur: the fill alone.' : 'Blurred and translucent.'}
      </p>
    </div>
  </div>
</div>

<div class="fallback">
  <label class="t-body">
    <input type="checkbox" bind:checked={rtl} />
    Right-to-left
  </label>
  <div class="rtl-row" dir={rtl ? 'rtl' : 'ltr'}>
    <span class="icon"><Icon name="share" /></span>
    <span class="t-body">Share</span>
  </div>
</div>

<p class="t-body t-muted">
  Reduced motion and high contrast are read from the system, with no in-app override: macOS Settings → Accessibility
  (Reduce Motion, Increase Contrast), Windows Settings → Accessibility, or a browser's devtools (in Chrome, the
  Rendering tab's "Emulate CSS media feature prefers-reduced-motion / prefers-contrast").
</p>

<style>
  .fallback {
    margin-top: var(--t-space-24);
  }
  .fallback:first-child {
    margin-top: var(--t-space-16);
  }
  label {
    display: inline-flex;
    align-items: center;
    gap: var(--t-space-8);
  }
  .art {
    margin-top: var(--t-space-12);
    padding: var(--t-space-24);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
  .glass {
    max-inline-size: 260px;
    padding: var(--t-space-16);
  }
  .rtl-row {
    display: flex;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-12);
    padding: var(--t-space-12) var(--t-space-16);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
    inline-size: fit-content;
  }
  .icon {
    display: flex;
    inline-size: var(--t-size-icon);
    block-size: var(--t-size-icon);
    color: var(--t-text-muted);
  }
</style>
