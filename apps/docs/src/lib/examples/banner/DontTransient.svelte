<!-- Don't: "saved" is over a moment later; a banner that stays would have to be closed by hand (DESIGN.md, Banner: "A lasting state"). -->
<script lang="ts">
  import { Banner } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Banner tone="success" title="Saved" onclose={() => {}} />
</div>
