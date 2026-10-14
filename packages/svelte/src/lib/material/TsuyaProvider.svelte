<!--
  @component
  The root of an app (DESIGN.md, Theme and mode; Labels): the mode, the labels every component reads, and the live
  regions of the announcer. A forced mode is also set on the document, so that the page's own background follows, but
  only once scripts run: before that, `<html data-theme>` in the app's HTML for a fixed mode, and `themeScript()` of
  @tsuya/core in the head for a persisted one, keep the first paint in the right mode.
-->
<script lang="ts">
  import type { TsuyaLabels } from '@tsuya/core';
  import { HIDDEN } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';

  import { setLabels } from '../primitives/labels.ts';
  import ToastRegion from '../components/toast/ToastRegion.svelte';

  interface Props {
    /** The system's mode, or one forced. */
    mode?: 'system' | 'light' | 'dark';
    /** Every system string: `labelsEn` or `labelsFr` of @tsuya/core, or your own. */
    labels: TsuyaLabels;
    /** The app. */
    children: Snippet;
  }

  let { mode = 'system', labels, children }: Props = $props();

  setLabels(() => labels);

  // what <html> had before a forced mode, for when the provider goes; `applied` while a forced mode is set
  let before: string | undefined;
  let applied = false;

  $effect(() => {
    const root = document.documentElement;
    if (mode === 'system') {
      // back to the system's: not to what the page was served with, which may be a persisted mode (themeScript)
      if (applied) delete root.dataset['theme'];
      applied = false;
      return;
    }
    if (!applied) before = root.dataset['theme'];
    applied = true;
    root.dataset['theme'] = mode;
  });

  $effect(() => () => {
    if (!applied) return;
    const root = document.documentElement;
    if (before === undefined) delete root.dataset['theme'];
    else root.dataset['theme'] = before;
  });
</script>

<div style:display="contents" data-theme={mode === 'system' ? undefined : mode}>
  {@render children()}
</div>
<div data-tsuya-live="polite" aria-live="polite" aria-atomic="true" style={HIDDEN}></div>
<div data-tsuya-live="assertive" aria-live="assertive" aria-atomic="true" style={HIDDEN}></div>
<ToastRegion />
