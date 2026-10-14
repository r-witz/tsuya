<!--
  An example alone, rendered on the server by routes/components/+layout.server.ts to show the HTML it renders: inside
  a provider, for its labels, and between two markers that the load cuts it out of.
-->
<script lang="ts">
  import { labelsEn } from '@tsuya/core';
  import { TsuyaProvider } from '@tsuya/svelte';
  import type { Component } from 'svelte';

  let { example: Example }: { example: Component } = $props();
</script>

<TsuyaProvider labels={labelsEn}><tsuya-example><Example /></tsuya-example></TsuyaProvider>
