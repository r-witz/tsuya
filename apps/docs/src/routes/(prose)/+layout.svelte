<!--
  The 3 pages written as plain Markdown (.svx): Getting started, For agents, Changelog. A route group so their URLs
  stay flat (/getting-started, not /prose/getting-started) while sharing the prose type styling (app.css's `.prose`
  rules) that mdsvex's bare h1/p/code/a output needs and a component page, built from its own classes, does not.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  let { children }: { children: Snippet } = $props();
</script>

<div class="prose">
  {@render children()}
</div>
